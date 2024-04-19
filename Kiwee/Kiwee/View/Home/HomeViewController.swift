//
//  HomeViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/19.
//

import UIKit

class HomeViewController: UIViewController {
    
    let context = StorageManager.shared.context
    var plantImageView: UIImageView?
    var addTime: Int = 0
    
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
        
        addTime = StorageManager.shared.fetchLatestAddTime()
        
        let plantImages = StorageManager.shared.fetchPlantImages()
            for plantImage in plantImages {
                if let imageName = plantImage.imageName {
                    let addTime = Int(plantImage.addTime)
                    let xPosition = CGFloat(plantImage.xPosition)
                    let yPosition = CGFloat(plantImage.yPosition)
                    updateUIForSelectedPlant(imageName: imageName, addTime: addTime, xPosition: xPosition, yPosition: yPosition)
                }
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
            guard let self = self else { return }
            self.addTime += 1
            
            // Calculate xPosition and yPosition based on addTime
            let row = (self.addTime - 1) / 24
            let column = (self.addTime - 1) % 24
            let xPosition = Double(6 + column * 60)
            let yPosition = Double(6 + row * 60)
            
            // Use StorageManager to save to CoreData
            StorageManager.shared.savePlantImage(imageName: imageName, addTime: Int32(self.addTime), xPosition: xPosition, yPosition: yPosition)
            
            print("Selected plant tag: \(selectedPlantTag), name: \(imageName)")
            selectionView.removeFromSuperview()
            updateUIForSelectedPlant(imageName: imageName, addTime: addTime, xPosition: xPosition, yPosition: yPosition)
        }
    }
    
    func updateUIForSelectedPlant(imageName: String, addTime: Int, xPosition: CGFloat, yPosition: CGFloat) {
        let imagePosition = CGPoint(x: xPosition, y: yPosition)
        let imageSize = CGSize(width: 50, height: 50)
        
        // Create a new UIImageView for each plant image
        let newPlantImageView = UIImageView(frame: CGRect(origin: imagePosition, size: imageSize))
        newPlantImageView.image = UIImage(named: imageName)
        scrollView.addSubview(newPlantImageView)
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
