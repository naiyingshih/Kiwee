//
//  MessageRowView.swift
//  Kiwee
//
//  Created by NY on 2024/4/22.
//

import UIKit

protocol MessageInputViewDelegate: AnyObject {
    func sendMessageButtonTapped(message: String)
}

class MessageInputView: UIView {
    
    weak var delegate: MessageInputViewDelegate?
    
    lazy var messageTextField: UITextField = {
        let textField = UITextField()
        textField.borderStyle = .roundedRect
        textField.placeholder = "請輸入訊息"
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Send"), for: .normal)
        button.setImage(UIImage(named: "Send_Selected"), for: .highlighted)
        button.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    private func setupUI() {
        backgroundColor = UIColor.hexStringToUIColor(hex: "BEDB39")
        
        addSubview(messageTextField)
        addSubview(sendButton)
        
        NSLayoutConstraint.activate([
            messageTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            messageTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            messageTextField.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8),
            messageTextField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 12),
            sendButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 30),
            sendButton.heightAnchor.constraint(equalToConstant: 30)
        ])
    }
    
    @objc private func sendButtonTapped() {
        guard let message = messageTextField.text, !message.isEmpty else { return }
        delegate?.sendMessageButtonTapped(message: message)
        messageTextField.text = ""
    }
    
}
