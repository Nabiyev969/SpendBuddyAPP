//
//  RatesViewModelTests.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 26.10.25.
//

import XCTest
@testable import SpendBuddy

final class RatesViewModelTests: XCTestCase {
    
    private final class MockRatesService: CurrencyRatesProviding {
        var tablesByBase: [Currency: [String: Double]] = [:]
        private(set) var currentBase: Currency = .USD
        
        func refreshRates(base: Currency) async throws {
            currentBase = base
        }
        
        func rate(to: Currency) -> Double? {
            tablesByBase[currentBase]?[to.rawValue]
        }
        
        func convert(_ amount: Double, from: Currency, to: Currency) -> Double? {
            guard let table = tablesByBase[currentBase] else { return nil }
            if from == to { return amount }
            let base = currentBase
            if base == from {
                guard let r = table[to.rawValue] else { return nil }
                return amount * r
            }
            if base == to {
                guard let r = table[from.rawValue] else { return nil }
                return amount / r
            }
            guard let rFrom = table[from.rawValue], let rTo = table[to.rawValue] else { return nil }
            return (amount / rFrom) * rTo
        }
    }
    
    @MainActor func testAmountInputRebuildsRows() throws {
        let mock = MockRatesService()
        
        mock.tablesByBase[.USD] = ["USD":1.0, "EUR": 0.9, "AZN": 1.7, "RUB": 95.0]
        
        let vm = RatesViewModel(service: mock, initialBase: .USD)
        vm.amountText = "100"
        
        XCTAssertEqual(vm.rows.count, 3)
        
        let eur = vm.rows.first { $0.code == "EUR" }!
        let azn = vm.rows.first { $0.code == "AZN" }!
        let rub = vm.rows.first { $0.code == "RUB" }!

        XCTAssertEqual(eur.rate, 0.9, accuracy: 0.0001)
        XCTAssertEqual(azn.rate, 1.7, accuracy: 0.0001)
        XCTAssertEqual(rub.rate, 95.0, accuracy: 0.0001)
        
        XCTAssertEqual(eur.converted ?? -1, 90.0, accuracy: 0.0001)
        XCTAssertEqual(azn.converted ?? -1, 170.0, accuracy: 0.0001)
        XCTAssertEqual(rub.converted ?? -1, 9500.0, accuracy: 0.001)
        
        vm.amountText = "12,5"
        let eur2 = vm.rows.first { $0.code == "EUR" }!
        XCTAssertEqual(eur2.converted ?? -1, 11.25, accuracy: 0.0001)
    }
    
    @MainActor func testBaseChangeTriggersReloadAndRecompute() async throws {
            let mock = MockRatesService()
            mock.tablesByBase[.USD] = ["USD":1.0, "EUR":0.9, "AZN":1.7, "RUB":95.0]
            mock.tablesByBase[.EUR] = ["USD":1.10, "EUR":1.0, "AZN":1.87, "RUB":105.0]

            let vm = RatesViewModel(service: mock, initialBase: .USD)
            vm.amountText = "100"

            let exp = expectation(description: "rows changed after base switch")
            vm.onRowsChanged = { exp.fulfill() }

            vm.base = .EUR
            await fulfillment(of: [exp], timeout: 1.0)

            let usd = vm.rows.first { $0.code == "USD" }!
            XCTAssertEqual(usd.rate, 1.10, accuracy: 0.0001)
            XCTAssertEqual(usd.converted ?? -1, 110.0, accuracy: 0.0001)
        }
}
