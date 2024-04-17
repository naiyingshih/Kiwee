//
//  CollectionReusableView.swift
//  Kiwee
//
//  Created by NY on 2024/4/17.
//

import UIKit

class IntakeCardView: UICollectionReusableView {
        
    private let contentView = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupContentView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupContentView()
    }
    
    private func setupContentView() {
        addSubview(contentView)
        contentView.backgroundColor = UIColor.hexStringToUIColor(hex: "BEDB39")
        contentView.layer.cornerRadius = 10
        contentView.layer.borderWidth = 2
        contentView.layer.borderColor = UIColor.hexStringToUIColor(hex: "1F8A70").cgColor
        contentView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: topAnchor, constant: 16),
            contentView.leftAnchor.constraint(equalTo: leftAnchor, constant: 16),
            contentView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -16),
            contentView.rightAnchor.constraint(equalTo: rightAnchor, constant: -16)
        ])
    }
    
}
