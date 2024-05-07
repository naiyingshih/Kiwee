//
//  MessageTableViewCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/22.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    
    lazy var sendAvatar: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "kiwi")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var responseAvatar: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chatbot")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var sendMessageLabel: UILabel = {
        let label = UILabel()
        label.applyContent(size: 16, color: .black)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var sendMessageView: UIView = {
        let view = UIView()
        view.backgroundColor = KWColor.lightY
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var responseMessageLabel: UILabel = {
        let label = UILabel()
        label.applyContent(size: 16, color: .white)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var responseMessageView: UIView = {
        let view = UIView()
        view.backgroundColor = KWColor.darkB
        view.layer.cornerRadius = 10
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Init
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {}
    
    // MARK: - UI Setting Functions
    func setupUI() {
        backgroundColor = KWColor.background
        contentView.addSubview(sendAvatar)
        contentView.addSubview(sendMessageView)
        contentView.addSubview(responseAvatar)
        contentView.addSubview(responseMessageView)
        sendMessageView.addSubview(sendMessageLabel)
        responseMessageView.addSubview(responseMessageLabel)
        
        NSLayoutConstraint.activate([
            sendAvatar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            sendAvatar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            sendAvatar.widthAnchor.constraint(equalToConstant: 40),
            sendAvatar.heightAnchor.constraint(equalToConstant: 40),
            
            sendMessageView.topAnchor.constraint(equalTo: sendAvatar.bottomAnchor, constant: 8),
            sendMessageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            sendMessageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),
            
            sendMessageLabel.topAnchor.constraint(equalTo: sendMessageView.topAnchor, constant: 8),
            sendMessageLabel.leadingAnchor.constraint(equalTo: sendMessageView.leadingAnchor, constant: 8),
            sendMessageLabel.trailingAnchor.constraint(equalTo: sendMessageView.trailingAnchor, constant: -8),
            sendMessageLabel.bottomAnchor.constraint(equalTo: sendMessageView.bottomAnchor, constant: -8),
            
            responseAvatar.topAnchor.constraint(equalTo: sendMessageLabel.bottomAnchor, constant: 12),
            responseAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            responseAvatar.widthAnchor.constraint(equalToConstant: 40),
            responseAvatar.heightAnchor.constraint(equalToConstant: 40),
            
            responseMessageView.topAnchor.constraint(equalTo: responseAvatar.bottomAnchor, constant: 8),
            responseMessageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            responseMessageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.7),
            responseMessageView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            responseMessageLabel.topAnchor.constraint(equalTo: responseMessageView.topAnchor, constant: 8),
            responseMessageLabel.leadingAnchor.constraint(equalTo: responseMessageView.leadingAnchor, constant: 8),
            responseMessageLabel.trailingAnchor.constraint(equalTo: responseMessageView.trailingAnchor, constant: -8),
            responseMessageLabel.bottomAnchor.constraint(equalTo: responseMessageView.bottomAnchor, constant: -8)
        ])
    }
    
    func configure(with message: MessageRow) {
        sendMessageLabel.text = message.sendText
        responseMessageLabel.text = message.responseText
    }
    
}
