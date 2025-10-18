//
//  HomeViewModel.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 06.10.25.
//

import Foundation

final class HomeViewModel {
    private let repo: TransactionsRepository
    private let summary: SummaryCalculating
//    private let currency: String
    private let userId: String
    
    var monthTotal: Double = 0
    var recent: [Transaction] = []
    
    init(repo: TransactionsRepository, summary: SummaryCalculating, userId: String? = AppDependencies.shared.authService.currentUserId) {
        self.repo = repo
        self.summary = summary
//        self.currency = currency
        self.userId = userId ?? "Unknown"
    }
    
    @MainActor
    func load() async {
        do {
            let tx = try await repo.fetch(userId: userId, range: nil, categories: nil, query: nil)
            recent = Array(tx.prefix(10))
            monthTotal = summary.total(for: tx, in: Date())
        } catch {
            print("Home load error: \(error.localizedDescription)")
        }
    }
    
    func formattedTotal() -> String {
        let format = NumberFormatter()
        format.numberStyle = .currency
        format.currencyCode = AppDependencies.shared.settings.currencyCode
        return format.string(from: monthTotal as NSNumber) ?? "\(monthTotal)"
      }
}
