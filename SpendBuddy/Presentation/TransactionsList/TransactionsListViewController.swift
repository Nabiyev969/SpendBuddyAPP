//
//  TransactionsListViewController.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 12.10.25.
//

import UIKit
import SnapKit

final class TransactionsListViewController: BaseViewController {
    
    private let vm: TransactionsListViewModel
    
    private lazy var table: UITableView = {
        let table = UITableView(frame: .zero, style: .insetGrouped)
        table.backgroundColor = .clear
        table.separatorColor = .white.withAlphaComponent(0.15)
        table.rowHeight = 60
        table.register(TransactionCell.self, forCellReuseIdentifier: TransactionCell.identifier)
        table.dataSource = self
        table.delegate = self
        return table
    }()
    
    private lazy var search: UISearchController = {
        let search = UISearchController(searchResultsController: nil)
        search.searchResultsUpdater = self
        search.searchBar.tintColor = .systemIndigo
        search.searchBar.searchTextField.textColor = .white
        search.searchBar.searchTextField.leftView?.tintColor = .systemIndigo
        search.searchBar.placeholder = "Search notes or categories"
        return search
    }()
    
    init(viewModel: TransactionsListViewModel) {
        self.vm = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "All Transactions"
        
        navigationItem.searchController = search
        
        setupUI()
        setupNavBar()
        
        Task { [weak self] in
            await self?.vm.load()
            self?.table.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        Task { [weak self] in
            await self?.vm.load()
            self?.table.reloadData()
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
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [
                    .foregroundColor: UIColor.systemIndigo,
                    .font: UIFont.systemFont(ofSize: 20, weight: .semibold)
                ]
        appearance.backgroundColor = .clear
        navigationItem.standardAppearance = appearance
    }
    
    private func format(amount: Double) -> String {
        let format = NumberFormatter()
        format.numberStyle = .currency
        format.currencyCode = AppDependencies.shared.settings.currencyCode
        return format.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }
    
//    private func tUserId() -> String {
//        AppDependencies.shared.authService.currentUserId ?? "unknown"
//    }
}

extension TransactionsListViewController: UITableViewDataSource, UITableViewDelegate, UISearchResultsUpdating {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCell(withIdentifier: TransactionCell.identifier, for: indexPath) as? TransactionCell {
            let item = vm.items[indexPath.row]
            let dateFormatter = DateFormatter()
            dateFormatter.dateStyle = .medium
            
            cell.configure(category: item.category.title, amountText: format(amount: item.amount), dateText: dateFormatter.string(from: item.date), note: item.note)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        
        let delete = UIContextualAction(style: .destructive, title: "Delete") { [weak self] _, _, completion in
            guard let self else { completion(false); return }
            Task {
                await self.vm.delete(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            completion(true)
        }
        delete.backgroundColor = .systemRed
        
        let edit = UIContextualAction(style: .normal, title: "Edit") { [weak self] _, _, completion in
            guard let self else { completion(false); return }
            let item = self.vm.items[indexPath.row]
            
            let deps = AppDependencies.shared
            let addVM = AddEditViewModel(repo: deps.transactionsRepository, userId: deps.authService.currentUserId ?? "unknown", existing: item)
            
//            addVM.amountText = String(item.amount)
//            addVM.note = item.note ?? ""
//            addVM.date = item.date
//            addVM.category = item.category
            
            let vc = AddEditViewController(viewModel: addVM)
            self.navigationController?.pushViewController(vc, animated: true)
            completion(true)
        }
        edit.backgroundColor = .systemIndigo

        return UISwipeActionsConfiguration(actions: [delete, edit])
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        vm.filter(query: searchController.searchBar.text)
        table.reloadData()
    }
}
