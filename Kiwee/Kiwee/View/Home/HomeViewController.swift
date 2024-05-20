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
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        if isFirstTimeOpeningApp() {
            setupGuideTour()
        }
        setupBackgroundUI()
        setupPlantImageView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        checkDataForToday()
    }
    
    // MARK: - UI setting functions
    private func setupBackgroundUI() {
        view.backgroundColor = KWColor.background
        scrollView.layer.cornerRadius = 10
        updateButtonAppearance()
    }
    
    private func setupPlantImageView() {
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
    
    private func updateUIForSelectedPlant(imageName: String, addTime: Int, xPosition: CGFloat, yPosition: CGFloat) {
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
    
    // MARK: - Actions
    
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

// MARK: - Handle button status functions

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
    
    private func updateButtonAppearance() {
        let calendar = Calendar.current
        let defaults = UserDefaults.standard
        
        if let lastTappedDate = defaults.object(forKey: "lastTappedDate") as? Date, calendar.isDateInToday(lastTappedDate) {
            plantButton.setTitle("今日已種菜", for: .normal)
            plantButton.applyPrimaryStyle(size: 17)
            updateButtonStatus(enabled: false)
        } else {
            // It's a different day or the button hasn't been tapped before, enable the button and set to default title
            plantButton.setTitle("開始種菜", for: .normal)
            plantButton.applyPrimaryStyle(size: 17)
            updateButtonStatus(enabled: true)
        }
    }
    
    private func canButtonBeTapped() -> Bool {
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
    
    private func updateButtonStatus(enabled: Bool) {
        let canTap = canButtonBeTapped()
        ButtonManager.updateButtonEnableStatus(for: plantButton, enabled: enabled && canTap)
    }
    
    private func updateImageStatus(enabled: Bool) {
        wateringImageView.isUserInteractionEnabled = enabled
        wateringImageView.alpha = enabled ? 1.0 : 0.3
        if enabled {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(wateringImageTapped(_:)))
            wateringImageView.addGestureRecognizer(tapGesture)
        } else {
            wateringImageView.gestureRecognizers?.forEach(wateringImageView.removeGestureRecognizer)
        }
    }
    
}

// MARK: - Pages for guide

extension HomeViewController {
        
    private func isFirstTimeOpeningApp() -> Bool {
        let hasLaunchedBefore = UserDefaults.standard.bool(forKey: "hasLaunchedBefore")
        if hasLaunchedBefore {
            return false
        } else {
            return true
        }
    }
    
    private func setupGuideTour() {
        // Semi-transparent background view
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        backgroundView.frame = self.view.bounds
        self.view.addSubview(backgroundView)
        
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
            backgroundView.removeFromSuperview()
            UserDefaults.standard.set(true, forKey: "hasLaunchedBefore")
        }
    }
    
}
