//
//  ChatBotViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/22.
//

import UIKit

class ChatBotViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    var messagesTableView: UITableView!
    var messageInputField: UITextField!
    var sendMessageButton: UIButton!
    
    var messages: [String] = ["Hello, how can i help you todey?", "I'm good, thanks! How about you?"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        // Messages Table View
        messagesTableView = UITableView()
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        messagesTableView.register(UITableViewCell.self, forCellReuseIdentifier: "messageCell")
        messagesTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messagesTableView)
        
        // Message Input Field
        messageInputField = UITextField()
        messageInputField.delegate = self
        messageInputField.borderStyle = .roundedRect
        messageInputField.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(messageInputField)
        
        // Send Message Button
        sendMessageButton = UIButton(type: .system)
        sendMessageButton.setTitle("Send", for: .normal)
        sendMessageButton.addTarget(self, action: #selector(sendMessage), for: .touchUpInside)
        sendMessageButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(sendMessageButton)
        
        // Auto Layout Constraints
        NSLayoutConstraint.activate([
            messagesTableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            messagesTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messagesTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messagesTableView.bottomAnchor.constraint(equalTo: messageInputField.topAnchor, constant: -8),
            
            messageInputField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            messageInputField.trailingAnchor.constraint(equalTo: sendMessageButton.leadingAnchor, constant: -8),
            messageInputField.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            
            sendMessageButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            sendMessageButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -8),
            sendMessageButton.widthAnchor.constraint(equalToConstant: 60)
        ])
    }
    
    @objc func sendMessage() {
        if let messageText = messageInputField.text, !messageText.isEmpty {
            messages.append(messageText)
            messageInputField.text = ""
            messagesTableView.reloadData()
            let indexPath = IndexPath(row: messages.count - 1, section: 0)
            messagesTableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    // MARK: - TableView DataSource & Delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath)
        let isUserMessage = indexPath.row % 2 != 0
            
            if isUserMessage {
                // User messages aligned to the right
                cell.textLabel?.textAlignment = .right
                cell.textLabel?.text = messages[indexPath.row]
            } else {
                // Server messages aligned to the left
                cell.textLabel?.textAlignment = .left
                // Assuming you have a separate array for server messages
                cell.textLabel?.text = messages[indexPath.row]
            }
        return cell
    }
}
