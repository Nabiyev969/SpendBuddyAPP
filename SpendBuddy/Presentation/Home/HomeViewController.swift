//
//  HomeViewController.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 06.10.25.
//

import UIKit
import SnapKit

final class HomeViewController: BaseViewController {
    private let viewModel: HomeViewModel
    
    private lazy var table: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.dataSource = self
        table.delegate = self
        table.backgroundColor = .clear
        table.separatorColor = .white.withAlphaComponent(0.15)
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        table.showsVerticalScrollIndicator = false
        return table
    }()
    
    init(viewModel: HomeViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
        title = "SpendBuddy"
    }
    required init?(coder: NSCoder) {
        fatalError()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavBar()
        
        Task { [weak self] in
            await self?.refreshData()
        }
}
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task { [weak self] in
            await self?.refreshData()
        }
    }

    private func setupUI() {
        view.addSubview(table)
        
        table.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.leading.trailing.bottom.equalToSuperview()
        }
    }
    
    private func setupNavBar() {
        let addBtn = UIButton(type: .system)
        addBtn.setImage(UIImage(systemName: "plus.circle.fill"), for: .normal)
        addBtn.tintColor = .systemIndigo
        addBtn.addTarget(self, action: #selector(onAdd), for: .touchUpInside)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: addBtn)
        
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
    
    private func refreshData() async {
        await viewModel.load()
        table.reloadData()
    }
    
    private func format(amount: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = AppDependencies.shared.settings.currencyCode
        return formatter.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }
    
    @objc
    private func onAdd() {
        let deps = AppDependencies.shared
        let uid = AppDependencies.shared.authService.currentUserId ?? "unknown"
        let addVM = AddEditViewModel(repo: deps.transactionsRepository, userId: uid)
        let addVC = AddEditViewController(viewModel: addVM)
        navigationController?.pushViewController(addVC, animated: true)
    }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        section == 0 ? "Summary for this month" : "Recent"
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        section == 0 ? 1 : viewModel.recent.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            cell.backgroundColor = .white.withAlphaComponent(0.06)
            cell.textLabel?.textColor = .white
            cell.detailTextLabel?.textColor = .white.withAlphaComponent(0.6)
            cell.layer.cornerRadius = 10
            cell.layer.masksToBounds = true

            if indexPath.section == 0 {
                cell.textLabel?.text = viewModel.formattedTotal()
                cell.detailTextLabel?.text = "Monthly total"
            } else {
                let item = viewModel.recent[indexPath.row]
                let dateFormat = DateFormatter()
                dateFormat.dateStyle = .medium
                cell.textLabel?.text = "\(item.category.title)  \(format(amount: item.amount))"
                cell.detailTextLabel?.text = "\(dateFormat.string(from: item.date))  \(item.note ?? "")"
            }
            cell.selectionStyle = .none
            return cell
        }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
}
