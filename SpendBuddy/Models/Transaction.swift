//
//  Transaction.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 06.10.25.
//

import Foundation

struct Transaction: Identifiable {
    let id: UUID
    var amount: Double
    var date: Date
    var note: String?
    var category: Category
    var userId: String
}
