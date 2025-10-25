//
//  RatesViewModel.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 22.10.25.
//

import Foundation

struct RateRow {
    let code: String
    let rate: Double
    let converted: Double?
}

@MainActor
final class RatesViewModel {
    
    private let service: CurrencyRatesProviding
    
    var onRowsChanged: (() -> ())?
    
    private let currencyFormatter: NumberFormatter = {
        let format = NumberFormatter()
        format.numberStyle = .currency
        return format
    }()
    
    var base: Currency {
        didSet { Task { await reload() } }
    }
    var amountText: String = "100" {
        didSet {
            rebuildRows()
            onRowsChanged?()
        }
    }
    
    var displayCurrencies: [Currency] = Currency.allCases
    
    private var isLoading = false
    private(set) var error: String?
    private(set) var rows: [RateRow] = []
    
    init(service: CurrencyRatesProviding, initialBase: Currency) {
        self.service = service
        self.base = initialBase
    }
    
    func reload() async {
        isLoading = true
        error = nil
        do {
            try await service.refreshRates(base: base)
            rebuildRows()
            onRowsChanged?()
        } catch {
            self.error = error.localizedDescription
            self.rows = []
            onRowsChanged?()
        }
        isLoading = false
    }
    
    func formatted(amount: Double, code: String) -> String {
        currencyFormatter.currencyCode = code
        return currencyFormatter.string(from: NSNumber(value: amount)) ?? "\(amount)"
    }
    
    private func parseAmount() -> Double {
        let parse = amountText.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(parse) ?? 0
    }
    
    private func rebuildRows() {
        let amount = parseAmount()
        rows = displayCurrencies
            .filter { $0 != base }
            .map { target in
                let rate = service.rate(to: target) ?? 0
                let convert = service.convert(amount, from: base, to: target)
                return RateRow(code: target.rawValue, rate: rate, converted: convert)
            }
            .sorted {
                $0.code < $1.code
            }
    }
}
