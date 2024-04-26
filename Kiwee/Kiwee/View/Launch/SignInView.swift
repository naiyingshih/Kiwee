//
//  SignInViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/25.
//

import UIKit
import AuthenticationServices

protocol SignInDelegate: AnyObject {
    func didTapSignInWithApple()
}

class SignInView: UIView {
    
    weak var delegate: SignInDelegate?
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.addTarget(self, action: #selector(closeLogInPage), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.text = "請登入以獲取個人化體驗"
        title.textColor = UIColor.hexStringToUIColor(hex: "004358")
        title.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        title.translatesAutoresizingMaskIntoConstraints = false
        return title
    }()
    
    lazy var divingLine: UIView = {
        let line = UIView()
        line.backgroundColor = UIColor.hexStringToUIColor(hex: "CCCCCC")
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.text = "在不同裝置隨時隨地記錄飲食"
        label.textColor = UIColor.hexStringToUIColor(hex: "004358")
        label.font = UIFont.systemFont(ofSize: 15)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var loginButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(pressSignInWithAppleButton), for: UIControl.Event.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    @objc func closeLogInPage(sender: UIButton) {
        self.removeFromSuperview()
//        activityIndicator?.stopAnimating()
    }
    
    @objc func pressSignInWithAppleButton() {
        delegate?.didTapSignInWithApple()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupInitialUI()
    }
    
    func setupInitialUI() {
        backgroundColor = .white
        addSubview(closeButton)
        addSubview(titleLabel)
        addSubview(contentLabel)
        addSubview(divingLine)
        addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 24),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            contentLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            contentLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            divingLine.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            divingLine.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            divingLine.topAnchor.constraint(equalTo: contentLabel.bottomAnchor, constant: 16),
            divingLine.heightAnchor.constraint(equalToConstant: 1),
            
            loginButton.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 30),
            loginButton.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: 30),
            loginButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -30),
            loginButton.heightAnchor.constraint(equalToConstant: 48)
        ])
    }
}

//extension SignInView: ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding {
//    
//    /// 授權成功
//    /// - Parameters:
//    ///   - controller: _
//    ///   - authorization: _
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
//                
//        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
//            UserDefaults.setValue(true, forKey: "isLoggedIn")
//            print("user: \(appleIDCredential.user)")
//            print("fullName: \(String(describing: appleIDCredential.fullName))")
//            print("Email: \(String(describing: appleIDCredential.email))")
//            print("realUserStatus: \(String(describing: appleIDCredential.realUserStatus))")
//        }
//    }
//    
//    /// 授權失敗
//    /// - Parameters:
//    ///   - controller: _
//    ///   - error: _
//    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
//                
//        switch (error) {
//        case ASAuthorizationError.canceled:
//            break
//        case ASAuthorizationError.failed:
//            break
//        case ASAuthorizationError.invalidResponse:
//            break
//        case ASAuthorizationError.notHandled:
//            break
//        case ASAuthorizationError.unknown:
//            break
//        default:
//            break
//        }
//                    
//        print("didCompleteWithError: \(error.localizedDescription)")
//    }
//    
//    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
//           return self.window!
//    }
//}
