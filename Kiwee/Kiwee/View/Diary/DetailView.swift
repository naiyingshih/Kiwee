//
//  DetailView.swift
//  Kiwee
//
//  Created by NY on 2024/4/24.
//

import UIKit

class DetailView: UIView {
    
    lazy var foodImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Food_Placeholder")
        imageView.clipsToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
//        label.text = "食物名稱"
        label.textColor = .black
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var totalCalorieLabel: UILabel = {
        let label = UILabel()
//        label.text = "kcal"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var dividingLine: UIView = {
        let line = UIView()
        line.backgroundColor = .gray
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    lazy var carboLabel: UILabel = {
        let label = UILabel()
//        label.text = "碳水\ng"
        label.numberOfLines = 0
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var proteinLabel: UILabel = {
        let label = UILabel()
//        label.text = "蛋白\ng"
        label.numberOfLines = 0
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var fatLabel: UILabel = {
        let label = UILabel()
//        label.text = "脂肪\ng"
        label.numberOfLines = 0
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var fiberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
//        label.text = "纖維\ng"
        label.numberOfLines = 0
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var quantityLabel: UILabel = {
        let label = UILabel()
//        label.text = "攝取量\ng"
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        addSubview(foodImageView)
        addSubview(nameLabel)
        addSubview(totalCalorieLabel)
        addSubview(dividingLine)
        addSubview(carboLabel)
        addSubview(proteinLabel)
        addSubview(fatLabel)
        addSubview(fiberLabel)
        addSubview(quantityLabel)
        setupConstraint()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        self.addGestureRecognizer(tapGesture)
    }
    
    private func setupConstraint() {
        NSLayoutConstraint.activate([
            foodImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor, constant: -24),
            foodImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            foodImageView.heightAnchor.constraint(equalTo: self.heightAnchor, multiplier: 0.4),
            foodImageView.widthAnchor.constraint(equalTo: foodImageView.heightAnchor),
            
//            nameLabel.leadingAnchor.constraint(equalTo: foodImageView.trailingAnchor, constant: 32),
            nameLabel.topAnchor.constraint(equalTo: foodImageView.centerYAnchor, constant: -24),
            
//            totalCalorieLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
//            totalCalorieLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            totalCalorieLabel.centerYAnchor.constraint(equalTo: nameLabel.centerYAnchor),
            
            dividingLine.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 16),
            dividingLine.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor, constant: -8),
            dividingLine.trailingAnchor.constraint(equalTo: totalCalorieLabel.trailingAnchor, constant: 8),
            
            carboLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            carboLabel.topAnchor.constraint(equalTo: dividingLine.bottomAnchor, constant: 16),
            
            proteinLabel.leadingAnchor.constraint(equalTo: carboLabel.trailingAnchor, constant: 8),
            proteinLabel.topAnchor.constraint(equalTo: carboLabel.topAnchor),
            
            fatLabel.leadingAnchor.constraint(equalTo: proteinLabel.trailingAnchor, constant: 8),
            fatLabel.topAnchor.constraint(equalTo: proteinLabel.topAnchor),
            
            fiberLabel.leadingAnchor.constraint(equalTo: fatLabel.trailingAnchor, constant: 8),
            fiberLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            fiberLabel.topAnchor.constraint(equalTo: fatLabel.topAnchor),

            quantityLabel.topAnchor.constraint(equalTo: foodImageView.bottomAnchor, constant: 16),
            quantityLabel.centerXAnchor.constraint(equalTo: foodImageView.centerXAnchor)
        ])
        
        let nameLabelLeadingConstraint = nameLabel.leadingAnchor.constraint(equalTo: foodImageView.trailingAnchor, constant: 32)
        nameLabelLeadingConstraint.priority = .required

        let totalCalorieLabelTrailingConstraint = totalCalorieLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24)
        totalCalorieLabelTrailingConstraint.priority = .required

        let distanceBetweenLabelsConstraint = totalCalorieLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8)
        distanceBetweenLabelsConstraint.priority = UILayoutPriority(750)

        NSLayoutConstraint.activate([
            nameLabelLeadingConstraint,
            totalCalorieLabelTrailingConstraint,
            distanceBetweenLabelsConstraint
        ])
        
        let equalWidths = [carboLabel, proteinLabel, fatLabel, fiberLabel].map {
            $0.widthAnchor.constraint(equalTo: carboLabel.widthAnchor)
        }
        NSLayoutConstraint.activate(equalWidths)

        // Adjust content hugging and compression resistance
        let labels = [carboLabel, proteinLabel, fatLabel, fiberLabel]
        labels.forEach { label in
            label.setContentHuggingPriority(UILayoutPriority.defaultLow, for: .horizontal)
            label.setContentCompressionResistancePriority(UILayoutPriority.defaultHigh, for: .horizontal)
        }
    }
    
    @objc private func dismissView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.alpha = 0
        }, completion: { _ in
            self.removeFromSuperview()
        })
    }
    
    func presentView(onView parentView: UIView, atTapLocation tapLocation: CGPoint) {
        // Set the size of the card
        let cardWidth: CGFloat = 350
        let cardHeight: CGFloat = 150
        
        // Calculate the position so the card appears centered at the tap location
        let originX = tapLocation.x - cardWidth / 2
        let originY = tapLocation.y - cardHeight / 2
        
        // Ensure the card does not go off the screen edges
        let adjustedOriginX = max(min(originX, parentView.bounds.width - cardWidth), 0)
        let adjustedOriginY = max(min(originY, parentView.bounds.height - cardHeight), 0)
        
        // Set the frame to be at the tap location, adjusted to be within parent view bounds
        self.frame = CGRect(x: adjustedOriginX, y: adjustedOriginY, width: cardWidth, height: cardHeight)
        
        // Style the view to look like a card
        self.backgroundColor = .white
        self.layer.cornerRadius = 10
        self.layer.shadowOpacity = 0.2
        self.layer.shadowRadius = 5
        self.layer.shadowOffset = CGSize(width: 0, height: 2)
        
        self.alpha = 0
        parentView.addSubview(self)
        UIView.animate(withDuration: 0.3) {
            self.alpha = 1
        }
    }
    
    func configureView(_ result: Food) {
        nameLabel.text = "\(result.name)"
        totalCalorieLabel.text = "熱量\(result.totalCalories)kcal"
        carboLabel.text = "碳水\n\(result.nutrients.carbohydrates)g"
        proteinLabel.text = "蛋白\n\(result.nutrients.protein)g"
        fatLabel.text = "脂肪\n\(result.nutrients.fat)g"
        fiberLabel.text = "纖維\n\(result.nutrients.fiber)g"
        foodImageView.loadImage(result.image, placeHolder: UIImage(named: "Food_Placeholder"))
        quantityLabel.text = "\(result.quantity ?? 100)g"
    }
    
}
