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
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.hexStringToUIColor(hex: "1F8A70")
        button.setTitle("確認", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(confirmed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }
    
    func setupUI() {
        view.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(resultLabel)
        view.addSubview(confirmButton)
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            resultLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor),
            resultLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            resultLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            resultLabel.heightAnchor.constraint(equalToConstant: 100),
            
            confirmButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            confirmButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.heightAnchor.constraint(equalToConstant: 50)
        ])
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
                self.resultLabel.text = "\(topClassification.identifier) (\(confidence)%)"
                print("===\(results)")
                
                self.loadFood(topClassification.identifier) { foods in
                    guard let foods = foods else {
                        print("no match food was found")
                        return
                    }
                    self.recognizedData = Food(
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
    
}
