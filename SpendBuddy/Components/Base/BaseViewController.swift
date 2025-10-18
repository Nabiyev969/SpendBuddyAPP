//
//  BaseViewController.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 12.10.25.
//

import UIKit

class BaseViewController: UIViewController {
    
    private var gradientLayer: CAGradientLayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .dark
        view.backgroundColor = .black
        
        let gradient = CAGradientLayer()
        gradient.colors = [UIColor.black.cgColor,
                           UIColor(red: 20/255, green: 20/255, blue: 30/255, alpha: 1).cgColor]
        gradient.locations = [0, 1]
        
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }
}
