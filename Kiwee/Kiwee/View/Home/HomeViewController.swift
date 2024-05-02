//
//  HomeViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/19.
//

import UIKit

class HomeViewController: UIViewController {
    
    let context = StorageManager.shared.context
    var plantImageViews: [Int: UIImageView] = [:]
    var plantImageView: UIImageView?
    var addTime: Int = 0
    
    var pages: [UIViewController] = []
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var wateringImageView: UIImageView!
    @IBOutlet weak var plantButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFirstTimeOpeningApp() {
            setupGuideTour()
        }
//        setupBackground()
        scrollView.layer.cornerRadius = 10
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "f8f7f2")
        checkDataForToday()
        updateButtonAppearance()
        plantButton.layer.cornerRadius = 10
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
    
//    func setupBackground() {
//        let backgroundView = UIImageView()
//        backgroundView.image = UIImage(named: "Background")
//        view.addSubview(backgroundView)
//        view.sendSubviewToBack(backgroundView)
//        backgroundView.translatesAutoresizingMaskIntoConstraints = false
//        NSLayoutConstraint.activate([
//            backgroundView.topAnchor.constraint(equalTo: view.topAnchor),
//            backgroundView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            backgroundView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            backgroundView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//        ])
//    }
    
    @IBAction func plantButtonTapped (_ sender: UIButton) {
        updateButtonStatus(enabled: false)
        
        let selectionView = PlantSelectionView(frame: CGRect(x: 0, y: 0, width: 300, height: 280))
        selectionView.center = self.view.center
        selectionView.backgroundColor = .white
        selectionView.layer.cornerRadius = 10
        self.view.addSubview(selectionView)
        
        selectionView.onPlantSelected = { [weak self] imageName in
            guard let self = self else { return }
            self.addTime += 1
            
            let xPosition = scrollView.bounds.maxX / 2 - 25
            let yPosition = scrollView.bounds.maxY / 2 - 25
            
            // Use StorageManager to save to CoreData
            StorageManager.shared.savePlantImage(imageName: imageName, addTime: Int32(self.addTime), xPosition: xPosition, yPosition: yPosition)
            
            print("Selected plant name: \(imageName)")
            
            selectionView.removeFromSuperview()
            updateUIForSelectedPlant(imageName: imageName, addTime: addTime, xPosition: xPosition, yPosition: yPosition)
            
            UserDefaults.standard.set(Date(), forKey: "lastTappedDate")
            updateButtonAppearance()
        }
        
        selectionView.viewDismissed = { [weak self] in
            self?.updateButtonStatus(enabled: true)
        }
        
    }
    
    func updateUIForSelectedPlant(imageName: String, addTime: Int, xPosition: CGFloat, yPosition: CGFloat) {
        let imagePosition = CGPoint(x: xPosition, y: yPosition)
        let imageSize = CGSize(width: 50, height: 50)
        
        // Create a new UIImageView for each plant image
        let newPlantImageView = UIImageView(frame: CGRect(origin: imagePosition, size: imageSize))
        newPlantImageView.image = UIImage(named: imageName)
        newPlantImageView.alpha = 0
        scrollView.addSubview(newPlantImageView)
        
        // Add pan gesture recognizer to the newPlantImageView
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture(_:)))
        newPlantImageView.isUserInteractionEnabled = true
        newPlantImageView.addGestureRecognizer(panGesture)
        
        plantImageViews[addTime] = newPlantImageView
        
        // Animate with spring damping for a bounce effect
        newPlantImageView.transform = CGAffineTransform(translationX: 0, y: -20)
        UIView.animate(
            withDuration: 2.0,
            delay: 0,
            usingSpringWithDamping: 0.2,
            initialSpringVelocity: 0,
            options: [],
            animations: {
                newPlantImageView.alpha = 1.0
                newPlantImageView.transform = CGAffineTransform.identity // Return to original position
            },
            completion: nil)
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
            guard let addTime = plantImageViews.first(where: { $0.value == gestureView })?.key else { return }
            let xPosition = Double(gestureView.frame.origin.x)
            let yPosition = Double(gestureView.frame.origin.y)
            StorageManager.shared.updatePlantImagePosition(addTime: Int32(addTime), xPosition: xPosition, yPosition: yPosition)
        default:
            break
        }
    }
    
}

// MARK: - Handle button status

