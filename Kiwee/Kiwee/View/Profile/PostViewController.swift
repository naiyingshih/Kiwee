//
//  PostViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/20.
//

import UIKit
import MobileCoreServices

enum PostState {
    case newPost
    case editingPost(initialFoodText: String?, initialSelectedButtonTag: String?, initialImage: String?)
}

class PostViewController: UIViewController {
    
    var postState: PostState?
    var editingPostID: String?
    
    var selectedButton: UIButton?
    var tagString: String?
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
        setupPostState()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addImage))
        plusImageView.addGestureRecognizer(tapGesture)
        foodTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
        postButton.isEnabled = false
        postButton.alpha = 0.5
    }
   
    func setupPostState() {
        switch postState {
        case .editingPost(let initialFoodText, let initialSelectedButtonTag, let initialImage):
            foodTextField.text = initialFoodText
            
            if let tag = initialSelectedButtonTag {
                tagString = tag
            }
            
            if let image = initialImage {
                plusImageView.loadImage(image)
            }
            setInitialButton(forTag: initialSelectedButtonTag ?? "")
            plusImageView.isUserInteractionEnabled = false
            postButton.setTitle("確認變更", for: .normal)
        case .newPost:
            plusImageView.isUserInteractionEnabled = true
            postButton.setTitle("發佈", for: .normal)
        case .none:
            break
        }
        checkForChanges()
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
    
    func setInitialButton(forTag tag: String) {
        let buttons: [UIButton] = [breakfastButton, lunchButton, dinnerButton, snackButton]
        for button in buttons where button.titleLabel?.text == tag {
            if button.titleLabel?.text == tag {
                button.backgroundColor = .lightGray
                selectedButton = button
            }
        }
    }
    
    @IBAction func tagButtonsSelected(_ sender: UIButton) {
        if let previousSelectedButton = selectedButton {
            previousSelectedButton.backgroundColor = .clear
        }
        sender.backgroundColor = .lightGray
        selectedButton = sender
        self.tagString = sender.titleLabel?.text
        checkForChanges()
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        
        switch self.postState {
        case .editingPost(_, _, _):
            // Editing an existing post
            if let editingPostID = self.editingPostID {
                FirestoreManager.shared.updateFoodCollection(
                    documentID: editingPostID,
                    foodName: self.foodTextField.text ?? "",
                    tag: self.tagString ?? ""
                ) {
                    print("Post updated successfully")
                    self.dismiss(animated: true)
                }
            }
        case .newPost:
            guard let foodTextField = foodTextField.text, !foodTextField.isEmpty,
                  let tag = tagString,
                  let imageData = selectedImageData else { return }
            
            FirestoreManager.shared.uploadImageData(imageData: imageData) { [weak self] success, url in
                guard success, let imageUrl = url else {
                    print("Image upload failed")
                    return
                }
                // Creating a new post
                FirestoreManager.shared.publishFoodCollection(
                    id: "Un9y8lW7NM5ghB43ll7r",
                    foodName: foodTextField,
                    tag: tag,
                    imageUrl: imageUrl.absoluteString
                )
                print("Post created successfully")
                self?.dismiss(animated: true)
                
            }
        default:
            break
        }
        self.selectedImageData = nil
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

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

        if let editedImage = info[.editedImage] as? UIImage {
            plusImageView.image = editedImage
            self.selectedImageData = editedImage.jpegData(compressionQuality: 0.75)
           
        } else if let originalImage = info[.originalImage] as? UIImage {
            plusImageView.image = originalImage
            self.selectedImageData = originalImage.jpegData(compressionQuality: 0.75)
        }
        checkForChanges()
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
}

// MARK: - handle button status

extension PostViewController {
    
    @objc func textFieldDidChange(_ textField: UITextField) {
        checkForChanges()
    }
    
    func checkForChanges() {
        let isFoodTextFieldNotEmpty = !(foodTextField.text?.isEmpty ?? true)
        let isImageSelected = selectedImageData != nil
        let isButtonSelected = selectedButton != nil
        
        switch postState {
        case .editingPost(let initialFoodText, let initialSelectedButtonTag, let initialImage):
            let hasFoodTextChanged = foodTextField.text != initialFoodText
            let hasButtonChanged = selectedButton?.currentTitle != initialSelectedButtonTag
            
            postButton.isEnabled = hasFoodTextChanged || hasButtonChanged
        case .newPost:
            postButton.isEnabled = isFoodTextFieldNotEmpty && isImageSelected && isButtonSelected
        case .none:
            break
        }
        
        postButton.alpha = postButton.isEnabled ? 1.0 : 0.5
    }
    
}
