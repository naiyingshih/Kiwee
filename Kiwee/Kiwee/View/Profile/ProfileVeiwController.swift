//
//  ProfileVeiwController.swift
//  Kiwee
//
//  Created by NY on 2024/4/18.
//

import UIKit

class ProfileVeiwController: UIViewController {
    
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
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPressGesture))
        collectionView.addGestureRecognizer(longPressGesture)
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

// MARK: - collection view

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
     
//     func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//         <#code#>
//     }
    
 }

// MARK: - Delegate

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
    
}

// MARK: - Handle post editing

extension ProfileVeiwController {
    
    @objc func handleLongPressGesture(gesture: UILongPressGestureRecognizer) {
        if gesture.state != .began {
            return
        }
        
        let point = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: point) {
            // Present options to the user
            let alertController = UIAlertController(title: nil, message: "選擇執行動作", preferredStyle: .alert)
            
            // Edit action
            let editAction = UIAlertAction(title: "編輯", style: .default) { _ in
                self.editItem(at: indexPath)
            }
            alertController.addAction(editAction)
            
            // Delete action
            let deleteAction = UIAlertAction(title: "刪除", style: .destructive) { _ in
                // Handle delete action
                self.deleteItem(at: indexPath)
            }
            alertController.addAction(deleteAction)
            
            // Cancel action
            let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
            alertController.addAction(cancelAction)
            
            present(alertController, animated: true, completion: nil)
        }
    }
    
    func editItem(at indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        guard let postVC = storyboard.instantiateViewController(
            withIdentifier: String(describing: PostViewController.self)
        ) as? PostViewController else { return }
        
        let foodName = posts[indexPath.row].foodName
        let buttonTag = posts[indexPath.row].tag
        let image = posts[indexPath.row].image

        postVC.editingPostID = posts[indexPath.row].documenID
        postVC.postState = .editingPost(initialFoodText: foodName, initialSelectedButtonTag: buttonTag, initialImage: image)
        
        postVC.modalPresentationStyle = .popover
        self.present(postVC, animated: true)
    }

    func deleteItem(at indexPath: IndexPath) {
        let post = posts[indexPath.row]
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
