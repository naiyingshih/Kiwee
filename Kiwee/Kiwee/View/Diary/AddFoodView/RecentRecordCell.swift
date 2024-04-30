//
//  RecentRecordCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

class RecentRecordCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    lazy var defaultLabel: UILabel = {
        let label = UILabel()
        label.text = "還沒有近期紀錄！"
        label.textColor = .gray
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func setSelected(_ selected: Bool, animated: Bool) {}
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupCollectionView()
    }
    
    private func setupCollectionView() {
        collectionView.register(RecordCollectionCell.self, forCellWithReuseIdentifier: "RecordCollectionCell")
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
        }
    }
    
    func setupDefaultLabel() {
        contentView.addSubview(defaultLabel)
        
        NSLayoutConstraint.activate([
            defaultLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            defaultLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            defaultLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
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
        label.font = UIFont.systemFont(ofSize: 15)
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
    
    func setupUI() {
        addSubview(foodImageView)
        addSubview(foodLabel)
        
        NSLayoutConstraint.activate([
            foodImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            foodImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            foodImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            foodImageView.widthAnchor.constraint(equalToConstant: 80),
            foodImageView.heightAnchor.constraint(equalToConstant: 100),
            
            foodLabel.topAnchor.constraint(equalTo: foodImageView.bottomAnchor, constant: 8),
            foodLabel.leadingAnchor.constraint(equalTo: foodImageView.leadingAnchor),
            foodLabel.trailingAnchor.constraint(equalTo: foodImageView.trailingAnchor),
            foodLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)
        ])
    }
    
    func updateResults(_ results: Food) {
        foodImageView.loadImage(results.image, placeHolder: UIImage(named: "Food_Placeholder"))
        foodLabel.text = results.name
    }
    
}
