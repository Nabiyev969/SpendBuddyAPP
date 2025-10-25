//
//  Currency.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 22.10.25.
//

import Foundation

enum Currency: String, CaseIterable {
    case USD
    case EUR
    case AZN
    case RUB
    
    var title: String { rawValue }
}
