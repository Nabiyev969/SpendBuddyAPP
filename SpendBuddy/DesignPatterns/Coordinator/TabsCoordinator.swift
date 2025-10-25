//
//  TabsCoordinator.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 20.10.25.
//

import UIKit

final class TabsCoordinator: BaseCoordinator {
    
    private let window: UIWindow
    private let deps = AppDependencies.shared
    private let tab = MainTabBarController()
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() {
        let home = ModuleBuilder.makeHome()
        let list = ModuleBuilder.makeTransactionsList()
        let stats = ModuleBuilder.makeStats()
        let rates = ModuleBuilder.makeRates()
        let settings = ModuleBuilder.makeSettings()
        
        tab.setViewControllers([home, list, stats, rates, settings])
        setRoot(tab)
    }
    
    private func setRoot(_ root: UIViewController) {
        if let snapshot = window.snapshotView(afterScreenUpdates: true) {
            window.rootViewController = root
            root.view.addSubview(snapshot)
            UIView.transition(with: snapshot, duration: 0.25, options: .transitionCrossDissolve, animations: {
                snapshot.alpha = 0
            }, completion: { _ in snapshot.removeFromSuperview() })
        } else {
            window.rootViewController = root
        }
        window.makeKeyAndVisible()
    }
}
