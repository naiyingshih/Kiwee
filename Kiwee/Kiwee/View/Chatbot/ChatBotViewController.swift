//
//  ChatBotViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/22.
//

import UIKit

class ChatBotViewController: UIViewController {
    
    var apiKey: String {
        guard let plistPath = Bundle.main.path(forResource: "APIKey", ofType: "plist"),
              let plistDict = NSDictionary(contentsOfFile: plistPath),
              let apiKey = plistDict["apiKey"] as? String else {
            fatalError("API key not found in plist")
        }
        return apiKey
    }
    
    lazy var chatGPTAPI: OpenAIManager = {
        return OpenAIManager(apiKey: apiKey)
    }()
    
    let tableView = UITableView()
    let messageInputView = MessageInputView()
    var messages: [MessageRow] = []
    var messageInputViewHeightConstraint: NSLayoutConstraint?

    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    // MARK: - UI Setting functions
    private func setupUI() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = KWColor.lightG.withAlphaComponent(0.5)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.black, .font: UIFont.medium(size: 17) as Any]
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.compactAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        setupTableView()
        setupMessageInputView()
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(MessageTableViewCell.self, forCellReuseIdentifier: "MessageTableViewCell")
        tableView.separatorStyle = .none
        tableView.backgroundColor = KWColor.background
        tableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 200, right: 0)
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
        messageInputViewHeightConstraint = messageInputView.heightAnchor.constraint(equalToConstant: 180)
        NSLayoutConstraint.activate([
            messageInputView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            messageInputView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            messageInputView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            messageInputViewHeightConstraint!
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
    
    func dismissMessageView() {
        guard let heightConstraint = messageInputViewHeightConstraint else { return }
        heightConstraint.constant = 40
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func openMessageView() {
        guard let heightConstraint = messageInputViewHeightConstraint else { return }
        heightConstraint.constant = 180
        
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }
    
    func faqButtonTapped(message: String) {
        let newMessage = MessageRow(
            isInteractingWithChatGPT: false,
            sendText: message,
            responseText: nil,
            responseError: nil
        )
        messages.append(newMessage)
        
        let indexPath = IndexPath(row: messages.count - 1, section: 0)
        tableView.insertRows(at: [indexPath], with: .none)
        
        self.getResponse(sendMessage: message) { responses in
            let randomResponse = responses.shuffled()
            let response = randomResponse.first?.responseText
            
            DispatchQueue.main.async {
                if let response = response {
                    let updatedResponse = response.replacingOccurrences(of: "\\n", with: "\n")
                    self.messages[indexPath.row].responseText = updatedResponse
                }
                self.tableView.reloadRows(at: [indexPath], with: .none)
                self.tableView.scrollToRow(at: indexPath, at: .top, animated: false)
            }
        }
    }
    
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
    
    private func getResponse(sendMessage: String, completion: @escaping([MessageRow]) -> Void) {
        let queryOption = FirebaseManager.shared.database.queryByOneField(userID: "", collection: .faq, field: "send_message", fieldContent: sendMessage)
        
        FirebaseManager.shared.fetchData(from: .faq, queryOption: queryOption) { (result: Result<[FAQ], Error>) in
            switch result {
            case .success(let documents):
                var messages = [MessageRow]()
                for document in documents {
                    for response in document.responseMessage {
                        let message = MessageRow(
                            isInteractingWithChatGPT: false,
                            sendText: sendMessage,
                            responseText: response,
                            responseError: nil
                        )
                        messages.append(message)
                    }
                }
                completion(messages)
                print(messages)
            case .failure(let error):
                print("Error getting documents: \(error)")
                completion([])
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

}
