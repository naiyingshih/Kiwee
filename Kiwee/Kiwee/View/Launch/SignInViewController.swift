//
//  LastViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/25.
//

import UIKit
import AuthenticationServices
import FirebaseAuth
import CryptoKit

class SignInViewController: UIViewController {
    
    /*fileprivate*/ var currentNonce: String?
    private var currentArea: Block?
    let datePicker = UIDatePicker()
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var goalWeightStackView: UIStackView!
    @IBOutlet weak var goalWeightTextField: UITextField!
    @IBOutlet weak var achieveStackView: UIStackView!
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setInitialUI()
    }
    
    func updateNextButtonState(isEnabled: Bool) {
        nextButton.isEnabled = isEnabled
        let alpha: CGFloat = isEnabled ? 1.0 : 0.5
        nextButton.backgroundColor = nextButton.backgroundColor?.withAlphaComponent(alpha)
    }
    
    func setInitialUI() {
        achieveStackView.isHidden = true
        
        goalWeightTextField.keyboardType = .decimalPad
        goalWeightTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        datePicker.addTarget(self, action: #selector(datePickerDidChange), for: .valueChanged)
        
        setupInitialLabels()
        cardView.backgroundColor = UIColor.hexStringToUIColor(hex: "004358")
        cardView.backgroundColor = cardView.backgroundColor?.withAlphaComponent(0.2)
        cardView.layer.cornerRadius = 10
        
        nextButton.layer.cornerRadius = 8
        updateNextButtonState(isEnabled: false)
    }
    
    func setupInitialLabels() {
        let defaults = UserDefaults.standard
        
        let name = defaults.string(forKey: "name")

        let height = defaults.double(forKey: "height")
        let initialWeight = defaults.double(forKey: "initial_weight")
        
        let BMI = initialWeight / (height * height) * 10000
        let formattedBMI = String(format: "%.1f", BMI)
        
        let lowRange = 18.5 * height * height / 10000
        let highRange = 24 * height * height / 10000
        let formattedLow = String(format: "%.0f", lowRange)
        let formattedHigh = String(format: "%.0f", highRange)
        
        welcomeLabel.text = "嗨！\(name ?? "")"
        label1.text = "BMI：\(formattedBMI)"
        label2.text = "理想體重：\(formattedLow) - \(formattedHigh) kg"
    }
    
    func setupDatePicker() {
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.centerXAnchor.constraint(equalTo: goalWeightTextField.centerXAnchor),
            datePicker.centerYAnchor.constraint(equalTo: goalWeightTextField.centerYAnchor)
        ])
        datePicker.datePickerMode = .date
    }
    
    @objc func textFieldDidChange() {
        if let textField = goalWeightTextField.text, !textField.isEmpty {
            updateNextButtonState(isEnabled: true)
        } else {
            updateNextButtonState(isEnabled: false)
        }
    }
    
    @objc func datePickerDidChange(_ datePicker: UIDatePicker) {
        if datePicker.date != Date() {
            updateNextButtonState(isEnabled: true)
            let achievement = datePicker.date
            UserDefaults.standard.set(achievement, forKey: "achievement_time")
            updateLabel()
        }
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        if currentArea == nil {
            // Show achievement area
            goalWeightStackView.isHidden = true
            setupDatePicker()
            fetchLabelsData()
            achieveStackView.isHidden = false
            currentArea = .achievement
            updateNextButtonState(isEnabled: false)
        } else if currentArea == .achievement {
            
            if let goalWeight = goalWeightTextField.text {
                UserDefaults.standard.set(goalWeight, forKey: "goal_weight")
            }
            showSignInView()
        }
    }
    
    func calculateRDA() -> Double {
        let defaults = UserDefaults.standard
        let userData = UserData(
            id: "",
            name: "",
            gender: defaults.integer(forKey: "gender"),
            age: defaults.integer(forKey: "age"),
            goal: defaults.integer(forKey: "goal"),
            activeness: defaults.integer(forKey: "activeness"),
            height: defaults.double(forKey: "height"),
            initialWeight: defaults.double(forKey: "initial_weight"),
            updatedWeight: 0,
            goalWeight: 0,
            achievementTime: datePicker.date)

        return BMRUtility.calculateBMR(with: userData)
    }
    
    func fetchLabelsData() {
        let RDA = calculateRDA()
        let formattedRDA = String(format: "%.0f", RDA)
        label1.text = "您一天建議攝取熱量 \(formattedRDA) kcal"
        label2.text = "您將在 ... 天後達成目標！"
    }
    
    func updateLabel() {
        let defaults = UserDefaults.standard
        
        let achievementTime = defaults.object(forKey: "achievement_time") as? Date ?? Date()
        let today = Date()
        let calendar = Calendar.current
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let achievementTimeComponents = calendar.dateComponents([.year, .month, .day], from: achievementTime)

        // Convert components back to dates for comparison
        let dateOnlyToday = calendar.date(from: todayComponents)!
        let dateOnlyAchievementTime = calendar.date(from: achievementTimeComponents)!

        if dateOnlyToday <= dateOnlyAchievementTime {
            // If today is before the achievementTime
            let components = calendar.dateComponents([.day], from: dateOnlyToday, to: dateOnlyAchievementTime)
            if let remainDay = components.day {
                label2.text = "您將在\(remainDay)天後達成目標！"
            } else {
                return
            }
        } else if dateOnlyToday > dateOnlyAchievementTime {
            // If the achievementTime has passed
            let components = calendar.dateComponents([.day], from: dateOnlyToday, to: dateOnlyAchievementTime)
            if let remainDay = components.day {
                label2.text = "已過目標時間：\(remainDay) 天"
                updateNextButtonState(isEnabled: false)
            } else {
                return
            }
        }
    }
    
    func postUserInfo() {
        let id = Auth.auth().currentUser?.uid ?? ""
        let userData = UserDataManager.shared.getCurrentUserData(id: id)
        
        FirestoreManager.shared.postUserData(input: userData) { success in
            if success {
                print("user data add successfully")
                FirestoreManager.shared.postWeightToSubcollection(weight: userData.initialWeight)
            } else {
                print("Error adding user data")
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

extension SignInViewController: SignInDelegate, ASAuthorizationControllerPresentationContextProviding {
    
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

extension SignInViewController: ASAuthorizationControllerDelegate {
    
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

extension SignInViewController {
    // MARK: - 透過 Credential 與 Firebase Auth 串接
    func firebaseSignInWithApple(credential: AuthCredential) {
        Auth.auth().signIn(with: credential) { [weak self] authResult, error in
            guard let self = self, error == nil else {
                print("Error signing in: \(error?.localizedDescription ?? "No error description")")
                return
            }
            print("log in successfully")
            DispatchQueue.main.async {
                self.transitionToWelcomeView()
            }
            self.getFirebaseUserInfo()
            self.checkAppleIDCredentialState(userID: Auth.auth().currentUser?.uid ?? "")
            self.postUserInfo()
        }
    }
    
    func transitionToWelcomeView() {
        let welcomeVC = WelcomeViewController()
        welcomeVC.modalPresentationStyle = .fullScreen
        self.present(welcomeVC, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3.5) {
//                welcomeVC.dismiss(animated: true) {
                    // transition to the initial page of the "Main" storyboard
                    let storyboard = UIStoryboard(name: "Main", bundle: nil)
                    if let initialViewController = storyboard.instantiateInitialViewController() {
                       
                        guard let windowScene = UIApplication.shared.connectedScenes.first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene else { return }
                        guard let window = windowScene.windows.first else { return }
                        
                        window.rootViewController = initialViewController
                        UIView.transition(with: window, duration: 0.5, options: .transitionCrossDissolve, animations: nil, completion: nil)
                        
                        window.makeKeyAndVisible()
                    }
            }
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
