//
//  MainTabBarController.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 12.10.25.
//

import UIKit

final class MainTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .dark
        tabBar.barStyle = .black
        tabBar.isTranslucent = true
        tabBar.tintColor = .systemIndigo
        tabBar.unselectedItemTintColor = UIColor.white.withAlphaComponent(0.6)
    }
    
    func setViewControllers(_ vcs: [UIViewController]) {
            super.setViewControllers(vcs, animated: false)
        }
}
