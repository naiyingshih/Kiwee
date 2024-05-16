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
