//
//  OnboardingPageViewController.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 21.10.25.
//

import UIKit
import SnapKit
import Lottie

struct OnboardingPage {
    let animation: String
    let title: String
    let subtitle: String
}

final class OnboardingPageViewController: UIViewController {
    
    private let page: OnboardingPage
    
    private let animationView: LottieAnimationView = {
        let view = LottieAnimationView()
        view.loopMode = .loop
        view.contentMode = .scaleAspectFit
        view.backgroundBehavior = .pauseAndRestore
        return view
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = .systemFont(ofSize: 24, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white.withAlphaComponent(0.8)
        label.font = .systemFont(ofSize: 15)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    init(page: OnboardingPage) {
        self.page = page
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(animationView)
        view.addSubview(titleLabel)
        view.addSubview(subtitleLabel)
        
        animationView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(32)
            make.centerX.equalToSuperview()
            make.width.lessThanOrEqualTo(view.snp.width).multipliedBy(0.8)
            make.height.equalTo(animationView.snp.width)
        }
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(animationView.snp.bottom).offset(20)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        
        subtitleLabel.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(24)
        }
        
        titleLabel.text = page.title
        subtitleLabel.text = page.subtitle
        
        if let animation = LottieAnimation.named(page.animation) {
            animationView.animation = animation
            animationView.play()
        } else {
            animationView.isHidden = true
        }
    }
}
