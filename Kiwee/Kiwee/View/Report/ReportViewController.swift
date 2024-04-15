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
        if let layout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 0
            layout.minimumLineSpacing = 0
        }
    }
    
}

extension ReportViewController: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: SwiftUIHostingCell.self),
            for: indexPath
        )
        guard let nutrientCell = cell as? SwiftUIHostingCell else { return cell }
        let contentView = ContentView() // Initialize SwiftUI view
        nutrientCell.host(contentView: contentView, parentViewController: self)
        return nutrientCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let collectionViewWidth = collectionView.bounds.width
        let collectionViewHeight = collectionView.bounds.height

        // Set the size of the cell to take up the full width and height of the collection view
        return CGSize(width: collectionViewWidth, height: collectionViewHeight)
    }
    
}
