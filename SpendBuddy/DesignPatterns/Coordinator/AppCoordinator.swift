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
    private var onboardingCoordinator: OnboardingCoordinator?
    
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
            self?.showOnboardingThenTabs()
        }
        authCoordinator = coordinator
        tabsCoordinator = nil
        onboardingCoordinator = nil
        coordinator.start()
    }
    
    private func showOnboardingThenTabs() {
        
        let onboarding = OnboardingCoordinator(window: window)
        onboardingCoordinator = onboarding
        authCoordinator = nil
        
        onboarding.onFinish = { [weak self] in
            self?.onboardingCoordinator = nil
            self?.showMainTabs(animated: true)
        }
        onboarding.start()
    }
    
    func showMainTabs(animated: Bool = false) {
        
        let coordinator = TabsCoordinator(window: window)
        tabsCoordinator = coordinator
        authCoordinator = nil
        coordinator.start()
    }
}
