//
//  ModuleBuilder.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 21.10.25.
//

import UIKit

enum ModuleBuilder {
    
    private static func applyNav(_ nav: UINavigationController) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemIndigo,
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        nav.navigationBar.standardAppearance = appearance
        nav.navigationBar.scrollEdgeAppearance = appearance
        nav.navigationBar.tintColor = .systemIndigo
        nav.navigationBar.barStyle = .black
        nav.navigationBar.isTranslucent = true
    }
    
    static func makeHome() -> UINavigationController {
        let deps = AppDependencies.shared
        let vm = HomeViewModel(repo: deps.transactionsRepository,
                               summary: deps.summaryCalculator,
                               userId: deps.authService.currentUserId)
        let vc = HomeViewController(viewModel: vm)
        let nav = UINavigationController(rootViewController: vc)
        applyNav(nav)
        nav.tabBarItem = UITabBarItem(title: "Home",
                                      image: UIImage(systemName: "house"),
                                      selectedImage: UIImage(systemName: "house.fill"))
        return nav
    }
    
    static func makeTransactionsList() -> UINavigationController {
            let deps = AppDependencies.shared
            let vm = TransactionsListViewModel(repo: deps.transactionsRepository,
                                               userId: deps.authService.currentUserId ?? "unknown")
            let vc = TransactionsListViewController(viewModel: vm)
            let nav = UINavigationController(rootViewController: vc)
            applyNav(nav)
            nav.tabBarItem = UITabBarItem(title: "All",
                                          image: UIImage(systemName: "list.bullet"),
                                          selectedImage: UIImage(systemName: "list.bullet"))
            return nav
        }

    static func makeStats() -> UINavigationController {
            let deps = AppDependencies.shared
            let vm = StatsViewModel(repo: deps.transactionsRepository,
                                    userId: deps.authService.currentUserId ?? "unknown")
            let vc = StatsViewController(viewModel: vm)
            let nav = UINavigationController(rootViewController: vc)
            applyNav(nav)
            nav.tabBarItem = UITabBarItem(title: "Stats",
                                          image: UIImage(systemName: "chart.pie"),
                                          selectedImage: UIImage(systemName: "chart.pie.fill"))
            return nav
        }
    
    static func makeSettings() -> UINavigationController {
            let vc = SettingsViewController()
            let nav = UINavigationController(rootViewController: vc)
            applyNav(nav)
            nav.tabBarItem = UITabBarItem(title: "Settings",
                                          image: UIImage(systemName: "gearshape"),
                                          selectedImage: UIImage(systemName: "gearshape.fill"))
            return nav
        }
    
    static func makeAddEdit(existing: Transaction? = nil) -> UIViewController {
            let deps = AppDependencies.shared
            let vm = AddEditViewModel(repo: deps.transactionsRepository,
                                      userId: deps.authService.currentUserId ?? "unknown",
                                      existing: existing)
            return AddEditViewController(viewModel: vm)
        }
    
    static func makeRates() -> UINavigationController {
        let deps = AppDependencies.shared
        let base = Currency(rawValue: deps.settings.currencyCode) ?? .USD
        let vm = RatesViewModel(service: deps.rates, initialBase: base)
        let vc = RatesViewController(viewModel: vm)
        let nav = UINavigationController(rootViewController: vc)
        applyNav(nav)
        nav.tabBarItem = UITabBarItem(title: "Rates",
                                      image: UIImage(systemName: "dollarsign.arrow.circlepath"),
                                      selectedImage: UIImage(systemName: "dollarsign.arrow.circlepath"))
        return nav
    }
}
