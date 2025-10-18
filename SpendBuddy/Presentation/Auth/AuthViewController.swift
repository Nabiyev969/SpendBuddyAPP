//
//  AuthViewController.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 07.10.25.
//

import UIKit
import SnapKit

final class AuthViewController: BaseViewController {
    
    private let viewModel: AuthViewModel
        
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "SpendBuddy"
        label.font = .systemFont(ofSize: 34, weight: .bold)
        label.textColor = .systemIndigo
        label.textAlignment = .center
        return label
    }()
    
    private let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Easily track your expenses"
        label.font = .systemFont(ofSize: 15)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let email: UITextField = {
        let email = UITextField()
        email.placeholder = "Email"
        email.keyboardType = .emailAddress
        email.backgroundColor = .white.withAlphaComponent(0.08)
        email.textColor = .white
        email.layer.cornerRadius = 12
        email.layer.borderWidth = 1
        email.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        email.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        email.leftViewMode = .always
        email.attributedPlaceholder = NSAttributedString(string: "Email", attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.4)])
        return email
    }()
    
    private let pass: UITextField = {
        let pass = UITextField()
        pass.placeholder = "Password"
        pass.isSecureTextEntry = true
        pass.backgroundColor = .white.withAlphaComponent(0.08)
        pass.textColor = .white
        pass.layer.cornerRadius = 12
        pass.layer.borderWidth = 1
        pass.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        pass.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        pass.leftViewMode = .always
        pass.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.4)])
        return pass
    }()
    
    private lazy var loginBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: #selector(onLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var registerBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Register", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .clear
        button.layer.cornerRadius = 12
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.white.withAlphaComponent(0.3).cgColor
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: #selector(onRegister), for: .touchUpInside)
        return button
    }()
    
    private let stack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20)
        return stack
    }()
    
    private lazy var loginWithApple: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.apple, for: .normal)
        button.tintColor = .white
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(didTapAppleLogin), for: .touchUpInside)
        return button
    }()
    
    private lazy var loginWithGoogle: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(.googleSymbol, for: .normal)
        button.tintColor = .red
        button.backgroundColor = .clear
        button.addTarget(self, action: #selector(didTapGoogleLogin), for: .touchUpInside)
        return button
    }()
    
    private let loginStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .horizontal
        stack.spacing = 16
        stack.alignment = .fill
        stack.distribution = .equalSpacing
        return stack
    }()
    
    private let loader = LottieView(name: "loader")
    
    init(viewModel: AuthViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        viewModel.onRegisterSuccess = { [weak self] in
            self?.presentRegistrationSuccess()
        }
    }
    
    private func setupUI() {
        view.addSubview(stack)
        [titleLabel, subtitleLabel, email, pass, loginBtn, registerBtn, loader, loginStack].forEach(stack.addArrangedSubview)
        [loginWithApple, loginWithGoogle].forEach(loginStack.addArrangedSubview)
        
        
        stack.setCustomSpacing(6, after: titleLabel)
        stack.setCustomSpacing(20, after: subtitleLabel)
        
        stack.snp.makeConstraints { make in
            make.leading.trailing.equalToSuperview().inset(24)
            make.centerY.equalToSuperview()
        }
        
        [email, pass].forEach { textField in
            textField.snp.makeConstraints { make in
                make.height.equalTo(48)
            }
        }
        
        [loginBtn, registerBtn].forEach { button in
            button.snp.makeConstraints { make in
                make.height.equalTo(48)
            }
        }
        
        [loginWithApple, loginWithGoogle].forEach { button in
            button.snp.makeConstraints { make in
                make.height.equalTo(48)
                make.width.equalTo(48)
            }
        }
        
        loader.isHidden = true
    }
    
    private func setLoading(_ loading: Bool) {
        loader.isHidden = !loading
    }
    
    private func refreshLoadingAndErrors() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) { [weak self] in
            guard let self else { return }
            self.setLoading(self.viewModel.isLoading)
            if let msg = self.viewModel.errorMessage {
                let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(alert, animated: true)
            }
        }
    }
    
    private func presentRegistrationSuccess() {
        setLoading(false)
        
        let alert = UIAlertController(title: "Registration Successful",
                                      message: "Welcome to SpendBuddy!",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak self] _ in
            self?.viewModel.onAuthSuccess?()
        }))
        present(alert, animated: true)
    }
    
    @objc
    private func onLogin() {
        setLoading(true)
        viewModel.login(email: email.text ?? "", password: pass.text ?? "")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.refreshLoadingAndErrors()
        }
    }
    
    @objc
    private func onRegister() {
        setLoading(true)
        viewModel.register(email: email.text ?? "", password: pass.text ?? "")
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.refreshLoadingAndErrors()
        }
    }
    
    @objc
    private func didTapAppleLogin() {
        viewModel.loginWithApple(presenting: self)
    }
    
    @objc
    private func didTapGoogleLogin() {
        viewModel.loginWithGoogle(presenting: self)
    }
}
