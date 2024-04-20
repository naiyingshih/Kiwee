//
//  PostViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/20.
//

import UIKit
import MobileCoreServices

class PostViewController: UIViewController {
    
    var selectedButton: UIButton?
    var tag: String?
    var selectedImageData: Data?
    
    @IBOutlet weak var plusImageView: UIImageView!
    @IBOutlet weak var foodTextField: UITextField!
    @IBOutlet weak var breakfastButton: UIButton!
    @IBOutlet weak var lunchButton: UIButton!
    @IBOutlet weak var dinnerButton: UIButton!
    @IBOutlet weak var snackButton: UIButton!
    @IBOutlet weak var postButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        breakfastButton.tag = 0
        lunchButton.tag = 1
        dinnerButton.tag = 2
        snackButton.tag = 3
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addImage))
        plusImageView.addGestureRecognizer(tapGesture)
        plusImageView.isUserInteractionEnabled = true
    }
    
    func setupUI() {
        configureButtonAppearance(button: breakfastButton)
        configureButtonAppearance(button: lunchButton)
        configureButtonAppearance(button: dinnerButton)
        configureButtonAppearance(button: snackButton)
    }

    func configureButtonAppearance(button: UIButton) {
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.hexStringToUIColor(hex: "1F8A70").cgColor
        button.layer.cornerRadius = 10
    }
    
    @IBAction func tagButtonsSelected(_ sender: UIButton) {
        if let previousSelectedButton = selectedButton {
            previousSelectedButton.backgroundColor = .clear
        }
        sender.backgroundColor = .lightGray
        selectedButton = sender
        self.tag = sender.titleLabel?.text
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        guard let foodTextField = foodTextField.text, !foodTextField.isEmpty,
              let tag = tag,
              let imageData = selectedImageData else { return }
        
        FirestoreManager.shared.uploadImageData(imageData: imageData) { [weak self] success, url in
            guard success, let imageUrl = url else {
                print("image upload failed")
                return
            }
            FirestoreManager.shared.publishFoodCollection(
                id: "Un9y8lW7NM5ghB43ll7r",
                foodName: foodTextField,
                tag: tag,
                imageUrl: imageUrl.absoluteString
            )
            self?.selectedImageData = nil
        }
        self.dismiss(animated: true)
    }
    
    @objc func addImage() {
        guard UIImagePickerController.isSourceTypeAvailable(.photoLibrary) else { return }
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = .photoLibrary
        imagePicker.allowsEditing = true
        imagePicker.mediaTypes = ["public.image"]
        present(imagePicker, animated: true, completion: nil)
    }
}

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let editedImage = info[.editedImage] as? UIImage {
            plusImageView.image = editedImage
            self.selectedImageData = editedImage.jpegData(compressionQuality: 0.75)
           
        } else if let originalImage = info[.originalImage] as? UIImage {
            plusImageView.image = originalImage
            self.selectedImageData = originalImage.jpegData(compressionQuality: 0.75)
            
        }
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}
