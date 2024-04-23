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
    
    lazy var FAQLabel: UILabel = {
        let label = UILabel()
        label.text = "常見問題集"
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var q1Button: UIButton = {
        let button = UIButton()
        button.setTitle("一份低GI且營養均衡的便當食譜", for: .normal)
        setupFAQButtons(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var q2Button: UIButton = {
        let button = UIButton()
        button.setTitle("幫助燃脂的食物", for: .normal)
        setupFAQButtons(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var q3Button: UIButton = {
        let button = UIButton()
        button.setTitle("三餐份量安排", for: .normal)
        setupFAQButtons(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var q4Button: UIButton = {
        let button = UIButton()
        button.setTitle("運動後飲食計畫", for: .normal)
        setupFAQButtons(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var q5Button: UIButton = {
        let button = UIButton()
        button.setTitle("20分鐘有氧運動", for: .normal)
        setupFAQButtons(button)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
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
    
    private func setupFAQButtons(_ sender: UIButton) {
        sender.setTitleColor(.white, for: .normal)
        sender.setTitleColor(.lightGray, for: .highlighted)
        sender.titleLabel?.font = UIFont.systemFont(ofSize: 13)
        sender.contentHorizontalAlignment = .center
        sender.backgroundColor = UIColor.hexStringToUIColor(hex: "004358")
        sender.layer.cornerRadius = 8
    }
    
    private func setupUI() {
        backgroundColor = UIColor.hexStringToUIColor(hex: "BEDB39")

        addSubview(FAQLabel)
        addSubview(q1Button)
        addSubview(q2Button)
        addSubview(q3Button)
        addSubview(q4Button)
        addSubview(q5Button)
        addSubview(messageTextField)
        addSubview(sendButton)
        
        setupConstraint()
    }
    
    private func setupConstraint() {
        
        NSLayoutConstraint.activate([
            FAQLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            FAQLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            q1Button.topAnchor.constraint(equalTo: FAQLabel.bottomAnchor, constant: 8),
            q1Button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            q1Button.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.56),
            
            q2Button.leadingAnchor.constraint(equalTo: q1Button.trailingAnchor, constant: 8),
            q2Button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            q2Button.centerYAnchor.constraint(equalTo: q1Button.centerYAnchor),
            
            q3Button.topAnchor.constraint(equalTo: q1Button.bottomAnchor, constant: 8),
            q3Button.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            
            q4Button.leadingAnchor.constraint(equalTo: q3Button.trailingAnchor, constant: 8),
            q4Button.centerYAnchor.constraint(equalTo: q3Button.centerYAnchor),
            
            q5Button.leadingAnchor.constraint(equalTo: q4Button.trailingAnchor, constant: 8),
            q5Button.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            q5Button.centerYAnchor.constraint(equalTo: q4Button.centerYAnchor),
            
            messageTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            messageTextField.topAnchor.constraint(equalTo: q5Button.bottomAnchor, constant: 16),
            messageTextField.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.8),
            messageTextField.heightAnchor.constraint(equalToConstant: 40),
            
            sendButton.leadingAnchor.constraint(equalTo: messageTextField.trailingAnchor, constant: 12),
            sendButton.centerYAnchor.constraint(equalTo: messageTextField.centerYAnchor),
            sendButton.widthAnchor.constraint(equalToConstant: 30),
            sendButton.heightAnchor.constraint(equalToConstant: 30)
        ])
        
        let equalWidths = [q3Button, q4Button, q5Button].map {
            $0.widthAnchor.constraint(equalTo: q5Button.widthAnchor)
        }
        NSLayoutConstraint.activate(equalWidths)

        // Adjust content hugging and compression resistance
        let buttons = [q3Button, q4Button, q5Button]
        buttons.forEach { button in
            button.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
            button.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        }
    }
    
    @objc private func sendButtonTapped() {
        guard let message = messageTextField.text, !message.isEmpty else { return }
        delegate?.sendMessageButtonTapped(message: message)
        messageTextField.text = ""
    }
    
}
