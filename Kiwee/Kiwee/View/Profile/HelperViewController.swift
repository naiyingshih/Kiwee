//
//  HelperViewController.swift
//  Kiwee
//
//  Created by NY on 2024/5/4.
//

import UIKit

class HelperViewController: UIViewController {
    
    @IBOutlet weak var card1View: UIView!
    @IBOutlet weak var card2View: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var verticleConstraint1: NSLayoutConstraint!
    @IBOutlet weak var verticleConstraint2: NSLayoutConstraint!
    @IBOutlet weak var verticleConstraint3: NSLayoutConstraint!
    @IBOutlet weak var verticleConstraint4: NSLayoutConstraint!
    
    let weight = UserDefaults.standard.double(forKey: "initial_weight")
    let RDA = UserDefaults.standard.double(forKey: "RDA")
    
    lazy var nutrientData: [NutrientCardModel] = [
        NutrientCardModel(nutrient: "蛋白質",
                          description: "有助於肌肉生長修復，使飽腹感更長久",
                          content: "維持或增加肌肉質量建議所需蛋白質為每千克體重 1.0-1.2g 蛋白質之間",
                          customInfo: "您的體重為\(weight)kg，\n每日建議的蛋白質攝取量約為 \(Int(weight * 1)) - \(Int(weight * 1.2)) g",
                          image: "protein"),
        NutrientCardModel(nutrient: "脂肪",
                          description: "脂肪有助於調節荷爾蒙水平和維持關節健康",
                          content: "建議每天攝取的脂肪應佔每日攝取熱量的 20-40 ％\n有益的脂肪：橄欖油和低脂乳製品、鮭魚、堅果等。",
                          customInfo: "9 kcal 等於 1g 脂肪，因此您建議攝取的脂肪為 \(Int(RDA * 0.2 / 9)) - \(Int(RDA * 0.4 / 9)) g。",
                          image: "fat"),
        NutrientCardModel(nutrient: "碳水化合物",
                          description: "可以為我們提供能量，補充肌肉糖原儲備",
                          content: "可以將總卡路里攝取量中減去蛋白質和脂肪的量，來計算碳水化合物的攝取量。",
                          customInfo: "4 kcal 等於 1g 碳水，因此您建議攝取的碳水為 \(Int((RDA - (weight * 1 * 4) - (RDA * 0.2)) / 4)) - \(Int((RDA - (weight * 1.2 * 4) - (RDA * 0.4)) / 4)) g。",
                          image: "carbo"),
        NutrientCardModel(nutrient: "纖維",
                          description: "纖維雖然不能被人體消化，但可以被利用",
                          content: "攝取足夠的纖維可以維持腸道健康、降低心臟病和糖尿病風險、輔助膽固醇控制等",
                          customInfo: "根據美國食品營養委員會建議，成年女性每天應攝取大約 25g 纖維，成年男性則約 38g 纖維。",
                          image: "fiber")
    ]
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupInitialUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        adjustConstraintsForDevice()
    }
    
    // MARK: - UI Setting Function
    func setupInitialUI() {
        view.backgroundColor = .white
        card1View.applyCardStyle()
        card2View.applyCardStyle()

        collectionView.backgroundColor = .clear
        collectionView.dataSource = self
        collectionView.delegate = self
    }
    
    func adjustConstraintsForDevice() {
        let screenSize = UIScreen.main.bounds.size

        if screenSize.width > 414 {
            // Adjust constraints for larger screens
            verticleConstraint1.constant = 40
            verticleConstraint2.constant = 40
            verticleConstraint3.constant = 60
            verticleConstraint4.constant = 120
        } else if screenSize.height > 736 {
            // Adjust constraints for medium screens
            verticleConstraint1.constant = 30
            verticleConstraint2.constant = 30
            verticleConstraint3.constant = 45
            verticleConstraint4.constant = 90
        } else {
            // Adjust constraints for smaller screens
            verticleConstraint1.constant = 8
            verticleConstraint2.constant = 8
            verticleConstraint3.constant = 5
            verticleConstraint4.constant = 60
        }
    }
    
}

// MARK: - UICollectionView
extension HelperViewController: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return nutrientData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: NutrientCell.self),
            for: indexPath)
        guard let nutrientCell = cell as? NutrientCell else { return cell }
        let nutrientModel = nutrientData[indexPath.row]
        nutrientCell.configureCell(with: nutrientModel)
        return nutrientCell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height
        let width = collectionView.bounds.width - 32
        return CGSize(width: width, height: height)
    }
    
}
