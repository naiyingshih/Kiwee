//
//  CategoryHeader.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

protocol TableViewHeaderDelegate: AnyObject {
    func didTappedAddButton(section: Int)
}

class CategoryHeaderView: UIView {
    
    weak var delegate: TableViewHeaderDelegate?
    var section: Int?
    
    lazy var iconImageView: UIImageView = {
        let icon = UIImageView()
        icon.contentMode = .scaleAspectFill
        icon.clipsToBounds = true
        icon.translatesAutoresizingMaskIntoConstraints = false
        return icon
    }()
    
    lazy var categoryLabel: UILabel = {
        let label = UILabel()
        label.applyTitle(size: 20, color: KWColor.darkB)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var addButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Plus"), for: .normal)
        button.tintColor = KWColor.darkG
        button.addTarget(self, action: #selector(addFood), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
    } 
    
    private func setupViews() {
        self.backgroundColor = KWColor.lightG
        addSubview(iconImageView)
        addSubview(categoryLabel)
        addSubview(addButton)
        
        NSLayoutConstraint.activate([
            iconImageView.widthAnchor.constraint(equalToConstant: 40),
            iconImageView.heightAnchor.constraint(equalToConstant: 40),
            iconImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            iconImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            
            categoryLabel.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            categoryLabel.leadingAnchor.constraint(equalTo: iconImageView.trailingAnchor, constant: 24),
            
            addButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            addButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            addButton.widthAnchor.constraint(equalToConstant: 24),
            addButton.heightAnchor.constraint(equalToConstant: 24)
        ])
    }
    
    func configure(with image: UIImage?, labelText: String) {
        iconImageView.image = image
        categoryLabel.text = labelText
    }
    
    @objc func addFood() {
        guard let section = section else { return }
        delegate?.didTappedAddButton(section: section)
    }
}
