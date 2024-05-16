//
//  RecentRecordCollectionViewCell.swift
//  Kiwee
//
//  Created by NY on 2024/5/16.
//

import UIKit

class RecordCollectionCell: UICollectionViewCell {
    
    lazy var foodImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = KWColor.darkB
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    lazy var foodLabel: UILabel = {
        let label = UILabel()
        label.applyContent(size: 16, color: KWColor.darkB)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
    }
    
    override var isSelected: Bool {
        didSet {
            configureForSelection(isSelected: isSelected)
        }
    }
    
    func configureForSelection(isSelected: Bool) {
        if isSelected {
            foodImageView.layer.borderWidth = 4
            foodImageView.layer.borderColor = KWColor.lightY.cgColor
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.foodImageView.layer.borderWidth = 0
            }
        } else {
            return
        }
    }
    
    func setupUI() {
        addSubview(foodImageView)
        addSubview(foodLabel)
        
        NSLayoutConstraint.activate([
            foodImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            foodImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            foodImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            foodImageView.widthAnchor.constraint(equalToConstant: 75),
            foodImageView.heightAnchor.constraint(equalToConstant: 90),
            
            foodLabel.topAnchor.constraint(equalTo: foodImageView.bottomAnchor, constant: 6),
            foodLabel.leadingAnchor.constraint(equalTo: foodImageView.leadingAnchor),
            foodLabel.trailingAnchor.constraint(equalTo: foodImageView.trailingAnchor),
            foodLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    func updateResults(_ results: Food) {
        foodImageView.loadImage(results.image, placeHolder: UIImage(named: "Food_Placeholder"))
        foodLabel.text = results.name
    }
    
}
