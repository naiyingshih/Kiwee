//
//  CameraViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/13.
//

import UIKit
import Vision
import CoreML

class CameraViewController: UIViewController, UINavigationControllerDelegate {
    
    lazy var imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.image = UIImage(named: "Food_Placeholder")
        imgView.contentMode = .scaleAspectFill
        imgView.clipsToBounds = true
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()
    
    lazy var resultLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var confirmButton: UIButton = {
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
        showAlert()
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
    
    func showAlert() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // Check if the device has a camera
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            let cameraAction = UIAlertAction(title: "Take Photo", style: .default) { [weak self] _ in
                self?.presentImagePicker(sourceType: .camera)
            }
            alertController.addAction(cameraAction)
        }
        
        let photoLibraryAction = UIAlertAction(title: "Choose from Library", style: .default) { [weak self] _ in
            self?.presentImagePicker(sourceType: .photoLibrary)
        }
        alertController.addAction(photoLibraryAction)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
    
    private func presentImagePicker(sourceType: UIImagePickerController.SourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        imagePicker.allowsEditing = false
        present(imagePicker, animated: true, completion: nil)
    }
    
    @objc func confirmed() {
        // TODOs: - find the corresponded food and show result
        self.navigationController?.popViewController(animated: true)
    }
    
}

// MARK: - UIImagePickerControllerDelegate Methods

extension CameraViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[.originalImage] as? UIImage else { return }
        imageView.image = image
        
        // Convert the image for CIImage
        if let ciImage = CIImage(image: image) {
//            processImage(ciImage: ciImage)
        } else {
            print("CIImage convert error")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
//    func processImage(ciImage: CIImage) {
//        
//        do {
//            let model = try VNCoreMLModel(for: SeeFood().model)
//            
//            let request = VNCoreMLRequest(model: model) { (request, error) in
//                self.processClassifications(for: request, error: error)
//            }
//            
//            DispatchQueue.global(qos: .userInitiated).async {
//                let handler = VNImageRequestHandler(ciImage: ciImage, orientation: .up)
//                do {
//                    try handler.perform([request])
//                } catch {
//                    
//                    print("Failed to perform classification.\n\(error.localizedDescription)")
//                }
//            }
//            
//        } catch {
//            print(error.localizedDescription)
//        }
//        
//    }
    
//    func processClassifications(for request: VNRequest, error: Error?) {
//        DispatchQueue.main.async {
//            guard let results = request.results else {
//                print("Unable to classify image.\n\(error!.localizedDescription)")
//                return
//            }
//            
//            let classifications = results as! [VNClassificationObservation]
//            
//            if let topClassification = classifications.first {
//                let confidence = Int(topClassification.confidence * 100) // Convert confidence to percentage
//                self.resultLabel.text = "\(topClassification.identifier.uppercased()) (\(confidence)%)"
//            }
//        }
//    }
    
}
