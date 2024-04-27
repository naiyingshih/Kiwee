//
//  WelcomeViewController.swift
//  Kiwee
//
//  Created by NY on 2024/4/26.
//

import UIKit
import Lottie

class WelcomeViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.hexStringToUIColor(hex: "BEDB39")
        displayLabelWithFadeIn()
        displayRibbons()
    }
    
    func displayLabelWithFadeIn() {
        // Create the label
        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 300, height: 50)
        label.text = "Welcome!"
        label.font = UIFont(name: "Optima", size: 60)
        label.textColor = .systemOrange
        label.center = view.center
        label.textAlignment = .center
        label.alpha = 0
        
        view.addSubview(label)
        UIView.animate(withDuration: 2.0) {
            label.alpha = 1.0
        }
    }
    
    func displayRibbons() {
        let ribbonsView = LottieAnimationView(name: "Ribbons_animation")
        ribbonsView.frame = CGRect(x: 0, y: 0, width: 400, height: 400)
        ribbonsView.center = self.view.center
        ribbonsView.contentMode = .scaleAspectFill
        view.addSubview(ribbonsView)
        ribbonsView.play()
        ribbonsView.animationSpeed = 0.9
        ribbonsView.loopMode = .loop
    }
}
