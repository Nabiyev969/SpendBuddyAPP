//
//  AppDependencies.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 06.10.25.
//

import Foundation

final class AppDependencies {
    static let shared = AppDependencies()
    
    let coreData = CoreDataStack(modelName: "SpendBuddy")
    let authService: AuthService = FirebaseAuthService()
    
    lazy var transactionsRepository: TransactionsRepository =
        TransactionsRepositoryCoreData(coreData: coreData)
    
    let summaryCalculator: SummaryCalculating = SummaryCalculator()
      var settings = Settings()
    
    struct Settings {
        private let defaults = UserDefaults.standard
        private let key = "currencyCode"
        var currencyCode: String {
            get { defaults.string(forKey: key) ?? "USD" }
            set { defaults.set(newValue, forKey: key) }
        }
    }
}