extension HomeViewController {
    
    func checkDataForToday() {
        FirestoreManager.shared.getIntakeCard(collectionID: "intake", chosenDate: Date()) { [weak self] foods, water in
            if !foods.isEmpty {
                self?.updateButtonStatus(enabled: true)
            } else {
                self?.updateButtonStatus(enabled: false)
            }
            
            if water != 0 {
                self?.updateImageStatus(enabled: true)
            } else {
                self?.updateImageStatus(enabled: false)
            }
        }
    }
    
    func updateButtonAppearance() {
        plantButton.backgroundColor = UIColor.hexStringToUIColor(hex: "004358")
        let calendar = Calendar.current
        let defaults = UserDefaults.standard
        
        if let lastTappedDate = defaults.object(forKey: "lastTappedDate") as? Date, calendar.isDateInToday(lastTappedDate) {
            plantButton.setTitle("今日已種菜", for: .normal)
            plantButton.setTitleColor(.white, for: .normal)
            updateButtonStatus(enabled: false)
        } else {
            // It's a different day or the button hasn't been tapped before, enable the button and set to default title
            plantButton.setTitle("開始種菜", for: .normal)
            plantButton.setTitleColor(.white, for: .normal)
            updateButtonStatus(enabled: true)
        }
    }
    
    func canButtonBeTapped() -> Bool {
        if let lastTappedDate = UserDefaults.standard.object(forKey: "lastTappedDate") as? Date {
            let calendar = Calendar.current
            if calendar.isDateInToday(lastTappedDate) {
                // It's the same day, button should not be enabled
                return false
            }
        }
        // Either the button hasn't been tapped before, or it was tapped on a different day
        return true
    }
    
    func updateButtonStatus(enabled: Bool) {
        let canTap = canButtonBeTapped()
        plantButton.isEnabled = enabled && canTap
        plantButton.backgroundColor = (enabled && canTap) ? plantButton.backgroundColor?.withAlphaComponent(1.0) : plantButton.backgroundColor?.withAlphaComponent(0.5)
    }
    
    func updateImageStatus(enabled: Bool) {
        wateringImageView.isUserInteractionEnabled = enabled
        wateringImageView.alpha = enabled ? 1.0 : 0.7
        if enabled {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(wateringImageTapped(_:)))
            wateringImageView.addGestureRecognizer(tapGesture)
        } else {
            wateringImageView.gestureRecognizers?.forEach(wateringImageView.removeGestureRecognizer)
        }
    }
    
    @objc private func wateringImageTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        guard let _ = gestureRecognizer.view as? UIImageView else { return }
        
        // Calculate the center of the visible area of the scrollView
        let scrollViewCenterX = scrollView.contentOffset.x + (scrollView.bounds.width / 2)
        let scrollViewCenterY = scrollView.contentOffset.y + (scrollView.bounds.height / 2)
        
        let splashImageView = UIImageView(frame: CGRect(x: scrollViewCenterX - 100, y: scrollViewCenterY - 100, width: 200, height: 200))
        self.scrollView.addSubview(splashImageView)
        
        var splashImages: [UIImage] = []
        for index in 1...9 {
            if let img = UIImage(named: "splash\(index)") {
                splashImages.append(img)
            }
        }
        
        splashImageView.animationImages = splashImages
        splashImageView.animationDuration = 1.0
        splashImageView.startAnimating()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + splashImageView.animationDuration - 0.1) {
            splashImageView.removeFromSuperview()
        }
    }
    
}

// MARK: - Pages for guide

extension HomeViewController {
        
    func isFirstTimeOpeningApp() -> Bool {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if hasLaunchedBefore {
            return false
        } else {
//            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
            return true
        }
    }
    
    func setupGuideTour() {
        let containerView = UIView()
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 10
        containerView.layer.masksToBounds = true
        self.view.addSubview(containerView)
        
        containerView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            containerView.widthAnchor.constraint(equalToConstant: 300),
            containerView.heightAnchor.constraint(equalToConstant: 400)
        ])
        
        let guideVC = GuideViewController()
        addChild(guideVC)
        containerView.addSubview(guideVC.view)

        guideVC.view.frame = containerView.bounds
        guideVC.didMove(toParent: self)
        
        guideVC.startbuttonTapped = {
            containerView.removeFromSuperview()
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
}
