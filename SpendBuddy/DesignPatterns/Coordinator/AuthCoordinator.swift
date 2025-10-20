//
//  AuthCoordinator.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 20.10.25.
//

import UIKit

final class AuthCoordinator: BaseCoordinator {
    
    private let window: UIWindow
    private let deps = AppDependencies.shared
    
    var onFinish: (() -> ())?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    override func start() {
        let vm = AuthViewModel(auth: deps.authService)
        vm.onAuthSuccess = { [weak self] in
            self?.onFinish?()
        }
        let vc = AuthViewController(viewModel: vm)
        let nav = UINavigationController(rootViewController: vc)
        applyNavAppearance(nav)
        setRoot(nav)
    }
    
    private func setRoot(_ root: UIViewController) {
        window.rootViewController = root
        window.makeKeyAndVisible()
    }
    
    private func applyNavAppearance(_ nav: UINavigationController) {
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
}
