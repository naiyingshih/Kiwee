//
//  RecentRecordCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

// MARK: - TableViewCell
class RecentRecordCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var defaultLabel: UILabel = {
        let label = UILabel()
        label.text = "還沒有近期紀錄！"
        label.applyContent(size: 18, color: .gray)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {}
    
    func setupCollectionView() {
        defaultLabel.isHidden = true
        collectionView.register(RecordCollectionCell.self, forCellWithReuseIdentifier: "RecordCollectionCell")
        collectionView.tag = 2
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
            layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 10)
        }
    }
    
    func setupDefaultLabel() {
        collectionView.isHidden = true
        contentView.addSubview(defaultLabel)
        
        NSLayoutConstraint.activate([
            defaultLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            defaultLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            defaultLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
}

// MARK: - CollectionViewCell
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
