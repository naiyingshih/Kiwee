//
//  ProfileViewModel.swift
//  Kiwee
//
//  Created by NY on 2024/5/23.
//

import Foundation

class ProfileViewModel {
    
    let firebaseManager = FirebaseManager.shared
    
    @Published var userData: UserData?
    @Published var posts: [Post] = []
    
    func fetchUserData() {
        guard let userID = firebaseManager.userID else { return }
        let query = firebaseManager.database.queryByOneField(userID: userID, collection: .users, field: "id", fieldContent: userID)
        
        firebaseManager.listenerRegistration = firebaseManager.addSnapshotListener(for: .users, queryOption: query) { [weak self] (result: Result<[UserData], Error>) in
            guard self != nil else { return }
            switch result {
            case .success(let userdata):
                let userdata = userdata.first
                guard let userData = userdata else { return }
                DispatchQueue.main.async {
                    self?.userData = userData
                }
            case .failure(let error):
                print("Error fetching calories: \(error.localizedDescription)")
            }
        }
    }
    
    func fetchPostData() {
        let query = firebaseManager.database.queryForPosts(userID: firebaseManager.userID ?? "")
        
        firebaseManager.listenerRegistration = firebaseManager.addSnapshotListener(for: .posts, queryOption: query) { [weak self] (result: Result<[Post], Error>) in
            switch result {
            case .success(let posts):
                DispatchQueue.main.async {
                    self?.posts = posts.reversed()
                }
            case .failure(let error):
                print("Error fetching posts: \(error.localizedDescription)")
            }
        }
    }
    
    func deletePost(at index: Int) {
        guard index >= 0 && index < posts.count else { return }
        let post = posts[index]
        let documentID = post.documentID
        
        firebaseManager.deleteData(from: .posts, documentID: documentID) { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    print("Document successfully removed!")
                case .failure(let error):
                    print("Error removing document: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func updateAccountStatus() {
        guard let userID = firebaseManager.userID else { return }
        firebaseManager.updatePartialUserData(userID: userID, updates: ["status": "delete"]) { success in
            if success {
                print("Account status updated successfully")
            } else {
                print("Failed to update account status")
            }
        }
    }
    
}
