//
//  CurrencyRatesServiceTests.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 26.10.25.
//

import XCTest
@testable import SpendBuddy

final class CurrencyRatesServiceTests: XCTestCase {

    private let cachedJSON: Data = """
    {
      "base":"USD",
      "rates":{"USD":1.0,"EUR":0.9,"AZN":1.7,"RUB":95.0},
      "nextUpdate": null
    }
    """.data(using: .utf8)!

    override func setUp() {
        super.setUp()
        UserDefaults.standard.set(cachedJSON, forKey: "fx.erapi.rates")
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: "fx.erapi.rates")
        super.tearDown()
    }

    func testConvertUSDToEURFromCache() throws {
        let service = CurrencyRatesService()
        let v = service.convert(100, from: .USD, to: .EUR)
        XCTAssertNotNil(v)
        XCTAssertEqual(v!, 90.0, accuracy: 0.0001)
    }

    func testConvertEURToUSDFromCache() throws {
        let service = CurrencyRatesService()

        let v = service.convert(90, from: .EUR, to: .USD)
        
        XCTAssertNotNil(v)
        XCTAssertEqual(v!, 100.0, accuracy: 0.001)
    }
}
