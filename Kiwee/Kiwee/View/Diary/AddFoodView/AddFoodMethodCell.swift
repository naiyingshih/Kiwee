//
//  AddFoodViewCell.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

protocol AddFoodMethodCellDelegate: AnyObject {
    func searchBarDidChange(text: String)
}

class AddFoodMethodCell: UITableViewCell, UISearchBarDelegate {
    
    weak var delegate: AddFoodMethodCellDelegate?
    
    lazy var cameraButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "camera"), for: .normal)
        button.setTitle("開啟相機", for: .normal)
        button.addTarget(self, action: #selector(openCamera), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search Food Here..."
        searchBar.delegate = self
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {}
    
    @objc func openCamera() {
        
    }
    
    private func setupUI() {
        contentView.addSubview(searchBar)
        
        NSLayoutConstraint.activate([
            searchBar.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 24),
            searchBar.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -24),
            searchBar.topAnchor.constraint(equalTo: self.topAnchor, constant: 8),
            searchBar.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8)
        ])
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        delegate?.searchBarDidChange(text: searchText)
    }
    
}
