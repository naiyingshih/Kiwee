//
//  ReportViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/15.
//

import UIKit
import SwiftUI

class ReportViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(SwiftUIHostingCell.self, forCellWithReuseIdentifier: "SwiftUIHostingCell")
        collectionView.register(IntakeCardView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: "IntakeCardView")
        
        let margin: CGFloat = 16
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
        flowLayout.sectionInset = UIEdgeInsets(top: margin, left: margin, bottom: margin, right: margin)
    }
    
}

extension ReportViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: SwiftUIHostingCell.self),
            for: indexPath
        )
        guard let nutrientCell = cell as? SwiftUIHostingCell else { return cell }
        
        let contentView: AnyView
            switch indexPath.row {
            case 0:
                contentView = AnyView(CaloriesChartView())
            case 1:
                contentView = AnyView(WeightChartView())
            case 2:
                contentView = AnyView(NutrientsChartView())
            default:
                contentView = AnyView(Text("Placeholder"))
            }
        nutrientCell.host(contentView: contentView, parentViewController: self)
        return nutrientCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width - 32
        if indexPath.row == 2 {
            return CGSize(width: collectionViewWidth, height: 400)
        } else {
            return CGSize(width: collectionViewWidth, height: 300)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionView.elementKindSectionHeader {
            
            if indexPath.section == 0 {
                let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "IntakeCardView", for: indexPath)
                guard let cardHeaderView = headerView as? IntakeCardView else { return headerView }
                return cardHeaderView
            }
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width - 32, height: 250)
    }
        
}
