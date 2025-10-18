//
//  Category.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 06.10.25.
//

import Foundation

enum Category: String, CaseIterable, Identifiable {
    case groceries
    case transport
    case dining
    case bills
    case fun
    case health
    case other
    
    var id: String { rawValue }
    var title: String {
        switch self {
        case .groceries: return "Groceries"
        case .transport: return "Transport"
        case .dining: return "Dining"
        case .bills: return "Bills"
        case .fun: return "Fun"
        case .health: return "Health"
        case .other: return "Other"
        }
    }
}
