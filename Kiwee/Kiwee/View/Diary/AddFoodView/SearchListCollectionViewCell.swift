//
//  SearchListCollectionViewCell.swift
//  Kiwee
//
//  Created by NY on 2024/5/16.
//

import UIKit

class SearchListCollectionViewCell: UICollectionViewCell {
    
    weak var delegate: AddFoodMethodCellDelegate?
    
    lazy var foodLabel: UILabel = {
        let label = UILabel()
        label.applyContent(size: 16, color: .black)
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLabel()
        applyCardStyle()
        self.clipsToBounds = true
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupLabel()
    }
    
    override var isSelected: Bool {
        didSet {
            configureForSelection(isSelected: isSelected)
        }
    }
    
    private func setupLabel() {
        contentView.addSubview(foodLabel)
        
        NSLayoutConstraint.activate([
            foodLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            foodLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            foodLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            foodLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
    }
    
    func configureForSelection(isSelected: Bool) {
        if isSelected {
            self.applyCardStyle(backgroundColor: .lightGray)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
                self?.applyCardStyle()
            }
        } else {
            self.applyCardStyle()
        }
    }
    
    func updateResults(_ results: Food) {
        foodLabel.text = results.name
    }
    
}
