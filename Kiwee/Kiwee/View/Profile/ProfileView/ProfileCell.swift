//
//  ProfileCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/18.
//

import UIKit

class ProfileCell: UICollectionViewCell {
    
    lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hexStringToUIColor(hex: "004358")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var tagView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "1F8A70")
        view.alpha = 0.5
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .lightGray
        imageView.layer.cornerRadius = 6
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var foodLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hexStringToUIColor(hex: "004358")
        label.font = UIFont.systemFont(ofSize: 16)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupView()
    }
    
    func setupView() {
        self.layer.cornerRadius = 10
        self.layer.borderWidth = 2
        self.layer.borderColor = UIColor.hexStringToUIColor(hex: "1F8A70").cgColor
        addSubview(tagView)
        addSubview(tagLabel)
        addSubview(photoImageView)
        addSubview(foodLabel)
        
        NSLayoutConstraint.activate([
            tagView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            tagView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            tagView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.4),
            tagView.heightAnchor.constraint(equalToConstant: 24),
            
            tagLabel.centerYAnchor.constraint(equalTo: tagView.centerYAnchor),
            tagLabel.centerXAnchor.constraint(equalTo: tagView.centerXAnchor),
            
            photoImageView.topAnchor.constraint(equalTo: tagView.bottomAnchor, constant: 8),
            photoImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            photoImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),

            foodLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 8),
            foodLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            foodLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            foodLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func updatePostResult(_ result: Post) {
        tagLabel.text = "\(result.tag)"
        foodLabel.text = "\(result.foodName)"
        photoImageView.loadImage(result.image)
    }
    
}
