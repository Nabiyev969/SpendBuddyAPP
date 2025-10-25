//
//  CurrencyRatesService.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 22.10.25.
//

import Foundation

protocol CurrencyRatesProviding {
    func refreshRates(base: Currency) async throws
    func rate(to: Currency) -> Double?
    func convert(_ amount: Double, from: Currency, to: Currency) -> Double?
}

final class CurrencyRatesService: CurrencyRatesProviding {
    
    private struct ERResponse: Decodable {
        let result: String
        let base_code: String
        let rates: [String: Double]
        let time_next_update_unix: Int?
    }

    
    private struct RatesCache: Codable {
        let base: String
        let rates: [String: Double]
        let nextUpdate: Date?
    }

    private let storage = UserDefaults.standard
    private let keyRates = "fx.erapi.rates"
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()

    private var cached: RatesCache? {
        guard let data = storage.data(forKey: keyRates) else { return nil }
        return try? decoder.decode(RatesCache.self, from: data)
    }

    func refreshRates(base: Currency) async throws {
        
        if let c = cached,
           c.base.uppercased() == base.rawValue,
           let next = c.nextUpdate,
           Date() < next {
            return
        }

        //https://open.er-api.com/v6/latest/USD
        guard let url = URL(string: "https://open.er-api.com/v6/latest/\(base.rawValue)") else {
            throw NSError(domain: "FX", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        var req = URLRequest(url: url)
        req.timeoutInterval = 15
        req.cachePolicy = .reloadIgnoringLocalCacheData

        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NSError(domain: "FX", code: (resp as? HTTPURLResponse)?.statusCode ?? -1,
                          userInfo: [NSLocalizedDescriptionKey: "Failed to load rates"])
        }

        let payload = try decoder.decode(ERResponse.self, from: data)
        guard payload.result.lowercased() == "success" else {
            throw NSError(domain: "FX", code: -2,
                          userInfo: [NSLocalizedDescriptionKey: "API returned error"])
        }

        let nextUpdate: Date?
        if let ts = payload.time_next_update_unix {
            nextUpdate = Date(timeIntervalSince1970: TimeInterval(ts))
        } else {
            nextUpdate = nil
        }

        let cache = RatesCache(base: payload.base_code, rates: payload.rates, nextUpdate: nextUpdate)
        let saved = try encoder.encode(cache)
        storage.set(saved, forKey: keyRates)
    }

    func rate(to: Currency) -> Double? {
        cached?.rates[to.rawValue]
    }

    func convert(_ amount: Double, from: Currency, to: Currency) -> Double? {
        guard let c = cached else { return nil }
        if from == to { return amount }

        if c.base.uppercased() == from.rawValue {
            guard let r = c.rates[to.rawValue] else { return nil }
            return amount * r
        }
        if c.base.uppercased() == to.rawValue {
            guard let r = c.rates[from.rawValue] else { return nil }
            return amount / r
        }
        guard let rFrom = c.rates[from.rawValue], let rTo = c.rates[to.rawValue] else { return nil }
        return (amount / rFrom) * rTo
    }
}
