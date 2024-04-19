//
//  HomeViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/19.
//

import UIKit

class HomeViewController: UIViewController {
    
    var plants: UIButton?
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wateringImageView: UIImageView!
    @IBOutlet weak var plantButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkDataForToday()
    }
    
    func checkDataForToday() {
        FirestoreManager.shared.getIntakeCard(collectionID: "intake",
                                              chosenDate: Date()
        ) { [weak self] foods, water in
            if !foods.isEmpty {
                self?.updateButtonStatus()
            }
            if water != 0 {
                self?.updateImageStatus()
            }
            if foods.isEmpty && water == 0 {
                self?.setInitialUI()
            }
        }
    }
    
    @IBAction func plantButtonTapped (_ sender: Any) {
        let selectionView = PlantSelectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 280))
        selectionView.center = self.view.center
        selectionView.backgroundColor = .white
        selectionView.layer.cornerRadius = 10
        
        selectionView.confirmButtonAction = { [weak self] in
            
            selectionView.removeFromSuperview()
        }
        
        selectionView.onPlantSelected = { [weak self] selectedPlantTag in
            // Handle the selected plant here
            // For example, update the UI to show the selected plant
            print("Selected plant tag: \(selectedPlantTag)")
            // You might want to store the selectedPlantTag or directly update the UI based on this tag
        }
        
        self.view.addSubview(selectionView)
    }
    
    @objc private func wateringImageTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        
        guard let tappedButtonView = gestureRecognizer.view else { return }
//        guard let delegate = delegate else { return }
//        if let shouldSelect = delegate.shouldSelectedButton?(self, at: newIndex), !shouldSelect {
//            return
//        }
//        
//        let indicatorWidth = bounds.width / CGFloat(optionsButtonViews.count)
//        let indicatorX = CGFloat(selectedIndex) * indicatorWidth
//        UIView.animate(withDuration: 0.3) {
//            self.indicatorView.frame.origin.x = indicatorX
//        }
//        
//        delegate.didSelectedButton?(self, at: newIndex)
    }
    
}

// MARK: - Handle button status

extension HomeViewController {
    
    func setInitialUI() {
        plantButton.isEnabled = false
        plantButton.alpha = 0.7
        wateringImageView.alpha = 0.7
    }
    
    func updateButtonStatus() {
        plantButton.isEnabled = true
        plantButton.alpha = 1.0
    }
    
    func updateImageStatus() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(wateringImageTapped(_:)))
        wateringImageView.addGestureRecognizer(tapGesture)
        wateringImageView.alpha = 1.0
    }
}
