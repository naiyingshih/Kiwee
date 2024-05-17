//
//  RecentRecordCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

// MARK: - TableViewCell
class RecentRecordCell: UITableViewCell {

    var viewModel: AddFoodViewModel?
    
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
        collectionView.dataSource = self
        collectionView.delegate = self
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

// MARK: - CollectionView
extension RecentRecordCell: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let viewModel = viewModel else { return 0 }
        return viewModel.recentFoods.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: RecordCollectionCell.self),
            for: indexPath)
        guard let recentCollectionViewCell = cell as? RecordCollectionCell else { return cell }
        guard let viewModel = viewModel else { return recentCollectionViewCell }
        let recentFood = viewModel.recentFoods[indexPath.row]
        recentCollectionViewCell.updateResults(recentFood)
        return recentCollectionViewCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        return CGSize(width: 80, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewModel = viewModel else { return }
        let recentFood = viewModel.recentFoods[indexPath.row]
        viewModel.filteredFoodItems.insert(recentFood, at: 0)
    }
    
}
