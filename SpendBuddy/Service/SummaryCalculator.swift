//
//  SummaryCalculator.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 07.10.25.
//

import Foundation

protocol SummaryCalculating {
    func total( for txs: [Transaction], in month: Date) -> Double
}

struct SummaryCalculator: SummaryCalculating {
    
    func total(for txs: [Transaction], in month: Date) -> Double {
        let cal = Calendar.current
        guard let start = cal.date(from: cal.dateComponents([.year, .month], from: month)),
              let end = cal.date(byAdding: DateComponents(month: 1, day: -1), to: start) else { return 0 }
        let interval = DateInterval(start: start, end: end)
        return txs
            .filter { interval.contains($0.date) }
            .reduce(0) { $0 + $1.amount }
    }
}
