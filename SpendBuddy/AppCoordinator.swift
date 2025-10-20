//
//  AppCoordinator.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 06.10.25.
//

import UIKit

final class AppCoordinator {
    
    private let deps = AppDependencies.shared
    private let window: UIWindow
    private var authCoordinator: AuthCoordinator?
    private var tabsCoordinator: TabsCoordinator?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        if deps.authService.currentUserId == nil {
            showAuth()
        } else {
            showMainTabs()
        }
        window.makeKeyAndVisible()
    }
    
    private func showAuth() {
        
        let coordinator = AuthCoordinator(window: window)
        coordinator.onFinish = { [weak self] in
            self?.showMainTabs()
        }
        authCoordinator = coordinator
        tabsCoordinator = nil
        coordinator.start()
    }
    
    func showMainTabs(animated: Bool = false) {
        
        let coordinator = TabsCoordinator(window: window)
        tabsCoordinator = coordinator
        authCoordinator = nil
        coordinator.start()
    }
}
