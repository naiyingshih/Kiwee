//
//  ProfileCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/18.
//

import UIKit

enum TagColor {
    case breakfast
    case lunch
    case dinner
    case snack
}

class ProfileCell: UICollectionViewCell {
    
    let dateFormatter = DateFormatterManager.shared.dateFormatter
    var color: TagColor?
    
    lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.applyContent(size: 13, color: KWColor.darkB)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var tagLabel: UILabel = {
        let label = UILabel()
        label.applyContent(size: 15, color: .white)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var tagView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 6
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var photoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 6
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var foodLabel: UILabel = {
        let label = UILabel()
        label.applyContent(size: 16, color: KWColor.darkB)
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
    
    // MARK: - UI setting function
    func setupView() {
        backgroundColor = KWColor.cardBackground
        applyCardStyle()
        
        addSubview(timeLabel)
        addSubview(tagView)
        addSubview(tagLabel)
        addSubview(photoImageView)
        addSubview(foodLabel)
        
        NSLayoutConstraint.activate([
            timeLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 16),
            timeLabel.centerYAnchor.constraint(equalTo: tagView.centerYAnchor),
            
            tagView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            tagView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -16),
            tagView.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.3),
            tagView.heightAnchor.constraint(equalToConstant: 24),
            
            tagLabel.centerYAnchor.constraint(equalTo: tagView.centerYAnchor),
            tagLabel.centerXAnchor.constraint(equalTo: tagView.centerXAnchor),
            
            photoImageView.topAnchor.constraint(equalTo: tagView.bottomAnchor, constant: 8),
            photoImageView.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            photoImageView.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            photoImageView.heightAnchor.constraint(equalTo: self.contentView.heightAnchor, multiplier: 0.6),

            foodLabel.topAnchor.constraint(equalTo: photoImageView.bottomAnchor, constant: 8),
            foodLabel.leadingAnchor.constraint(equalTo: self.contentView.leadingAnchor, constant: 16),
            foodLabel.trailingAnchor.constraint(equalTo: self.contentView.trailingAnchor, constant: -16),
            foodLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -8)
        ])
    }
    
    func updatePostResult(_ result: Post) {
        let dateString = dateFormatter.string(from: result.createdTime)
        timeLabel.text = dateString
        tagLabel.text = "\(result.tag)"
        foodLabel.text = "\(result.foodName)"
        photoImageView.loadImage(result.image)
        tagView.backgroundColor = updateTagColor(result)
    }
    
    func updateTagColor(_ result: Post) -> UIColor {
        switch result.tag {
        case "早餐":
            color = .breakfast
            return UIColor.hexStringToUIColor(hex: "E1B739")
        case "午餐":
            color = .lunch
            return UIColor.hexStringToUIColor(hex: "E08161")
        case "晚餐":
            color = .dinner
            return UIColor.hexStringToUIColor(hex: "657760")
        case "點心":
            color = .snack
            return UIColor.hexStringToUIColor(hex: "632623")
        default:
            break
        }
        return UIColor()
    }
}
