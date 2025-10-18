//
//  SettingsViewController.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 12.10.25.
//

import UIKit
import SnapKit

final class SettingsViewController: BaseViewController {
    
    private lazy var picker: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.backgroundColor = .clear
        return picker
    }()
    
    private let currencies = ["USD", "EUR", "AZN", "RUB"]
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Currency"
        label.font = .systemFont(ofSize: 20, weight: .semibold)
        label.textColor = .white
        label.textAlignment = .center
        return label
    }()
    
    private lazy var logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log out", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.addTarget(self, action: #selector(didLogOut), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Settings"
        
        setupUI()
    }
    
    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(picker)
        view.addSubview(logoutButton)
        
        titleLabel.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(24)
            make.centerX.equalToSuperview()
        }
        
        picker.snp.makeConstraints { make in
            make.top.equalTo(titleLabel.snp.bottom).offset(36)
            make.horizontalEdges.equalToSuperview()
            make.height.equalTo(200)
        }
        
        logoutButton.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(36)
            make.centerX.equalToSuperview()
            make.height.equalTo(48)
        }
    }
    
    @objc
    private func didLogOut() {
        try? AppDependencies.shared.authService.signOut()
        (UIApplication.shared.connectedScenes.first?.delegate as? SceneDelegate)?.coordinator?.start()
    }
}

extension SettingsViewController: UIPickerViewDataSource, UIPickerViewDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        NSAttributedString(string: currencies[row], attributes: [.foregroundColor: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        AppDependencies.shared.settings.currencyCode = currencies[row]
        
        let alert = UIAlertController(title: nil, message: "Currency: \(currencies[row])", preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak alert] in
            alert?.dismiss(animated: true)
        }
    }
}
