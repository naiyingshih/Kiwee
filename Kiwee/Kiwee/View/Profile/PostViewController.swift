//
//  PostViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/20.
//

import UIKit
import MobileCoreServices
import Lottie

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
    
    var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .medium)
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.hidesWhenStopped = true
        return indicator
    }()
    
    // MARK: Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupPostState()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(addImage))
        plusImageView.addGestureRecognizer(tapGesture)
        foodTextField.addTarget(self, action: #selector(textFieldDidChange), for: .editingChanged)
    }
   
    // MARK: - UI Setting functions
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
            setInitialTagButton(forTag: initialSelectedButtonTag ?? "")
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
        ButtonManager.updateButtonEnableStatus(for: postButton, enabled: false)
        postButton.applyPrimaryStyle(size: 17)
        breakfastButton.applyThirdStyle(size: 15)
        lunchButton.applyThirdStyle(size: 15)
        dinnerButton.applyThirdStyle(size: 15)
        snackButton.applyThirdStyle(size: 15)
        
        view.addSubview(activityIndicator)
        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: postButton.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: postButton.centerYAnchor)
        ])
    }
    
    func setInitialTagButton(forTag tag: String) {
        let buttons: [UIButton] = [breakfastButton, lunchButton, dinnerButton, snackButton]
        for button in buttons where button.titleLabel?.text == tag {
            if button.titleLabel?.text == tag {
                button.backgroundColor = UIColor.hexStringToUIColor(hex: "CCCCCC")
                selectedButton = button
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func tagButtonsSelected(_ sender: UIButton) {

        if let previousSelectedButton = selectedButton {
            previousSelectedButton.backgroundColor = .clear
        }
        sender.backgroundColor = UIColor.hexStringToUIColor(hex: "CCCCCC")
        selectedButton = sender
        self.tagString = sender.titleLabel?.text
        checkForChanges()
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        activityIndicator.startAnimating()
        ButtonManager.updateButtonEnableStatus(for: postButton, enabled: false)
        
        switch self.postState {
        case .editingPost:
            // Editing an existing post
            if let editingPostID = self.editingPostID {
                FirestoreManager.shared.updateFoodCollection(
                    documentID: editingPostID,
                    foodName: self.foodTextField.text ?? "",
                    tag: self.tagString ?? ""
                ) { [weak self] in
                    DispatchQueue.main.async {
                        self?.activityIndicator.stopAnimating()
                        self?.showSuccess {
                            self?.dismiss(animated: true)
                        }
                    }
                    print("Post updated successfully")
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
                FirestoreManager.shared.publishFoodCollection(foodName: foodTextField, tag: tag, imageUrl: imageUrl.absoluteString) { success in
                    if success {
                        self?.activityIndicator.stopAnimating()
                        self?.showSuccess {
                            DispatchQueue.main.async {
                                self?.dismiss(animated: true)
                            }
                        }
                        print("Post created successfully")
                    } else {
                        print("Post failed")
                    }
                }
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
        case .editingPost(let initialFoodText, let initialSelectedButtonTag, _):
            let hasFoodTextChanged = foodTextField.text != initialFoodText
            let hasButtonChanged = selectedButton?.titleLabel?.text != initialSelectedButtonTag
            ButtonManager.updateButtonEnableStatus(for: postButton, enabled: hasFoodTextChanged || hasButtonChanged)

        case .newPost:
            ButtonManager.updateButtonEnableStatus(for: postButton, enabled: isFoodTextFieldNotEmpty && isImageSelected && isButtonSelected)
            
        case .none:
            break
        }
    }
    
}

// MARK: - success animation

extension PostViewController {
    
    func showSuccess(completion: @escaping () -> Void) {
        let successView = LottieAnimationView(name: "Success_animation")
        successView.frame = CGRect(x: 0, y: 0, width: 200, height: 200)
        successView.center = self.view.center
        successView.contentMode = .scaleAspectFill
        view.addSubview(successView)
        successView.play { (finished) in
            if finished {
                completion()
            }
        }
        successView.animationSpeed = 0.9
        successView.loopMode = .playOnce
    }
    
}
