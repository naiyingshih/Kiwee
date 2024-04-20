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
                    let tag = Int(plantImage.tag)
                    let addTime = Int(plantImage.addTime)
                    let xPosition = CGFloat(plantImage.xPosition)
                    let yPosition = CGFloat(plantImage.yPosition)
                    updateUIForSelectedPlant(imageName: imageName, addTime: addTime, xPosition: xPosition, yPosition: yPosition, tag: tag)
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
            let xPosition = scrollView.bounds.minX
            let yPosition = scrollView.bounds.minY
            
            // Use StorageManager to save to CoreData
            StorageManager.shared.savePlantImage(imageName: imageName, addTime: Int32(self.addTime), xPosition: xPosition, yPosition: yPosition)
            
            print("Selected plant tag: \(selectedPlantTag), name: \(imageName)")
            
            selectionView.removeFromSuperview()
            updateUIForSelectedPlant(imageName: imageName, addTime: addTime, xPosition: xPosition, yPosition: yPosition, tag: selectedPlantTag)
        }
    }
    
    func updateUIForSelectedPlant(imageName: String, addTime: Int, xPosition: CGFloat, yPosition: CGFloat, tag: Int) {
        let imagePosition = CGPoint(x: xPosition, y: yPosition)
        let imageSize = CGSize(width: 50, height: 50)
        
        // Create a new UIImageView for each plant image
        let newPlantImageView = UIImageView(frame: CGRect(origin: imagePosition, size: imageSize))
        newPlantImageView.image = UIImage(named: imageName)
        newPlantImageView.tag = tag
        scrollView.addSubview(newPlantImageView)
        
        // Add pan gesture recognizer to the newPlantImageView
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        newPlantImageView.isUserInteractionEnabled = true
        newPlantImageView.addGestureRecognizer(panGesture)
        
        UIView.animate(withDuration: 0.5) {
            // Calculate the center position of the view
            let centerX = self.view.bounds.midX
            let centerY = self.view.bounds.midY

            // Calculate the new origin for newPlantImageView to be centered
            let newOriginX = centerX - (newPlantImageView.frame.width / 2)
            let newOriginY = centerY - (newPlantImageView.frame.height / 2)

            // Update the frame of newPlantImageView to move it to the center
            newPlantImageView.frame.origin = CGPoint(x: newOriginX, y: newOriginY)
        }
    }
    
    @objc private func handlePanGesture(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: self.view)
        guard let gestureView = gesture.view else { return }
        
        switch gesture.state {
        case .changed:
            let newPosition = CGPoint(x: gestureView.center.x + translation.x, y: gestureView.center.y + translation.y)
            gestureView.center = newPosition
            gesture.setTranslation(.zero, in: self.view)
        case .ended:
            // Save the new position to CoreData
            let xPosition = Double(gestureView.frame.origin.x)
            let yPosition = Double(gestureView.frame.origin.y)
            StorageManager.shared.updatePlantImagePosition(tag: Int32(gestureView.tag), xPosition: xPosition, yPosition: yPosition)
        default:
            break
        }
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
    
    @objc private func wateringImageTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        
    }
}
