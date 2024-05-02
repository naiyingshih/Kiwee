//
//  ProfileVeiwController.swift
//  Kiwee
//
//  Created by NY on 2024/4/18.
//

import UIKit
import FirebaseAuth
import CryptoKit
import AuthenticationServices

class ProfileVeiwController: UIViewController {
    
    var user = Auth.auth().currentUser
    
    var userData: UserData? {
        didSet {
            if let userData = userData {
                bannerView.updateView(with: userData)
            }
        }
    }
    
    var posts: [Post] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var bannerView: ProfileBannerView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserData()
        fetchPost()
        bannerView.delegate = self
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: "ProfileCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let margin: CGFloat = 16
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: 0, left: margin, bottom: margin, right: margin)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    func fetchUserData() {
        FirestoreManager.shared.getUserData { [weak self] userData in
            DispatchQueue.main.async {
                self?.userData = userData
            }
        }
    }
    
    func fetchPost() {
        FirestoreManager.shared.getPostData { [weak self] posts in
            DispatchQueue.main.async {
                self?.posts = posts
            }
        }
    }

}

// MARK: - collectionDataSource and Delegate

 extension ProfileVeiwController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
     
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ProfileCell.self),
            for: indexPath
        )
        guard let profileCell = cell as? ProfileCell else { return cell }
        let postResult = posts[indexPath.item]
        profileCell.updatePostResult(postResult)
        return profileCell
    }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         let numberOfColumns: CGFloat = 2
         let width = (collectionView.bounds.width - (16 * (numberOfColumns + 1))) / numberOfColumns
         return CGSize(width: width, height: 200)
     }
     
 }

extension ProfileVeiwController: UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        configureContextMenu(index: indexPath.row)
    }
    
    func configureContextMenu(index: Int) -> UIContextMenuConfiguration {
        let context = UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ -> UIMenu? in
            
            let edit = UIAction(title: "編輯", image: UIImage(systemName: "square.and.pencil"), identifier: nil, discoverabilityTitle: nil, state: .off) { (_) in
                print("edit button clicked")
                self.editItem(at: index)
            }
            let delete = UIAction(title: "刪除", image: UIImage(systemName: "trash"), identifier: nil, discoverabilityTitle: nil, attributes: .destructive, state: .off) { (_) in
                print("delete button clicked")
                self.deleteItem(at: index)
            }
            
            return UIMenu(title: "選擇執行動作", image: nil, identifier: nil, options: UIMenu.Options.displayInline, children: [edit,delete])
            
        }
        return context
    }
    
    func editItem(at index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let postVC = storyboard.instantiateViewController(
            withIdentifier: String(describing: PostViewController.self)
        ) as? PostViewController else { return }
        
        let foodName = posts[index].foodName
        let buttonTag = posts[index].tag
        let image = posts[index].image
        
        postVC.editingPostID = posts[index].documenID
        postVC.postState = .editingPost(initialFoodText: foodName, initialSelectedButtonTag: buttonTag, initialImage: image)
        
        postVC.modalPresentationStyle = .popover
        self.present(postVC, animated: true)
    }
    
    func deleteItem(at index: Int) {
        let post = posts[index]
        let documentID = post.documenID
        
        FirestoreManager.shared.deleteDocument(collectionID: "posts", documentID: documentID) { success in
            DispatchQueue.main.async {
                if success {
                    print("Document successfully removed!")
                    self.collectionView.reloadData()
                } else {
                    print("Error removing document")
                }
            }
        }
    }
    
}

// MARK: - ProfileBanneViewDelegate

extension ProfileVeiwController: ProfileBanneViewDelegate, ASAuthorizationControllerDelegate {
        
    func presentManageVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let manageVC = storyboard.instantiateViewController(
            withIdentifier: String(describing: RecordManageViewController.self)
        ) as? RecordManageViewController else { return }
        manageVC.initialUserData = self.userData
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(manageVC, animated: true)
    }
    
    func presentPostVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let postVC = storyboard.instantiateViewController(
            withIdentifier: String(describing: PostViewController.self)
        ) as? PostViewController else { return }
        postVC.modalPresentationStyle = .popover
        postVC.postState = .newPost
        self.present(postVC, animated: true)
    }
    
    func presentHelpPage() {
        print("present help page")
    }
    
    func logoutAccount() {
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    func removeAccount() {
        
//        user?.delete { error in
//          if let error = error {
//              print("account remove failed:\(error)")
//          } else {
//              print("account deleted")
//            // Account deleted.
//          }
//        }
    }
    
    func authorizationController(controller: ASAuthorizationController,
                                 didCompleteWithAuthorization authorization: ASAuthorization) {
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential
        else {
            print("Unable to retrieve AppleIDCredential")
            return
        }
        
        let signinVC = SignInViewController()
        guard let _ = signinVC.currentNonce else {
            fatalError("Invalid state: A login callback was received, but no login request was sent.")
        }
        
        guard let appleAuthCode = appleIDCredential.authorizationCode else {
            print("Unable to fetch authorization code")
            return
        }
        
        guard let authCodeString = String(data: appleAuthCode, encoding: .utf8) else {
            print("Unable to serialize auth code string from data: \(appleAuthCode.debugDescription)")
            return
        }
        
        Task {
            do {
                try await Auth.auth().revokeToken(withAuthorizationCode: authCodeString)
                try await user?.delete()
                //          self.updateUI()
            } catch {
                //          self.displayError(error)
            }
        }
    }

}
