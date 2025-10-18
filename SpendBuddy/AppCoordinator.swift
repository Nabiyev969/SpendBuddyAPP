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

    private let tab = MainTabBarController()

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
        
        let vm = AuthViewModel(auth: deps.authService)

        vm.onAuthSuccess = { [weak self] in
            self?.showMainTabs(animated: true)
        }
        vm.onRegisterSuccess = { }

        let vc = AuthViewController(viewModel: vm)
        let nav = UINavigationController(rootViewController: vc)
        applyNavAppearance(to: nav)

        setRoot(nav, animated: false)
    }

    func showMainTabs(animated: Bool = false) {
        
        let homeNav = buildHomeNav()
        let listNav = buildListNav()
        let settingsNav = buildSettingsNav()

        tab.setViewControllers([homeNav, listNav, settingsNav])

        setRoot(tab, animated: animated)
    }

    // MARK: - Builders
    private func buildHomeNav() -> UINavigationController {
        let vm = HomeViewModel(
            repo: deps.transactionsRepository,
            summary: deps.summaryCalculator,
            userId: deps.authService.currentUserId
        )
        let vc = HomeViewController(viewModel: vm)
        let nav = UINavigationController(rootViewController: vc)
        applyNavAppearance(to: nav)
        nav.tabBarItem = UITabBarItem(
            title: "Home",
            image: UIImage(systemName: "house"),
            selectedImage: UIImage(systemName: "house.fill")
        )
        return nav
    }

    private func buildListNav() -> UINavigationController {
        let vm = TransactionsListViewModel(
            repo: deps.transactionsRepository,
            userId: deps.authService.currentUserId ?? "unknown"
        )
        let vc = TransactionsListViewController(viewModel: vm)
        let nav = UINavigationController(rootViewController: vc)
        applyNavAppearance(to: nav)
        nav.tabBarItem = UITabBarItem(
            title: "All",
            image: UIImage(systemName: "list.bullet"),
            selectedImage: UIImage(systemName: "list.bullet")
        )
        return nav
    }

    private func buildSettingsNav() -> UINavigationController {
        let vc = SettingsViewController()
        let nav = UINavigationController(rootViewController: vc)
        applyNavAppearance(to: nav)
        nav.tabBarItem = UITabBarItem(
            title: "Settings",
            image: UIImage(systemName: "gearshape"),
            selectedImage: UIImage(systemName: "gearshape.fill")
        )
        return nav
    }

    // MARK: - Appearance
    private func applyNavAppearance(to nav: UINavigationController) {
        let ap = UINavigationBarAppearance()
        ap.configureWithTransparentBackground()
        ap.titleTextAttributes = [
            .foregroundColor: UIColor.systemIndigo,
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        ap.largeTitleTextAttributes = [
            .foregroundColor: UIColor.systemIndigo,
            .font: UIFont.systemFont(ofSize: 34, weight: .bold)
        ]
        ap.backgroundColor = .clear

        nav.navigationBar.standardAppearance = ap
        nav.navigationBar.scrollEdgeAppearance = ap
        nav.navigationBar.compactAppearance = ap
        nav.navigationBar.tintColor = .systemIndigo
        nav.navigationBar.isTranslucent = true
        nav.navigationBar.barStyle = .black
    }

    // MARK: - Root swap
    private func setRoot(_ vc: UIViewController, animated: Bool) {
        guard animated, let snapshot = window.snapshotView(afterScreenUpdates: true) else {
            window.rootViewController = vc
            return
        }
        window.rootViewController = vc
        vc.view.addSubview(snapshot)
        UIView.transition(with: snapshot, duration: 0.25, options: .transitionCrossDissolve, animations: {
            snapshot.alpha = 0
        }, completion: { _ in
            snapshot.removeFromSuperview()
        })
    }
}
