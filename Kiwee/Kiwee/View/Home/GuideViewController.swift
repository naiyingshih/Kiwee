//
//  GuideView.swift
//  Kiwee
//
//  Created by NY on 2024/4/30.
//

import UIKit

class GuideViewController: UIViewController, UIScrollViewDelegate {
    
    var startbuttonTapped: (() -> Void)?
    
    var currentIndex: Int = 0 {
        didSet {
            // 首、尾頁按鈕文字不同
            if currentIndex == 0 {
                pillButton.isHidden = false
                controlStackView.isHidden = true
                pillButton.setTitle("開始探索", for: .normal)
            }
            // 除了首、尾頁需要PillButton，其餘則是PageControl配CircleButton
            else if currentIndex > 0 && currentIndex < tutorialImages.count - 1 {
                pillButton.isHidden = true
                controlStackView.isHidden = false
            } else {
                pillButton.isHidden = false
                controlStackView.isHidden = true
                pillButton.setTitle("旅程開始", for: .normal)
            }
        }
    }
    
    let tutorialImages = ["guide_01", "guide_02", "guide_03"]
    var pageViews = [UIView]()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.isPagingEnabled = true
//        scrollView.isScrollEnabled = false
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    lazy var stackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 0
        stackView.distribution = .fillEqually
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var controlStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 0
        stackView.distribution = .equalSpacing
        stackView.isHidden = true
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.pageIndicatorTintColor = .darkGray
        pageControl.currentPageIndicatorTintColor = .white
        pageControl.backgroundStyle = .minimal
        pageControl.numberOfPages = tutorialImages.count
        pageControl.currentPage = currentIndex
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    lazy var circleButton: UIButton = {
        let button = UIButton()
        if let image = UIImage(systemName: "arrow.right") {
            button.setImage(image.withRenderingMode(.alwaysTemplate), for: .normal)
            button.tintColor = .black
        }
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.backgroundColor = .white
        button.layer.cornerRadius = 20
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var pillButton: UIButton = {
        let button = UIButton()
        button.setTitle("開始探索", for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 18
        button.addTarget(self, action: #selector(buttonPressed), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "004358")
        setupUI()
        addPageView()
    }
    
    func setupUI() {
        view.addSubview(scrollView)
        scrollView.delegate = self
        scrollView.addSubview(stackView)
        
        view.addSubview(controlStackView)
        // 加東西到stackView上是用addArrangedSubview不是addSubview!
        controlStackView.addArrangedSubview(pageControl)
        controlStackView.addArrangedSubview(circleButton)
        
        view.addSubview(pillButton)
    
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            
            controlStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            controlStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            controlStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            controlStackView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -12),
            
            circleButton.widthAnchor.constraint(equalToConstant: 40),
            circleButton.heightAnchor.constraint(equalToConstant: 40),
            
            pillButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            pillButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 36),
            pillButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -36),
            pillButton.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -8),
            pillButton.heightAnchor.constraint(equalToConstant: 36)
        ])

    }
    
    @objc func buttonPressed() {
        if currentIndex < pageViews.count - 1 {
            currentIndex += 1
            scrollView.setContentOffset(pageViews[currentIndex].frame.origin, animated: true)
            
        } else if currentIndex == pageViews.count - 1 {
            startbuttonTapped?()
        }
        pageControl.currentPage = currentIndex
    }
    
    func addPageView() {
        
        for image in tutorialImages {
            
            let pageView = UIView()
            
            let imageView: UIImageView = {
                let imageView = UIImageView(image: UIImage(named: image))
                imageView.contentMode = .scaleAspectFill
                imageView.clipsToBounds = true
                return imageView
            }()
            
            pageView.addSubview(imageView)
            imageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                imageView.topAnchor.constraint(equalTo: pageView.topAnchor, constant: 8),
                imageView.leadingAnchor.constraint(equalTo: pageView.leadingAnchor, constant: 8),
                imageView.trailingAnchor.constraint(equalTo: pageView.trailingAnchor, constant: -8),
                imageView.bottomAnchor.constraint(equalTo: pageView.bottomAnchor, constant: -50)
            ])
            
            stackView.addArrangedSubview(pageView)
            pageView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                pageView.widthAnchor.constraint(equalTo: scrollView.frameLayoutGuide.widthAnchor),
                pageView.heightAnchor.constraint(equalTo: scrollView.frameLayoutGuide.heightAnchor)
            ])
            
            pageViews.append(pageView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let currentPage = Int(scrollView.contentOffset.x / pageWidth)
        currentIndex = currentPage
        pageControl.currentPage = currentPage
        print(currentPage)
    }
    
}
