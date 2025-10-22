//
//  OnboardingViewController.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 21.10.25.
//

import UIKit
import SnapKit
import Lottie

final class OnboardingViewController: BaseViewController {
    
    var onFinish: (() -> ())?
    
    private let pages: [OnboardingPage] = [
        .init(animation: "onboard1", title: "Track your spending", subtitle: "Log expenses in seconds and see where your money goes."),
        .init(animation: "onboard2", title: "Beautiful insights", subtitle: "Pie and bar charts help you spot trends instantly."),
        .init(animation: "onboard3", title: "Secure & synced", subtitle: "Sign in with Apple/Google. Your data stays with you.")
    ]
    
    private lazy var pageVC: UIPageViewController = {
        UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    }()
    
    private let pageControl: UIPageControl = {
        let page = UIPageControl()
        page.currentPage = 0
        page.numberOfPages = 3
        page.pageIndicatorTintColor = .white.withAlphaComponent(0.25)
        page.currentPageIndicatorTintColor = .systemIndigo
        return page
    }()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Next", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemIndigo
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.layer.cornerRadius = 12
        button.contentEdgeInsets = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        button.addTarget(self, action: #selector(onNext), for: .touchUpInside)
        return button
    }()
    
    private lazy var skipButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Skip", for: .normal)
        button.setTitleColor(.white.withAlphaComponent(0.9), for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 15)
        button.addTarget(self, action: #selector(onSkip), for: .touchUpInside)
        return button
    }()
    
    private var controllers: [OnboardingPageViewController] = []
    private var currentIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for p in pages {
            controllers.append(OnboardingPageViewController(page: p))
        }
        
        setupUI()
        updateButtons()
    }
    
    private func setupUI() {
        addChild(pageVC)
        view.addSubview(pageVC.view)
        pageVC.didMove(toParent: self)
        pageVC.dataSource = self
        pageVC.delegate = self
        pageVC.setViewControllers([controllers[0]], direction: .forward, animated: false)
        
        view.addSubview(pageControl)
        view.addSubview(nextButton)
        view.addSubview(skipButton)
        
        pageVC.view.snp.makeConstraints { make in
            make.top.leading.trailing.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(120)
        }
        
        pageControl.snp.makeConstraints { make in
            make.top.equalTo(pageVC.view.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
        }
        
        nextButton.snp.makeConstraints { make in
            make.top.equalTo(pageControl.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(48)
            make.width.greaterThanOrEqualTo(160)
        }
        
        skipButton.snp.makeConstraints { make in
            make.top.equalTo(nextButton.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
        }
    }
    
    private func updateButtons() {
        let last = (currentIndex == controllers.count - 1)
        nextButton.setTitle(last ? "Get Started" : "Next", for: .normal)
        skipButton.isHidden = last
    }
    
    @objc
    private func onNext() {
        if currentIndex < controllers.count - 1 {
            currentIndex += 1
            pageVC.setViewControllers([controllers[currentIndex]], direction: .forward, animated: true)
            pageControl.currentPage = currentIndex
            updateButtons()
        } else {
            onFinish?()
        }
    }
    
    @objc
    private func onSkip() {
        onFinish?()
    }
}

extension OnboardingViewController: UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let index = controllers.firstIndex(of: viewController as! OnboardingPageViewController), index > 0 else { return nil }
        return controllers[index - 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController,
                            viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let index = controllers.firstIndex(of: viewController as! OnboardingPageViewController), index < controllers.count - 1 else { return nil }
        return controllers[index + 1]
    }

    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed, let vc = pageViewController.viewControllers?.first as? OnboardingPageViewController,
              let index = controllers.firstIndex(of: vc) else { return }
        currentIndex = index
        pageControl.currentPage = index
        updateButtons()
    }
}
