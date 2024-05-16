//
//  ViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/10.
//

import UIKit

class DiaryViewController: UIViewController {
    
    var viewModel = DiaryViewModel()
    
    lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.layer.cornerRadius = 10
        picker.layer.backgroundColor = KWColor.lightY.cgColor
        picker.tintColor = KWColor.darkG
        picker.sizeToFit()
        picker.addTarget(self, action: #selector(dateChanged(datePicker:)), for: .valueChanged)
        picker.translatesAutoresizingMaskIntoConstraints = false
        return picker
    }()
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = KWColor.background
        self.navigationItem.titleView = datePicker
        setupTableView()
        viewModel.loadData(for: Date())
        bindViewModel()
    }
    
    // MARK: - UI setting functions
    private func setupTableView() {
        tableView.backgroundColor = KWColor.background
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.sectionHeaderTopPadding = 8
    }
    
    // MARK: - Fetching Data functions
    private func bindViewModel() {
        viewModel.reloadData = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadData()
            }
        }
        
        viewModel.updateWaterSection = { [weak self] in
            DispatchQueue.main.async {
                self?.tableView.reloadSections(IndexSet(integer: 4), with: .none)
            }
        }
    }
    
    // MARK: - Actions
    @objc func dateChanged(datePicker: UIDatePicker) {
        viewModel.loadData(for: datePicker.date)
    }
    
}

// MARK: - TableViewHeaderDelegate
extension DiaryViewController: TableViewHeaderDelegate {
    
    func didTappedAddButton(section: Int) {
        if section == 4 {
            viewModel.addWaterCount()
            
            viewModel.postWaterCount(chosenDate: datePicker.date) { [weak self] success in
                if success {
                    print("water intake data posted successfully, water count = \(self?.viewModel.waterCount ?? 0)")
                    self?.navigationController?.popViewController(animated: true)
                } else {
                    print("Failed to post water intake data")
                }
            }
        } else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            guard let addFoodVC = storyboard.instantiateViewController(
                withIdentifier: String(describing: AddFoodViewController.self)
            ) as? AddFoodViewController else { return }
            addFoodVC.sectionIndex = section
            addFoodVC.selectedDate = datePicker.date
            self.navigationController?.pushViewController(addFoodVC, animated: true)
        }
    }
    
}

// MARK: - Extension: UITableViewDelegate, UITableViewDataSource
extension DiaryViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 4 {
            return 1
        } else {
            return viewModel.allFood[section].count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 4 {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: WaterViewCell.self),
                for: indexPath
            )
            guard let waterCell = cell as? WaterViewCell else { return cell }
            waterCell.waterSectionConfigure(count: viewModel.waterCount)
            scrollToBottomIfNeeded()
            return waterCell

        } else {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: String(describing: DiaryViewCell.self),
                for: indexPath
            )
            guard let diaryCell = cell as? DiaryViewCell else { return cell }
            let foodData = viewModel.allFood[indexPath.section][indexPath.row]
            diaryCell.update(foodData)
            return diaryCell
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 4 {
            let numberOfRows = (viewModel.waterCount + 7) / 8
            let imageHeight: CGFloat = 50
            let spaceBetweenRows: CGFloat = 10
            let totalHeight = CGFloat(numberOfRows) * imageHeight + CGFloat(numberOfRows - 1) * spaceBetweenRows
            return totalHeight + 30
        } else {
            return 80
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = CategoryHeaderView()
        header.section = section
        header.delegate = self
        switch section {
        case 0:
            header.configure(with: UIImage(named: "Breakfast"), labelText: "早餐")
        case 1:
            header.configure(with: UIImage(named: "Lunch"), labelText: "午餐")
        case 2:
            header.configure(with: UIImage(named: "Dinner"), labelText: "晚餐")
        case 3:
            header.configure(with: UIImage(named: "Snack"), labelText: "點心")
        case 4:
            header.configure(with: UIImage(named: "Water"), labelText: "水")
        default:
            header.configure(with: nil, labelText: "Other Sections")
        }
        
        return header
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section != 4 {
            let detailView = DetailView()
            if let cell = tableView.cellForRow(at: indexPath) {
                let cellFrameInSuperview = tableView.convert(cell.frame, to: self.view)
                let tapLocation = CGPoint(x: cellFrameInSuperview.midX, y: cellFrameInSuperview.midY)
                let food = viewModel.allFood[indexPath.section][indexPath.row]
                detailView.configureView(food)
                detailView.presentView(onView: self.view, atTapLocation: tapLocation)
            }
        } else {
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            if indexPath.section >= 0 && indexPath.section <= 3 {
                viewModel.deleteFoodItem(at: indexPath) { success in
                    if success {
                        print("Document successfully removed!")
                    } else {
                        print("Error removing document")
                    }
                }
            } else if indexPath.section == 4 {
                viewModel.resetWaterCount(chosenDate: datePicker.date) { success in
                    if success {
                        print("water successfully reset")
                    } else {
                        print("Error removing document")
                    }
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        if indexPath.section == 4 {
            return "重設"
        } else {
            return "刪除"
        }
    }
    
    private func scrollToBottomIfNeeded() {
        DispatchQueue.main.async {
            let bottomIndexPath = IndexPath(row: 0, section: 4)
            self.tableView.scrollToRow(at: bottomIndexPath, at: .bottom, animated: false)
        }
    }
    
}
