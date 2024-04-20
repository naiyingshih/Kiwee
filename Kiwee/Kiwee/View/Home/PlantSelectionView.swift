//
//  PlantSelectionView.swift
//  Kiwee
//
//  Created by NY on 2024/4/19.
//

import UIKit

class PlantSelectionView: UIView {
    
    var selectedIconButton: UIButton?
    var shuffledImageNames: [String] = []
    var onPlantSelected: ((/*Int,*/ String) -> Void)?
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "今天想種什麼呢？"
        label.textColor = UIColor.hexStringToUIColor(hex: "004358")
        label.font = UIFont.systemFont(ofSize: 18)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        button.addTarget(self, action: #selector(close), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var iconButton1: UIButton = {
        let button = UIButton()
        button.tag = 0
        button.setImage(UIImage(named: shuffledImageNames[0]), for: .normal)
        button.addTarget(self, action: #selector(selectPlant(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var iconButton2: UIButton = {
        let button = UIButton()
        button.tag = 1
        button.setImage(UIImage(named: shuffledImageNames[1]), for: .normal)
        button.addTarget(self, action: #selector(selectPlant(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var iconButton3: UIButton = {
        let button = UIButton()
        button.tag = 2
        button.setImage(UIImage(named: shuffledImageNames[2]), for: .normal)
        button.addTarget(self, action: #selector(selectPlant(_:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("加入農場", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.hexStringToUIColor(hex: "004358")
        button.addTarget(self, action: #selector(plantInFarm), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    private func setupView() {
        setRandomImagesForButtons()
        addSubview(titleLabel)
        addSubview(closeButton)
        addSubview(iconButton1)
        addSubview(iconButton2)
        addSubview(iconButton3)
        addSubview(confirmButton)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            
            titleLabel.topAnchor.constraint(equalTo: closeButton.bottomAnchor, constant: 12),
            titleLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            
            iconButton2.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 24),
            iconButton2.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            iconButton2.widthAnchor.constraint(equalToConstant: 60),
            iconButton2.heightAnchor.constraint(equalToConstant: 60),
            
            iconButton1.topAnchor.constraint(equalTo: iconButton2.topAnchor),
            iconButton1.trailingAnchor.constraint(equalTo: iconButton2.leadingAnchor, constant: -30),
            iconButton1.widthAnchor.constraint(equalToConstant: 60),
            iconButton1.heightAnchor.constraint(equalToConstant: 60),
            
            iconButton3.topAnchor.constraint(equalTo: iconButton2.topAnchor),
            iconButton3.leadingAnchor.constraint(equalTo: iconButton2.trailingAnchor, constant: 30),
            iconButton3.widthAnchor.constraint(equalToConstant: 60),
            iconButton3.heightAnchor.constraint(equalToConstant: 60),
            
            confirmButton.topAnchor.constraint(equalTo: iconButton2.bottomAnchor, constant: 40),
            confirmButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            confirmButton.widthAnchor.constraint(equalToConstant: 120)
        ])
    }
    
    func setRandomImagesForButtons() {
        var imageNames = ["apple", "corn", "ebifry", "eggplant", "frenchfries", "grape", "hamburger", "icecream", "lemon", "lettuce", "mushroom", "peach", "pineapple", "sweetpotato", "vegetable"]
        
        guard imageNames.count >= 3 else {
            print("Not enough unique images available.")
            return
        }
        // Shuffle the array to randomize the order
        imageNames.shuffle()
        shuffledImageNames = imageNames
    }
    
    @objc func close() {
        self.removeFromSuperview()
    }
    
    @objc func selectPlant(_ sender: UIButton) {
        let selectedPlant = sender.tag
        print("===\(selectedPlant)")
        
        if let previousSelectedButton = selectedIconButton {
            previousSelectedButton.layer.borderWidth = 0
        }
    
        sender.layer.borderWidth = 1
        sender.layer.cornerRadius = 8
        sender.layer.borderColor = UIColor.hexStringToUIColor(hex: "004358").cgColor
        
        selectedIconButton = sender
    }
    
    @objc func plantInFarm() {
        if let selectedPlantTag = selectedIconButton?.tag {
            let imageName = determineImageNameForTag(selectedPlantTag)
            onPlantSelected?(/*selectedPlantTag,*/ imageName)
        }
    }
    
    func determineImageNameForTag(_ tag: Int) -> String {
        if tag >= 0 && tag <= shuffledImageNames.count {
            return shuffledImageNames[tag]
        } else {
            return "DefaultImage"
        }
    }
    
}
