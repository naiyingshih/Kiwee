//
//  SigninViewController.swift
//  Kiwee
//
//  Created by NY on 2024/5/3.
//

import UIKit
import AuthenticationServices
import FirebaseAuth
import Firebase
import CryptoKit
import Lottie

class SigninViewController: UIViewController {

    private var signInWithAppleViewModel = SignInWithAppleViewModel()
    private var signInWithAppleMate = SignInWithAppleMate()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = KWColor.darkB
        setupInitialUI {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.showSignInView()
            }
        }
        NotificationCenter.default.addObserver(self, selector: #selector(showLogoutSuccessAlert), name: .logoutSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showAccountDeletionSuccessAlert), name: .accountDeletionSuccess, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
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
    
    @objc func showLogoutSuccessAlert() {
        AlertManager.closeAlert(title: "登出成功！", message: "感謝您的使用，歡迎隨時回來！", viewController: self, actionHandler: nil)
    }

    @objc func showAccountDeletionSuccessAlert() {
        AlertManager.closeAlert(title: "帳號刪除成功！", message: "感謝您的使用，期待再次相見！", viewController: self, actionHandler: nil)
    }
    
}

// MARK: - Sign in with Apple

extension SigninViewController: SignInDelegate, ASAuthorizationControllerPresentationContextProviding {

    func didTapSignInWithApple(_ view: SignInView) {
        Task {
            do {
                let appleIDCredential = try await self.signInWithAppleMate()
                // Use the appleIDCredential to sign in with Firebase or perform other operations
                let nonce = signInWithAppleViewModel.currentNonce
                guard let appleIDToken = appleIDCredential.identityToken,
                      let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                    // Handle error: unable to fetch identity token
                    print("unable to fetch identity token")
                    return
                }
                
                // 產生 Apple ID 登入的 Credential
                let credential = OAuthProvider.credential(withProviderID: "apple.com",
                                                          idToken: idTokenString,
                                                          rawNonce: nonce)
                // sign in with Firebase using the credential
                firebaseSignInWithApple(credential: credential)
            } catch {
                // Handle error: could be user cancellation or an actual error
                print("Authentication error: \(error.localizedDescription)")
            }
        }
    }

    // MARK: - ASAuthorizationControllerPresentationContextProviding
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
   
}

// MARK: - 透過 Credential 與 Firebase Auth 串接

extension SigninViewController {
    
    func firebaseSignInWithApple(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let self = self, error == nil else {
                print("Error signing in: \(error?.localizedDescription ?? "No error description")")
                return
            }
            print("log in successfully")
            
            let database = Firestore.firestore()
            if let userID = Auth.auth().currentUser?.uid {
                database.collection("users").whereField("id", isEqualTo: userID).getDocuments { (querySnapshot, _) in
                    if let querySnapshot = querySnapshot, !querySnapshot.documents.isEmpty {
                        // Document for user exists, navigate to main storyboard
                        self.navigateToMainStoryboard()
                    } else {
                        // No document for user, present BasicInfoViewController
                        self.presentBasicInfoViewController()
                    }
                }
            }
            self.getFirebaseUserInfo()
            self.checkAppleIDCredentialState(userID: Auth.auth().currentUser?.uid ?? "")
        }
    }
    
    func navigateToMainStoryboard() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let mainVC = storyboard.instantiateInitialViewController() {
            mainVC.modalPresentationStyle = .fullScreen
            self.present(mainVC, animated: true, completion: nil)
        }
    }

    func presentBasicInfoViewController() {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        if let basicInfoVC = storyboard.instantiateViewController(withIdentifier: "BasicInfoViewController") as? BasicInfoViewController {
            basicInfoVC.modalPresentationStyle = .fullScreen
            self.present(basicInfoVC, animated: true, completion: nil)
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
