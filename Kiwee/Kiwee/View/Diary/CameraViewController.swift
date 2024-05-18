//
//  CameraViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/13.
//

import UIKit

protocol FoodDataDelegate: AnyObject {
    func didReceiveFoodData(name: String, totalCalories: Double, nutrients: Food.Nutrient, image: String)
    func didTappedRetake(_ controller: CameraViewController)
}

class CameraViewController: UIViewController, UINavigationControllerDelegate {
    
    let viewModel = CameraViewModel()
    weak var delegate: FoodDataDelegate?
    
    lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "Food_Placeholder")
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    private lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.regular(size: 17)
        label.textColor = .black
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.setTitle("確認", for: .normal)
        button.applyPrimaryStyle(size: 17)
        button.addTarget(self, action: #selector(confirmed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var cancelButton: UIButton = {
       let button = UIButton()
        button.setTitle("取消", for: .normal)
        button.applyThirdStyle(size: 17)
        button.addTarget(self, action: #selector(canceled), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    private lazy var retakeButton: UIButton = {
       let button = UIButton()
        button.setTitle("重新辨識", for: .normal)
        button.applySecondaryStyle(size: 17)
        button.addTarget(self, action: #selector(retake), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        viewModel.onUpdateResultLabel = { [weak self] attributedText in
            self?.resultLabel.attributedText = attributedText
        }
    }
    
    // MARK: - UI Setting Function
    func setupUI() {
        view.backgroundColor = KWColor.background
        view.addSubview(imageView)
        view.addSubview(resultLabel)
        view.addSubview(confirmButton)
        view.addSubview(cancelButton)
        view.addSubview(retakeButton)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            resultLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor,constant: 24),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 48),
            confirmButton.trailingAnchor.constraint(equalTo: retakeButton.leadingAnchor, constant: -20),
            confirmButton.widthAnchor.constraint(equalToConstant: 90),
            
            retakeButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            retakeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            retakeButton.heightAnchor.constraint(equalToConstant: 48),
            retakeButton.widthAnchor.constraint(equalTo: confirmButton.widthAnchor),
            
            cancelButton.leadingAnchor.constraint(equalTo: retakeButton.trailingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cancelButton.heightAnchor.constraint(equalToConstant: 48),
            cancelButton.widthAnchor.constraint(equalTo: confirmButton.widthAnchor)
        ])
    }
    
    // MARK: - Actions
    @objc func confirmed() {
        if let foodData = viewModel.recognizedData {
            self.delegate?.didReceiveFoodData(
                name: foodData.name,
                totalCalories: foodData.totalCalories,
                nutrients: foodData.nutrients,
                image: foodData.image
            )
        }
        self.dismiss(animated: true) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func canceled() {
        self.dismiss(animated: true) { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
    }
    
    @objc func retake() {
        delegate?.didTappedRetake(self)
    }
    
}
