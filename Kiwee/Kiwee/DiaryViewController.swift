//
//  ViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/10.
//

import UIKit

class DiaryViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

}

extension DiaryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(
            withIdentifier: String(describing: DiaryViewCell.self),
            for: indexPath
        )
        guard let diaryCell = cell as? DiaryViewCell else { return cell }
        
        return diaryCell
    }

}
