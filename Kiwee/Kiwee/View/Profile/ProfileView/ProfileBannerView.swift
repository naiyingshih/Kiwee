//
//  ProfileBannerView.swift
//  Kiwee
//
//  Created by NY on 2024/4/18.
//

import UIKit

protocol ProfileBanneViewDelegate: AnyObject {
    func presentManageVC()
    func presentPostVC()
    func presentHelpPage()
    func logoutAccount()
    func removeAccount()
}

class ProfileBannerView: UIView {
    
    weak var delegate: ProfileBanneViewDelegate?
    
    lazy var countDownLabel: UILabel = {
        let label = UILabel()
        label.applyTitle(size: 16, color: .white)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var settingButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "gearshape"), for: .normal)
        button.tintColor = .white
        button.showsMenuAsPrimaryAction = true
        button.menu = UIMenu(children: [
            UIAction(title: "飲食指南", image: UIImage(systemName: "questionmark.circle"), handler: { _ in
                print("Select Help")
                self.delegate?.presentHelpPage()
            }),
            UIAction(title: "登出", image: UIImage(systemName: "rectangle.portrait.and.arrow.right"), handler: { _ in
                print("log out pressed")
                self.delegate?.logoutAccount()
            }),
            UIAction(title: "刪除帳戶", image: UIImage(systemName: "trash"), attributes: .destructive, handler: { _ in
                print("remove account pressed")
                self.delegate?.removeAccount()
            })
        ])
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var profileImage: UIImageView = {
        let imageView = UIImageView()
        imageView.tintColor = KWColor.lightY
        imageView.image = UIImage(named: "User")
//        imageView.image = UIImage(systemName: "person.crop.circle")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.applyTitle(size: 20, color: KWColor.lightY)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var targetLabel: UILabel = {
        let label = UILabel()
        label.applyContent(size: 16, color: .white)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var BMILabel: UILabel = {
        let label = UILabel()
        label.applyContent(size: 14, color: .white)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var RDALabel: UILabel = {
        let label = UILabel()
        label.applyContent(size: 14, color: .white)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = KWColor.darkB
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var outlineView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.layer.borderWidth = 2
        view.layer.borderColor = KWColor.darkG.cgColor
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "紀錄管理"
        label.applyContent(size: 17, color: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var manageButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "chevron.forward"), for: .normal)
        button.tintColor = KWColor.darkG
        button.addTarget(self, action: #selector(manageProfile), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var dividingLine: UIView = {
        let line = UIView()
        line.backgroundColor = .gray
        line.translatesAutoresizingMaskIntoConstraints = false
        return line
    }()
    
    lazy var cardOutlineView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 10
        view.backgroundColor = KWColor.lightG
        view.isUserInteractionEnabled = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    lazy var menuLabel: UILabel = {
        let label = UILabel()
        label.text = "我的菜單"
        label.applyContent(size: 17, color: .black)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var addPostButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(systemName: "plus"), for: .normal)
        button.tintColor = KWColor.darkB
        button.addTarget(self, action: #selector(cameraButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // MARK: - Init
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
        setupConstraints()
        setupViewsInteraction()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupViews()
        setupConstraints()
        setupViewsInteraction()
    }
    
    // MARK: - UI setting functions
    private func setupViews() {
        self.addSubview(backgroundView)
        backgroundView.addSubview(countDownLabel)
        backgroundView.addSubview(settingButton)
        backgroundView.addSubview(profileImage)
        backgroundView.addSubview(nameLabel)
        backgroundView.addSubview(targetLabel)
        backgroundView.addSubview(BMILabel)
        backgroundView.addSubview(RDALabel)
        self.addSubview(outlineView)
        outlineView.addSubview(titleLabel)
        outlineView.addSubview(manageButton)
        self.addSubview(dividingLine)
        self.addSubview(cardOutlineView)
        cardOutlineView.addSubview(menuLabel)
        cardOutlineView.addSubview(addPostButton)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            backgroundView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            backgroundView.topAnchor.constraint(equalTo: self.topAnchor),
            backgroundView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            backgroundView.bottomAnchor.constraint(equalTo: RDALabel.bottomAnchor, constant: 8),
            
            countDownLabel.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            countDownLabel.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            
            settingButton.centerYAnchor.constraint(equalTo: countDownLabel.centerYAnchor),
            settingButton.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -20),
            settingButton.widthAnchor.constraint(equalToConstant: 30),
            settingButton.heightAnchor.constraint(equalToConstant: 30),
            
            profileImage.topAnchor.constraint(equalTo: countDownLabel.bottomAnchor, constant: 16),
            profileImage.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            profileImage.heightAnchor.constraint(equalToConstant: 80),
            profileImage.widthAnchor.constraint(equalToConstant: 80),
            
            nameLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor, constant: -16),
            nameLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: -30),
            
            targetLabel.centerYAnchor.constraint(equalTo: profileImage.centerYAnchor, constant: 16),
            targetLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            
            BMILabel.centerYAnchor.constraint(equalTo: targetLabel.centerYAnchor),
            BMILabel.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 100),

            RDALabel.leadingAnchor.constraint(equalTo: BMILabel.leadingAnchor),
            RDALabel.topAnchor.constraint(equalTo: BMILabel.bottomAnchor, constant: 4),
            
            outlineView.topAnchor.constraint(equalTo: backgroundView.bottomAnchor, constant: 8),
            outlineView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            outlineView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            outlineView.heightAnchor.constraint(equalToConstant: 45),
            
            titleLabel.leadingAnchor.constraint(equalTo: outlineView.leadingAnchor, constant: 24),
            titleLabel.centerYAnchor.constraint(equalTo: outlineView.centerYAnchor),
            
            manageButton.trailingAnchor.constraint(equalTo: outlineView.trailingAnchor, constant: -24),
            manageButton.centerYAnchor.constraint(equalTo: outlineView.centerYAnchor),
            
            dividingLine.topAnchor.constraint(equalTo: outlineView.bottomAnchor, constant: 10),
            dividingLine.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            dividingLine.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.9),
            dividingLine.heightAnchor.constraint(equalToConstant: 1),
            
            cardOutlineView.topAnchor.constraint(equalTo: dividingLine.bottomAnchor, constant: 10),
            cardOutlineView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 32),
            cardOutlineView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -32),
            cardOutlineView.heightAnchor.constraint(equalTo: outlineView.heightAnchor),
            cardOutlineView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -8),
            
            menuLabel.leadingAnchor.constraint(equalTo: cardOutlineView.leadingAnchor, constant: 24),
            menuLabel.centerYAnchor.constraint(equalTo: cardOutlineView.centerYAnchor),
            
            addPostButton.trailingAnchor.constraint(equalTo: cardOutlineView.trailingAnchor, constant: -24),
            addPostButton.centerYAnchor.constraint(equalTo: cardOutlineView.centerYAnchor)
        ])
    }
    
    private func setupViewsInteraction() {
        let manageTapGesture = UITapGestureRecognizer(target: self, action: #selector(manageProfile))
        outlineView.addGestureRecognizer(manageTapGesture)
        
        let addTapGesture = UITapGestureRecognizer(target: self, action: #selector(cameraButtonTapped))
        cardOutlineView.addGestureRecognizer(addTapGesture)
    }
    
    @objc func manageProfile() {
        guard let delegate = delegate else { return }
        delegate.presentManageVC()
    }
    
    @objc func cameraButtonTapped() {
        guard let delegate = delegate else { return }
        delegate.presentPostVC()
    }
    
    func updateView(with userData: UserData) {
        
        let RDA = BMRUtility.calculateBMR(with: userData)
        let formattedRDA = String(format: "%.0f", RDA)
        UserDefaults.standard.set(formattedRDA, forKey: "RDA")

        let BMI = (userData.updatedWeight ?? userData.initialWeight) / (userData.height * userData.height) * 10000
        let formattedBMI = String(format: "%.1f", BMI)
        
        nameLabel.text = userData.name
        
        let goalTitles: [Int: String] = [
            0: "減重",
            1: "增重",
            2: "維持體重"
        ]
        if let goalTitle = goalTitles[userData.goal] {
            targetLabel.text = "\(goalTitle)中..."
        }
            
        BMILabel.text = "BMI:   \(formattedBMI)"
        RDALabel.text = "RDA:  \(formattedRDA) kcal"

        let today = Date()
        let calendar = Calendar.current
       
        let todayComponents = calendar.dateComponents([.year, .month, .day], from: today)
        let achievementTimeComponents = calendar.dateComponents([.year, .month, .day], from: userData.achievementTime)

        // Convert components back to dates for comparison
        let dateOnlyToday = calendar.date(from: todayComponents)!
        let dateOnlyAchievementTime = calendar.date(from: achievementTimeComponents)!

        if dateOnlyToday < dateOnlyAchievementTime {
            // If today is before the achievementTime
            let components = calendar.dateComponents([.day], from: dateOnlyToday, to: dateOnlyAchievementTime)
            if let remainDay = components.day {
                countDownLabel.text = "距離達標還有：\(remainDay) 天"
            } else {
                return
            }
        } else if dateOnlyToday > dateOnlyAchievementTime {
            // If the achievementTime has passed
            let components = calendar.dateComponents([.day], from: dateOnlyToday, to: dateOnlyAchievementTime)
            if let remainDay = components.day {
                countDownLabel.text = "已過目標時間：\(remainDay) 天"
            } else {
                return
            }
        } else {
            // If today is the achievementTime
            countDownLabel.text = "今天是達標日！\n您可以前往紀錄管理設定新目標"
        }
    }
    
}
