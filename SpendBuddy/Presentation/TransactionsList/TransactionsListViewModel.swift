//
//  TransactionsListViewModel.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 12.10.25.
//

import Foundation

final class TransactionsListViewModel {
    private let repo: TransactionsRepository
    private let userId: String
    
    private(set) var items: [Transaction] = []
    private var all: [Transaction] = []
    
    init(repo: TransactionsRepository, userId: String) {
        self.repo = repo
        self.userId = userId
    }
    
    @MainActor
    func load() async {
        do {
            let item = try await repo.fetch(userId: userId, range: nil, categories: nil, query: nil)
            self.all = item
            self.items = item
        } catch {
            print("List load error: ", error)
        }
    }
    
    func filter(query: String?) {
        guard let q = query, !q.isEmpty else { items = all; return }
        let lower = q.lowercased()
        items = all.filter { item in
            item.category.title.lowercased().contains(lower) || (item.note ?? "").lowercased().contains(lower)
        }
    }
    
    @MainActor
    func delete(at index: Int) async {
        let item = items[index]
        do {
            try await repo.delete(id: item.id, userId: userId)
            if let indexAll = all.firstIndex(where: { $0.id == item.id }) { all.remove(at: indexAll) }
            items.remove(at: index)
        } catch {
            print("Delete error: ", error)
        }
    }
}
