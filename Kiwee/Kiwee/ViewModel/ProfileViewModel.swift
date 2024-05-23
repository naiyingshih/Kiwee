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
        
        firebaseManager.fetchData(from: .users, queryOption: query) { [weak self] (result: Result<[UserData], Error>) in
            guard self != nil else { return }
            switch result {
            case .success(let userdata):
                let userdata = userdata.first
                guard let userData = userdata else { return }
                DispatchQueue.main.async {
                    self?.userData = userData
                    UserDefaults.standard.set(userData.updatedWeight, forKey: "initial_weight")
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
        guard let documentID = post.documentID else { return }
        
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
        firebaseManager.setAccountDeletedStatus()
    }
    
}
