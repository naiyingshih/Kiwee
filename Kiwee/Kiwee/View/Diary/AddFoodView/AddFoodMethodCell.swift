//
//  AddFoodViewCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

@objc protocol AddFoodMethodCellDelegate: AnyObject {
    @objc optional func searchBarDidChange(text: String)
    @objc optional func cameraButtonDidTapped()
}

enum AddFoodMethod {
    case imageRecognition
    case search
    case manual
}

class AddFoodMethodCell: UITableViewCell {
    
    weak var delegate: AddFoodMethodCellDelegate?
    
    lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "搜尋食物"
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    lazy var nameTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "輸入食物名稱"
        textField.borderStyle = .roundedRect
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {}
    
    @objc func openCamera() {
        guard let delegate = delegate else { return }
        delegate.cameraButtonDidTapped?()
    }
    
    func configureCellForMethod(_ method: AddFoodMethod?) {
        contentView.subviews.forEach { $0.removeFromSuperview() }
        switch method {
        case .imageRecognition:
            setupCameraButton()
        case .search:
            setupSearchBar()
        case .manual:
            setupTextField()
        default:
            break
        }
    }
    
    func setupCameraButton() {
        contentView.addSubview(cameraButton)
        
        NSLayoutConstraint.activate([
            cameraButton.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            cameraButton.centerYAnchor.constraint(equalTo: self.centerYAnchor),
            cameraButton.widthAnchor.constraint(equalToConstant: 100),
            cameraButton.heightAnchor.constraint(equalToConstant: 100)
        ])
    }
    
    func setupSearchBar() {
        contentView.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            searchBar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            searchBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 16),
            searchBar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -16)
        ])
    }
    
    func setupTextField() {
        contentView.addSubview(nameTextField)
        
        NSLayoutConstraint.activate([
            nameTextField.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            nameTextField.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            nameTextField.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
        
    }
    
}

extension AddFoodMethodCell: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        guard let delegate = delegate else { return }
        delegate.searchBarDidChange?(text: searchText)
    }
    
}
