//
//  StatsViewModel.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 18.10.25.
//

import Foundation

struct StatsCategorySlice {
    let category: Category
    let total: Double
}

struct StatsDailyBar {
    let day: Int
    let total: Double
}

final class StatsViewModel {
    
    private let repo: TransactionsRepository
    private let userId: String
    private let calendar = Calendar.current
    
    private(set) var categorySlices: [StatsCategorySlice] = []
    private(set) var dailyBars: [StatsDailyBar] = []
    private(set) var monthTitle: String = ""
    
    private lazy var monthFormatter: DateFormatter = {
        let format = DateFormatter()
        format.dateFormat = "LLLL yyyy"
        return format
    }()
    
    init(repo: TransactionsRepository, userId: String) {
        self.repo = repo
        self.userId = userId
    }
    
    @MainActor
    func loadCurrentMonth() async {
        let (start, end) = currentMonthBounds(Date())
        monthTitle = monthFormatter.string(from: start)
        
        do {
            let item = try await repo.fetch(userId: userId,
                                            range: DateInterval(start: start, end: end),
                                            categories: nil,
                                            query: nil)
            
            let byCategory = Dictionary(grouping: item, by: { $0.category })
                .map { (category, list) -> StatsCategorySlice in
                    let sum = list.reduce(0) { $0 + $1.amount }
                    return StatsCategorySlice(category: category, total: sum)
                }.sorted { $0.total > $1.total }
            
            var byDay: [Int: Double] = [:]
            for t in item {
                let day = calendar.component(.day, from: t.date)
                byDay[day, default: 0] += t.amount
            }
            
            let range = calendar.range(of: .day, in: .month, for: start) ?? 1..<32
            let bars: [StatsDailyBar] = range.map { day in
                StatsDailyBar(day: day, total: byDay[day] ?? 0)
            }
            
            self.categorySlices = byCategory
            self.dailyBars = bars
        } catch {
            print("Statistics load error: ", error.localizedDescription)
            self.categorySlices = []
            self.dailyBars
        }
    }
    
    private func currentMonthBounds(_ ref: Date) -> (Date, Date) {
        let comps = calendar.dateComponents([.year, .month], from: ref)
        let start = calendar.date(from: comps)!
        let end = calendar.date(byAdding: DateComponents(month: 1, day: 0), to: start)!
        return (start, end)
    }
    
    func formatted(amount: Double) -> String {
        let format = NumberFormatter()
        format.numberStyle = .currency
        format.currencyCode = AppDependencies.shared.settings.currencyCode
        return format.string(from: NSNumber(value: amount)) ?? String(format: "%.2f", amount)
    }
}
