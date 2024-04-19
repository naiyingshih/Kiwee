//
//  HomeViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/19.
//

import UIKit

class HomeViewController: UIViewController {
    
    var plantImageView: UIImageView?
    var addTime = -1
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wateringImageView: UIImageView!
    @IBOutlet weak var plantButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkDataForToday()
        
        plantImageView = UIImageView()
        if let plantImageView = plantImageView {
            scrollView.addSubview(plantImageView)
        }
    }
    
    func checkDataForToday() {
        FirestoreManager.shared.getIntakeCard(
            collectionID: "intake",
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
        self.view.addSubview(selectionView)
        
        selectionView.onPlantSelected = { [weak self] (selectedPlantTag, imageName) in
            self?.addTime += 1
            self?.updateUIForSelectedPlant(withTag: selectedPlantTag, imageName: imageName, addTime: self?.addTime ?? 0)
            print("Selected plant tag: \(selectedPlantTag), name: \(imageName)")
            selectionView.removeFromSuperview()
        }
    }
    
//    func updateUIForSelectedPlant(withTag tag: Int, imageName: String) {
//        
//        let imagePosition = CGPoint(x: 0, y: 0)
//        let imageSize = CGSize(width: 50, height: 50)
//        
//        plantImageView?.frame = CGRect(origin: imagePosition, size: imageSize)
//        plantImageView?.image = UIImage(named: imageName)
//    }
    
    func updateUIForSelectedPlant(withTag tag: Int, imageName: String, addTime: Int) {
        let row = addTime / 24
        let column = addTime % 24
        
        // Calculate the x and y positions based on the row and column
        let xPosition = CGFloat(6 + column * 60)
        let yPosition = CGFloat(6 + row * 60)
        
        let imagePosition = CGPoint(x: xPosition, y: yPosition)
        let imageSize = CGSize(width: 50, height: 50)

        plantImageView?.frame = CGRect(origin: imagePosition, size: imageSize)
        plantImageView?.image = UIImage(named: imageName)
    }
    
    @objc private func wateringImageTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        
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
