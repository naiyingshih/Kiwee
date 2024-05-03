//
//  ProfileVeiwController.swift
//  Kiwee
//
//  Created by NY on 2024/4/18.
//

import UIKit

class ProfileVeiwController: UIViewController {
    
    var viewModel = SignInWithAppleViewModel()
    
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

extension ProfileVeiwController: ProfileBanneViewDelegate {
        
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
        backtoSigninPage(notificationName: .logoutSuccess)
        viewModel.signOut()
    }
    
    func removeAccount() {
        let alertController = UIAlertController(title: "確定要刪除帳戶嗎？", message: "刪除帳戶後，您所有的紀錄將會刪除且無法復原！\n若想暫停使用，可以先選擇登出！", preferredStyle: .alert)
        
        let deleteAction = UIAlertAction(title: "確定刪除", style: .destructive) { [weak self] _ in
            self?.deleteAccount()
        }
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    private func deleteAccount() {
        backtoSigninPage(notificationName: .accountDeletionSuccess)
        Task {
            if await viewModel.deleteAccount() == true {
                print("deleteAccount!!!")
            }
        }
        FirestoreManager.shared.updateAccountStatus()
        UserDefaults.standard.set(false, forKey: "hasLaunchedBefore")
    }
    
    private func backtoSigninPage(notificationName: Notification.Name) {
        let storyboard = UIStoryboard(name: "Login", bundle: nil)
        if let signinVC = storyboard.instantiateViewController(withIdentifier: "SigninViewController") as? SigninViewController {
            signinVC.modalPresentationStyle = .fullScreen
            self.present(signinVC, animated: false) {
                NotificationCenter.default.post(name: notificationName, object: nil)
            }
        }
    }
    
}

// MARK: - Notification

extension Notification.Name {
    static let logoutSuccess = Notification.Name("logoutSuccess")
    static let accountDeletionSuccess = Notification.Name("accountDeletionSuccess")
}
