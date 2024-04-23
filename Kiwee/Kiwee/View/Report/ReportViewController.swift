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
        
        let margin: CGFloat = 16
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }
        flowLayout.minimumInteritemSpacing = margin
        flowLayout.minimumLineSpacing = margin
    }
    
}

extension ReportViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 4
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
                contentView = AnyView(IntakeCardView())
            case 1:
                contentView = AnyView(CaloriesChartView())
            case 2:
                contentView = AnyView(WeightChartView())
            case 3:
                contentView = AnyView(NutrientsChartView())
            default:
                contentView = AnyView(Text("Placeholder"))
            }
        nutrientCell.host(contentView: contentView, parentViewController: self)
        return nutrientCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width - 32
        switch indexPath.row {
        case 0:
            return CGSize(width: collectionViewWidth, height: 250)
        case 3:
            return CGSize(width: collectionViewWidth, height: 400)
        default:
            return CGSize(width: collectionViewWidth, height: 300)
        }
    }
        
}
