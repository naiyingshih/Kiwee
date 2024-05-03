//
//  SigninViewController.swift
//  Kiwee
//
//  Created by NY on 2024/5/3.
//

import UIKit
import AuthenticationServices
import FirebaseAuth
import CryptoKit
import Lottie

class SigninViewController: UIViewController {
    
    fileprivate var currentNonce: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showSignInView()
            }
        }
    }
    
    func setupInitialUI(completion: @escaping () -> Void) {
        let foodView = LottieAnimationView(name: "Food_animation")
        foodView.frame = CGRect(x: 0, y: 0, width: 300, height: 300)
        foodView.center = self.view.center
        foodView.contentMode = .scaleAspectFill
        view.addSubview(foodView)
        foodView.loopMode = .playOnce
        foodView.play { (finished) in
            if finished {
                completion()
            }
        }
    }
    
    func showSignInView() {
        // Create a semi-transparent black overlay view
        let overlayView = UIView()
        overlayView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        
        // Constraints for overlayView to cover the entire screen
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        // Create and setup your signInView
        let signinView = SignInView()
        signinView.delegate = self
        signinView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(signinView)
        
        signinView.layer.cornerRadius = 10
        signinView.clipsToBounds = true
        let screenHeight = UIScreen.main.bounds.height
        let signinViewHeight = screenHeight * 0.4
        
        let offScreenConstraint = signinView.topAnchor.constraint(equalTo: view.bottomAnchor)
        NSLayoutConstraint.activate([
            signinView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            signinView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            signinView.heightAnchor.constraint(equalToConstant: signinViewHeight),
            offScreenConstraint
        ])
        
        view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.5, animations: {
            offScreenConstraint.isActive = false
            let finalPositionConstraint = signinView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
            finalPositionConstraint.isActive = true
            self.view.layoutIfNeeded()
        })
    }
    
}

// MARK: - Sign in with Apple

extension SigninViewController: SignInDelegate, ASAuthorizationControllerPresentationContextProviding {
    
    func didTapSignInWithApple() {
        let nonce = randomNonceString()
        currentNonce = nonce
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)

        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length

        while(remainingLength > 0) {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if (errorCode != errSecSuccess) {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }

            randoms.forEach { random in
                if (remainingLength == 0) {
                    return
                }

                if (random < charset.count) {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        return hashString
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
    
}

extension SigninViewController: ASAuthorizationControllerDelegate {
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        // 登入成功
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            guard let nonce = currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Unable to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Unable to serialize token string from data\n\(appleIDToken.debugDescription)")
                return
            }
            // 產生 Apple ID 登入的 Credential
            let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: idTokenString, rawNonce: nonce)
            // 與 Firebase Auth 進行串接
            firebaseSignInWithApple(credential: credential)
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        // 登入失敗，處理 Error
        switch error {
        case ASAuthorizationError.canceled:
            print("使用者取消登入")
        case ASAuthorizationError.failed:
            print("授權請求失敗")
        case ASAuthorizationError.invalidResponse:
            print("授權請求無回應")
        case ASAuthorizationError.notHandled:
            print("授權請求未處理")
        case ASAuthorizationError.unknown:
            print("授權失敗，原因不知")
        default:
            break
        }
    }
}

extension SigninViewController {
    // MARK: - 透過 Credential 與 Firebase Auth 串接
    func firebaseSignInWithApple(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let self = self, error == nil else {
                print("Error signing in: \(error?.localizedDescription ?? "No error description")")
                return
            }
            print("log in successfully")
            let storyboard = UIStoryboard(name: "Login", bundle: nil)
            if let basicInfoVC = storyboard.instantiateViewController(withIdentifier: "BasicInfoViewController") as? BasicInfoViewController {
                basicInfoVC.modalPresentationStyle = .fullScreen
                self.present(basicInfoVC, animated: true, completion: nil)
            }
            self.getFirebaseUserInfo()
            self.checkAppleIDCredentialState(userID: Auth.auth().currentUser?.uid ?? "")
        }
    }
    
    // MARK: - Firebase 取得登入使用者的資訊
    
    func getFirebaseUserInfo() {
        let currentUser = Auth.auth().currentUser
        guard let user = currentUser else {
            print("can not load user data")
            return
        }
        let uid = user.uid
        let email = user.email
        print("===\(uid)")
        print("===\(String(describing: email))")
    }
    
    func checkAppleIDCredentialState(userID: String) {
        ASAuthorizationAppleIDProvider().getCredentialState(forUserID: userID) { credentialState, error in
            switch credentialState {
            case .authorized:
                print("使用者已授權")
            case .revoked:
                print("使用者憑證已被註銷")
            case .notFound:
                print("使用者尚未使用過 Apple ID 登入")
            case .transferred:
                print("請與開發者團隊進行聯繫，以利進行使用者遷移")
            default:
                break
            }
        }
    }
}
