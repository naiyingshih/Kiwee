//
//  RecentRecordCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

class RecentRecordCell: UITableViewCell {
    
    @IBOutlet weak var collectionView: UICollectionView!

    override func setSelected(_ selected: Bool, animated: Bool) {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    func setupCollectionView() {
        collectionView.register(RecordCollectionCell.self, forCellWithReuseIdentifier: "RecordCollectionCell")
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
        }
    }
}

class RecordCollectionCell: UICollectionViewCell {
    
    lazy var foodImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.backgroundColor = UIColor.hexStringToUIColor(hex: "004358")
        imageView.layer.cornerRadius = 8
        return imageView
    }()
    
    lazy var foodLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hexStringToUIColor(hex: "004358")
        label.font = UIFont.systemFont(ofSize: 17)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var calorieLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.hexStringToUIColor(hex: "004358")
        label.font = UIFont.systemFont(ofSize: 14)
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
    
    func setupUI() {
        addSubview(foodImageView)
        addSubview(foodLabel)
        addSubview(calorieLabel)
        
        NSLayoutConstraint.activate([
            foodImageView.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            foodImageView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 12),
            foodImageView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -12),
            foodImageView.heightAnchor.constraint(equalTo: self.widthAnchor),
            
            foodLabel.topAnchor.constraint(equalTo: foodImageView.bottomAnchor, constant: 8),
            foodLabel.leadingAnchor.constraint(equalTo: foodImageView.leadingAnchor),
            foodLabel.trailingAnchor.constraint(equalTo: foodImageView.trailingAnchor),
            
            calorieLabel.topAnchor.constraint(equalTo: foodLabel.bottomAnchor, constant: 8),
            calorieLabel.leadingAnchor.constraint(equalTo: foodLabel.leadingAnchor),
            calorieLabel.trailingAnchor.constraint(equalTo: foodLabel.trailingAnchor),
            calorieLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12)
        ])
    }
    
    func updateResults(_ results: Food) {
        foodImageView.loadImage(results.image, placeHolder: UIImage(named: "Food_Placeholder"))
        foodLabel.text = results.name
        calorieLabel.text = "\(results.totalCalories)"
    }
    
}
