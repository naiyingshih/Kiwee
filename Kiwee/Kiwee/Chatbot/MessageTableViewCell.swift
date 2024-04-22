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
        label.numberOfLines = 0
        label.textAlignment = .right
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var responseMessageLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textAlignment = .left
        label.textColor = UIColor.black
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        contentView.addSubview(sendAvatar)
        contentView.addSubview(sendMessageLabel)
        contentView.addSubview(responseAvatar)
        contentView.addSubview(responseMessageLabel)
        
        NSLayoutConstraint.activate([
            sendAvatar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            sendAvatar.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            sendAvatar.widthAnchor.constraint(equalToConstant: 40),
            sendAvatar.heightAnchor.constraint(equalToConstant: 40),
            
            sendMessageLabel.topAnchor.constraint(equalTo: sendAvatar.bottomAnchor, constant: 8),
            sendMessageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30),
            sendMessageLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            
            responseAvatar.topAnchor.constraint(equalTo: sendMessageLabel.bottomAnchor, constant: 12),
            responseAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            responseAvatar.widthAnchor.constraint(equalToConstant: 40),
            responseAvatar.heightAnchor.constraint(equalToConstant: 40),
            
            responseMessageLabel.topAnchor.constraint(equalTo: responseAvatar.bottomAnchor, constant: 8),
            responseMessageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 30),
            responseMessageLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.6),
            responseMessageLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with message: MessageRow) {
        sendMessageLabel.text = message.sendText
        responseMessageLabel.text = message.responseText
    }
}
