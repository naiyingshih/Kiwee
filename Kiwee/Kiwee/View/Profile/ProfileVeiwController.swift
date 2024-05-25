//
//  ProfileVeiwController.swift
//  Kiwee
//
//  Created by NY on 2024/4/18.
//

import UIKit
import Combine

class ProfileVeiwController: UIViewController {
    
    let viewModel = SignInWithAppleViewModel()
    let profileViewModel = ProfileViewModel()
    private var cancellables = Set<AnyCancellable>()
    
    @IBOutlet weak var bannerView: ProfileBannerView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        profileViewModel.fetchUserData()
        profileViewModel.fetchPostData()
        setupBindings()
        bannerView.delegate = self
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: "ProfileCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let margin: CGFloat = 16
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tabBarController?.tabBar.isHidden = false
    }
    
    // MARK: - Fetch data functions
    func setupBindings() {
        profileViewModel.$userData
            .receive(on: DispatchQueue.main)
            .sink { [weak self] userData in
                if let userData = userData {
                    self?.bannerView.updateView(with: userData)
                }
            }
            .store(in: &cancellables)
        
        profileViewModel.$posts
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.collectionView.reloadData()
            }
            .store(in: &cancellables)
    }
}

// MARK: - collectionDataSource and Delegate
 extension ProfileVeiwController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
     
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return profileViewModel.posts.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ProfileCell.self),
            for: indexPath
        )
        guard let profileCell = cell as? ProfileCell else { return cell }
        let postResult = profileViewModel.posts[indexPath.item]
        profileCell.updatePostResult(postResult)
        return profileCell
    }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         let numberOfColumns: CGFloat = 2
         let width = (collectionView.bounds.width - (16 * (numberOfColumns + 1))) / numberOfColumns
         return CGSize(width: width, height: 200)
     }
     
 }

// MARK: - collectionViewDelegate
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
    
    private func editItem(at index: Int) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let postVC = storyboard.instantiateViewController(
            withIdentifier: String(describing: PostViewController.self)
        ) as? PostViewController else { return }
        
        let foodName = profileViewModel.posts[index].foodName
        let buttonTag = profileViewModel.posts[index].tag
        let image = profileViewModel.posts[index].image
        
        postVC.editingPostID = profileViewModel.posts[index].documentID
        postVC.postState = .editingPost(initialFoodText: foodName, initialSelectedButtonTag: buttonTag, initialImage: image)
        
        postVC.modalPresentationStyle = .popover
        self.present(postVC, animated: true)
    }
    
    private func deleteItem(at index: Int) {
        profileViewModel.deletePost(at: index)
    }
    
}

// MARK: - ProfileBanneViewDelegate

extension ProfileVeiwController: ProfileBanneViewDelegate {
        
    func presentManageVC() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let manageVC = storyboard.instantiateViewController(
            withIdentifier: String(describing: RecordManageViewController.self)
        ) as? RecordManageViewController else { return }
        manageVC.initialUserData = self.profileViewModel.userData
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
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        if let helperVC = storyboard.instantiateViewController(withIdentifier: "HelperViewController") as? HelperViewController {
            helperVC.modalPresentationStyle = .popover
            self.present(helperVC, animated: true)
            print("present help page")
        }
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
        Task {
            if await viewModel.deleteAccount() == true {
                print("Account deleted successfully")
                // Move back to the Signin page and post notification only after successful deletion
                DispatchQueue.main.async {
                    self.backtoSigninPage(notificationName: .accountDeletionSuccess)
                }
                profileViewModel.updateAccountStatus()
                UserDefaults.standard.set(false, forKey: "hasLaunchedBefore")
            } else {
                print("Failed to delete account")
            }
        }
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
