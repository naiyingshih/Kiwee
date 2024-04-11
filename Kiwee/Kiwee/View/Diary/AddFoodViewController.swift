//
//  AddFoodViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/11.
//

import UIKit

class AddFoodViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var imageRecognizeButton: UIButton!
    @IBOutlet weak var searchFoodButton: UIButton!
    @IBOutlet weak var manualButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
    }
    
}

extension AddFoodViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        <#code#>
    }
    
}
