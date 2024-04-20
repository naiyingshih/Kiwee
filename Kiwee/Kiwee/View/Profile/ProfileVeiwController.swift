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
    
    @IBOutlet weak var bannerView: ProfileBannerView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchUserData()
        bannerView.delegate = self
        collectionView.register(ProfileCell.self, forCellWithReuseIdentifier: "ProfileCell")
        collectionView.dataSource = self
        collectionView.delegate = self
        
        let margin: CGFloat = 30
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.minimumInteritemSpacing = margin / 2
        flowLayout.minimumLineSpacing = margin / 2
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

}

// MARK: - collection view

 extension ProfileVeiwController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
     
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: ProfileCell.self),
            for: indexPath
        )
        guard let profileCell = cell as? ProfileCell else { return cell }
        return profileCell
    }
     
     func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
         let width = collectionView.bounds.width / 2.5
         return CGSize(width: width, height: 200)
     }
    
 }

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
    
    func presentCameraVC() {
        let cameraVC = CameraViewController()
        self.navigationController?.pushViewController(cameraVC, animated: false)
    }
    
}
