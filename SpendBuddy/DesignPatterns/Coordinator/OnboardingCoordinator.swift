//
//  OnboardingCoordinator.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 21.10.25.
//

import UIKit

final class OnboardingCoordinator {
    
    private let window: UIWindow
    var onFinish: (() -> ())?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let vc = OnboardingViewController()
        let nav = UINavigationController(rootViewController: vc)
        nav.navigationBar.isHidden = true
        
        vc.onFinish = { [weak self] in
            self?.onFinish?()
        }
        
        if let snapShot = window.snapshotView(afterScreenUpdates: true) {
            window.rootViewController = nav
            window.makeKeyAndVisible()
            nav.view.addSubview(snapShot)
            UIView.transition(with: snapShot, duration: 0.25, options: .transitionCrossDissolve, animations: {
                snapShot.alpha = 0
            }, completion: { _ in
                snapShot.removeFromSuperview() })
        } else {
            window.rootViewController = nav
            window.makeKeyAndVisible()
        }
    }
}
