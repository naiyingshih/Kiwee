//
//  ChatBotViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/22.
//

import UIKit

class ChatBotViewController: UIViewController {
    
    let chatGPTAPI = OpenAIManager(apiKey: "不准commit api key!")
    
    let tableView = UITableView()
    let messageInputView = MessageInputView()
    var messages: [MessageRow] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    private func setupUI() {
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
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

        let newMessage = MessageRow(
            isInteractingWithChatGPT: true,
            sendText: message,
            responseText: nil,
            responseError: nil
        )
        messages.append(newMessage)
        
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .none)
        
        sendMessageToChatBot(message) { response in
            DispatchQueue.main.async {
                self.messages[indexPath.row].responseText = response
                self.tableView.reloadRows(at: [indexPath], with: .none)
                self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }
    
}

// MARK: - OpenAI function

extension ChatBotViewController {
    
    func sendMessageToChatBot(_ message: String, completion: @escaping (String) -> Void) {
        Task {
            do {
                var responseText = ""
                let stream = try await chatGPTAPI.sendMessageStream(text: message)
                for try await line in stream {
                    responseText += line
                    
                    let localResponseText = responseText
                    DispatchQueue.main.async {
                        completion(localResponseText)
                    }
                }
            } catch {
                print("Error: \(error)")
                DispatchQueue.main.async {
                    completion("Failed to get response")
                }
            }
        }
    }
    
//    func sendMessageToChatBot(_ message: String, completion: @escaping (String) -> Void) {
//        Task {
//            do {
//                let stream = try await chatGPTAPI.sendMessageStream(text: message)
//                for try await word in stream {
//                    DispatchQueue.main.async {
//                        completion(word)
//                    }
//                }
//            } catch {
//                print("Error: \(error)")
//                DispatchQueue.main.async {
//                    completion("Failed to get response")
//                }
//            }
//        }
//    }
    
}
