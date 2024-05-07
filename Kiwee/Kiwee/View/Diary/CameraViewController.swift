//
//  CameraViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/13.
//

import UIKit
import Vision
import CoreML

protocol FoodDataDelegate: AnyObject {
    func didReceiveFoodData(name: String, totalCalories: Double, nutrients: Nutrient, image: String)
    func didTappedRetake(_ controller: CameraViewController)
}

class CameraViewController: UIViewController, UINavigationControllerDelegate {
    
    weak var delegate: FoodDataDelegate?
    
    var recognizedData: Food?
    
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
//        button.setTitleColor(.white, for: .normal)
//        button.layer.cornerRadius = 10
//        button.backgroundColor = UIColor.hexStringToUIColor(hex: "004358")
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
        if let foodData = recognizedData {
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

// MARK: - Image processing

extension CameraViewController {
      
    func processImage(ciImage: CIImage) {
        
        do {
            let configuration = MLModelConfiguration()
            let model = try VNCoreMLModel(for: FoodSample(configuration: configuration).model)
            
            let request = VNCoreMLRequest(model: model) { (request, error) in
                self.processClassifications(for: request, error: error)
            }
            
            DispatchQueue.global(qos: .userInitiated).async {
                let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
                do {
                    try handler.perform([request])
                } catch {
                    print("Failed to perform classification.\n\(error.localizedDescription)")
                }
            }
            
        } catch {
            print("Error initializing VNCoreMLModel: \(error)")
        }
    }
    
    func processClassifications(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                print("Unable to classify image.\n\(error!.localizedDescription)")
                return
            }
            
            guard let classifications = results as? [VNClassificationObservation] else {
                print("Error:\(String(describing: error))")
                return
            }
            
            if let topClassification = classifications.first {
                let confidence = Int(topClassification.confidence * 100)
                self.updateResultLabel(with: topClassification.identifier, confidence: confidence)
                
                self.loadFood(topClassification.identifier) { [weak self] foods in
                    guard let foods = foods else {
                        print("no match food was found")
                        return
                    }
                    self?.recognizedData = Food(
                        documentID: "", 
                        name: foods.name,
                        totalCalories: foods.totalCalories,
                        nutrients: foods.nutrients,
                        image: foods.image,
                        quantity: nil,
                        section: nil,
                        date: nil
                    )
                }
            }
        }
    }
    
    private func updateResultLabel(with identifier: String, confidence: Int) {
        let fullText = "是 \(identifier) 嗎？\n\n辨識信心度：(\(confidence)%)"
        // Create an NSMutableAttributedString that we'll append everything to
        let attributedString = NSMutableAttributedString(string: fullText)
        // Define the attributes for the different parts of the text
        let identifierAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.medium(size: 24) as Any,
            .foregroundColor: KWColor.darkB
        ]
        let confidenceAttributes: [NSAttributedString.Key: Any] = [
            .font: UIFont.regular(size: 15) as Any,
            .foregroundColor: UIColor.lightGray
        ]
        // Apply the attributes to the specific parts of the text
        if let identifierRange = fullText.range(of: identifier) {
            let nsRange = NSRange(identifierRange, in: fullText)
            attributedString.addAttributes(identifierAttributes, range: nsRange)
        }
        
        if let confidenceRange = fullText.range(of: "辨識信心度：(\(confidence)%)") {
            let nsRange = NSRange(confidenceRange, in: fullText)
            attributedString.addAttributes(confidenceAttributes, range: nsRange)
        }
        // Set the attributed text to the label
        self.resultLabel.attributedText = attributedString
    }
    
    private func loadFood(_ name: String, completion: @escaping (Food?) -> Void) {
        FoodDataManager.shared.loadFood { (foodItems, _) in
            if let food = foodItems?.first(where: { $0.name == name }) {
                completion(food)
            } else {
                completion(nil)
            }
        }
    }
    
}
