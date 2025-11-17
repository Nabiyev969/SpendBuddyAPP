//
//  AddEditViewController.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 10.10.25.
//

import UIKit
import SnapKit

final class AddEditViewController: BaseViewController {
    private let vm: AddEditViewModel
    
    private let scrollView = UIScrollView()
    
    private let vStack: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 16
        stack.alignment = .fill
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20)
        return stack
    }()
    
    private lazy var amountField: UITextField = {
        let field = UITextField()
        field.placeholder = "Amount"
        field.keyboardType = .decimalPad
        field.delegate = self
        field.backgroundColor = .white.withAlphaComponent(0.08)
        field.textColor = .white
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        field.leftViewMode = .always
        field.attributedPlaceholder = NSAttributedString(string: "Amount", attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.4)])
        return field
    }()
    
    private let noteField: UITextField = {
        let field = UITextField()
        field.placeholder = "Note"
        field.backgroundColor = UIColor.white.withAlphaComponent(0.08)
        field.textColor = .white
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.white.withAlphaComponent(0.12).cgColor
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        field.leftViewMode = .always
        field.attributedPlaceholder = NSAttributedString(
            string: "Note",
            attributes: [.foregroundColor: UIColor.white.withAlphaComponent(0.4)]
        )
        return field
    }()
    
    private lazy var datePicker: UIDatePicker = {
        let picker = UIDatePicker()
        picker.datePickerMode = .dateAndTime
        picker.preferredDatePickerStyle = .wheels
        picker.tintColor = .white
        picker.addTarget(self, action: #selector(onDateChange), for: .valueChanged)
        return picker
    }()
    
    private lazy var categoryPicker: UIPickerView = {
        let picker = UIPickerView()
        picker.dataSource = self
        picker.delegate = self
        picker.backgroundColor = .clear
        return picker
    }()
    
    private lazy var saveBtn: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Save", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 12
        button.titleLabel?.font = .systemFont(ofSize: 17, weight: .semibold)
        button.addTarget(self, action: #selector(onSave), for: .touchUpInside)
        return button
    }()
    
    private let loader: UIActivityIndicatorView = {
        let loader = UIActivityIndicatorView(style: .large)
        loader.hidesWhenStopped = true
        loader.color = .white
        return loader
    }()
    
    private let categories = Category.allCases
    
    init(viewModel: AddEditViewModel) {
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = (vm.existing == nil) ? "Add Transaction" : "Edit Transaction"
        
        setupUI()
        setupNavBar()
        
        if let idx = categories.firstIndex(of: vm.category) {
            categoryPicker.selectRow(idx, inComponent: 0, animated: true)
        }
        loader.hidesWhenStopped = true
        
        amountField.text = vm.amountText
        noteField.text = vm.note
        datePicker.date = vm.date
        scrollView.showsVerticalScrollIndicator = false
        
        amountField.addTarget(self, action: #selector(onAmountChanged), for: .editingChanged)
        updateSaveState()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        tabBarController?.isTabBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        tabBarController?.isTabBarHidden = false
    }
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(vStack)
        
        [
            labeled("Amount", amountField),
            labeled("Note", noteField),
            labeled("Date", datePicker),
            labeled("Category", categoryPicker),
            saveBtn,
            loader].forEach(vStack.addArrangedSubview)
        
        vStack.setCustomSpacing(24, after: categoryPicker)
        
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
        vStack.snp.makeConstraints { make in
            make.edges.equalTo(scrollView.contentLayoutGuide)
            make.width.equalTo(scrollView.frameLayoutGuide)
        }
        
        [amountField, noteField].forEach { textField in
            textField.snp.makeConstraints { make in make.height.equalTo(48) }
        }
        datePicker.snp.makeConstraints { make in make.height.greaterThanOrEqualTo(180) }
        categoryPicker.snp.makeConstraints { make in make.height.equalTo(160) }
        saveBtn.snp.makeConstraints { make in make.height.equalTo(48) }
    }
    
    private func setupNavBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
            .foregroundColor: UIColor.systemIndigo,
            .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
        ]
        appearance.largeTitleTextAttributes = [
            .foregroundColor: UIColor.systemIndigo,
            .font: UIFont.systemFont(ofSize: 32, weight: .bold)
        ]
        appearance.backgroundColor = .clear
        
        navigationItem.standardAppearance = appearance
    }
    
    private func labeled(_ title: String, _ v: UIView) -> UIStackView {
        let label = UILabel()
        label.text = title
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .white.withAlphaComponent(0.8)
        
        let stack = UIStackView(arrangedSubviews: [label, v])
        stack.axis = .vertical
        stack.spacing = 8
        return stack
    }
    
    private func setLoading(_ loading: Bool) {
        if loading {
            loader.startAnimating()
        } else {
            loader.stopAnimating()
        }
        let enable = !loading && isAmountValid()
        saveBtn.isEnabled = enable
        saveBtn.alpha = enable ? 1.0 : 0.5
    }
    
    private func checkErrorAndLoading() {
        setLoading(vm.isSaving)
        if let message = vm.error {
            let alertController = UIAlertController(title: "Error", message: message, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "OK", style: .default))
            present(alertController, animated: true)
        }
    }
    
    private func normalizedAmountString(_ string: String) -> String {
        string.replacingOccurrences(of: ",", with: ".")
         .trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func isAmountValid() -> Bool {
        let point = normalizedAmountString(amountField.text ?? "")
        guard !point.isEmpty,
        let value = Double(point),
        value >= 0 else { return false }
        return true
    }
    
    private func updateSaveState() {
        let enabled = isAmountValid() && !vm.isSaving
        saveBtn.isEnabled = enabled
        saveBtn.alpha = enabled ? 1.0 : 0.5
    }
    
    @objc
    private func onDateChange() {
        vm.date = datePicker.date
    }
    
    @objc
    private func onSave() {
        view.endEditing(true)
        vm.amountText = amountField.text ?? ""
        vm.note = noteField.text ?? ""
        setLoading(true)
        vm.save { [weak self] in
            guard let self else { return }
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                self?.checkErrorAndLoading()
            }
            
        }
    }
    
    @objc
    private func onAmountChanged() {
        updateSaveState()
    }
    
}

extension AddEditViewController: UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        NSAttributedString(string: categories[row].title,
                           attributes: [.foregroundColor: UIColor.white])
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        vm.category = categories[row]
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
}
