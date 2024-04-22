//
//  ChatBotViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/22.
//

import UIKit

class ChatBotViewController: UIViewController, UITextFieldDelegate {
    
    let tableView = UITableView()
    let messageInputView = MessageInputView()
    var messages: [MessageRow] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        setupTableView()
        setupMessageInputView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageTableViewCell")
        tableView.separatorStyle = .none
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupMessageInputView() {
        messageInputView.delegate = self
        view.addSubview(messageInputView)
        
        messageInputView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            messageInputView.heightAnchor.constraint(equalToConstant: 80)
        ])
    }
    
    // MARK: - Methods for Sending and Handling Messages
    
    private func sendMessage(_ text: String) {
        let responseText = "Response to: \(text)"
        let message = MessageRow(
            isInterctingWithChatGPT: false,
//            sendAvatar: "kiwi",
            sendText: text,
//            responseAvatar: "chatbot",
            responseText: responseText,
            responseError: nil
        )

        messages.append(message)
        tableView.reloadData()
    }
}
    
// MARK: - TableView DataSource & Delegate
    
extension ChatBotViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: MessageTableViewCell.self),
            for: indexPath
        )
        guard let messageCell = cell as? MessageTableViewCell else { return cell }
        
        let message = messages[indexPath.row]
        messageCell.configure(with: message)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        tableView.estimatedRowHeight = 100
        return UITableView.automaticDimension
    }
    
}

// MARK: - MessageInputViewDelegate

extension ChatBotViewController: MessageInputViewDelegate {
    func sendMessageButtonTapped(message: String) {
        sendMessage(message)
    }
}
