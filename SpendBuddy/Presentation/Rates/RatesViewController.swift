//
//  RatesViewController.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 22.10.25.
//

import UIKit
import SnapKit

final class RatesViewController: BaseViewController {
    
    private let vm: RatesViewModel
    
    private let header: UILabel = {
        let label = UILabel()
        label.text = "Live currency rates"
        label.textColor = .white
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 22, weight: .bold)
        return label
    }()
    
    private lazy var baseControl: UISegmentedControl = {
        let control = UISegmentedControl(items: Currency.allCases.map(\.title))
        control.selectedSegmentIndex = Currency.allCases.firstIndex(of: vm.base) ?? 0
        control.selectedSegmentTintColor = .systemIndigo
        control.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        control.setTitleTextAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.8)], for: .normal)
        control.addTarget(self, action: #selector(onBaseChanged), for: .valueChanged)
        return control
    }()
    
    private lazy var amountField: UITextField = {
        let field = UITextField()
        field.keyboardType = .decimalPad
        field.text = vm.amountText
        field.textColor = .white
        field.attributedPlaceholder = NSAttributedString(string: "Amount in \(vm.base.rawValue)",
                                                         attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.4)])
        field.backgroundColor = .white.withAlphaComponent(0.08)
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        field.leftView = UIView(frame: .init(x: 0, y: 0, width: 12, height: 0))
        field.leftViewMode = .always
        field.addTarget(self, action: #selector(onAmountChanged), for: .editingChanged)
        return field
    }()
    
    private lazy var table: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = .clear
        table.separatorColor = .white.withAlphaComponent(0.15)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    private lazy var refreshButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Refresh", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemIndigo
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(onRefresh), for: .touchUpInside)
        return button
    }()
    
    private let loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.hidesWhenStopped = true
        loader.color = .white
        return loader
    }()
    
    init(viewModel: RatesViewModel) {
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "Rates"
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNav()
        setupUI()
        bind()
        
        Task { [weak self] in
            await self?.vm.reload()
            self?.table.reloadData()
        }
    }
    
    private func setupNav() {
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
                    .foregroundColor: UIColor.systemIndigo,
                    .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
                ]
        appearance.backgroundColor = .clear
        navigationItem.standardAppearance = appearance
    }
    
    private func setupUI() {
        
        [header, baseControl, amountField, refreshButton, table, loader].forEach(view.addSubview)
        
        header.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(10)
            make.horizontalEdges.equalToSuperview().inset(16)
        }
        baseControl.snp.makeConstraints { make in
            make.top.equalTo(header.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.greaterThanOrEqualTo(240)
        }
        amountField.snp.makeConstraints { make in
            make.top.equalTo(baseControl.snp.bottom).offset(12)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(48)
        }
        refreshButton.snp.makeConstraints { make in
            make.top.equalTo(amountField.snp.bottom).offset(10)
            make.horizontalEdges.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        table.snp.makeConstraints { make in
            make.top.equalTo(refreshButton.snp.bottom).offset(8)
            make.leading.trailing.bottom.equalTo(view.safeAreaLayoutGuide)
        }
        loader.snp.makeConstraints { make in
            make.center.equalToSuperview()
        }
    }
    
    private func bind() {
        vm.onRowsChanged = { [weak self] in
            self?.table.reloadData()
        }
    }
    
    @objc
    private func onBaseChanged() {
        let index = baseControl.selectedSegmentIndex
        let newBase = Currency.allCases[index]
        vm.base = newBase
        amountField.attributedPlaceholder = NSAttributedString(string: "Amount in \(newBase.rawValue)",
                                                               attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.4)])
    }
    
    @objc
    private func onAmountChanged() {
        vm.amountText = amountField.text ?? ""
    }
    
    @objc
    private func onRefresh() {
        loader.startAnimating()
        Task { [weak self] in
            await self?.vm.reload()
            self?.loader.stopAnimating()
            if let msg = self?.vm.error {
                let alert = UIAlertController(title: "Error", message: msg, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .default))
                self?.present(alert, animated: true)
            }
        }
    }
}

extension RatesViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        vm.rows.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let row = vm.rows[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .white.withAlphaComponent(0.06)
        cell.layer.cornerRadius = 10
        cell.layer.masksToBounds = true
        cell.textLabel?.numberOfLines = 0
        
        let rateText = "1 \(vm.base.rawValue) = \(String(format: "%.4f", row.rate)) \(row.code)"
        
        let convertedText: String
        if let v = row.converted {
            convertedText = "≈ \(vm.formatted(amount: v, code: row.code))"
        } else {
            convertedText = ""
        }
        
        let string = NSMutableAttributedString(string: rateText + (convertedText.isEmpty ? "" : "\n" + convertedText))
        string.addAttributes([.foregroundColor: UIColor.white,
                              .font: UIFont.systemFont(ofSize: 16, weight: .semibold)],
                             range: NSRange(location: 0, length: rateText.count))
        
        if !convertedText.isEmpty {
            string.addAttributes([.foregroundColor: UIColor.white.withAlphaComponent(0.8),
                                  .font: UIFont.systemFont(ofSize: 13)],
                                 range: NSRange(location: rateText.count + 1, length: convertedText.count))
        }
        cell.textLabel?.attributedText = string
        return cell
    }
}
