//
//  LastViewController.swift
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
    
    lazy var titleLabel: UILabel = {
        let title = UILabel()
        title.text = "請登入以獲取個人化體驗"
        title.applyContent(size: 20, color: KWColor.darkB)
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
        label.applyContent(size: 15, color: KWColor.darkB)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var loginButton: ASAuthorizationAppleIDButton = {
        let button = ASAuthorizationAppleIDButton()
        button.addTarget(self, action: #selector(pressSignInWithAppleButton), for: UIControl.Event.touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupInitialUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupInitialUI()
    }
    
    // MARK: - UI Setting Function
    func setupInitialUI() {
        backgroundColor = .white
        addSubview(titleLabel)
        addSubview(contentLabel)
        addSubview(divingLine)
        addSubview(loginButton)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 40),
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
    
    // MARK: - Action
    @objc func pressSignInWithAppleButton() {
        delegate?.didTapSignInWithApple()
    }
}
