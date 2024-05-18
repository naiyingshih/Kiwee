//
//  CameraViewModel.swift
//  Kiwee
//
//  Created by NY on 2024/5/18.
//

import UIKit
import Vision
import CoreML

class CameraViewModel {
    
    var recognizedData: Food?
    var onUpdateResultLabel: ((NSAttributedString) -> Void)?
    
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
    
    private func processClassifications(for request: VNRequest, error: Error?) {
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
                    guard let self = self, let foods = foods else { return }
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
    
    private func updateResultLabel(with identifier: String, confidence: Int) {
        let fullText = "是 \(identifier) 嗎？\n\n辨識信心度：(\(confidence)%)"
        let attributedString = NSMutableAttributedString(string: fullText)
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
        
        DispatchQueue.main.async {
            self.onUpdateResultLabel?(attributedString)
        }
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
