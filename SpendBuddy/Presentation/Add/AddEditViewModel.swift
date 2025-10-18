//
//  AddEditViewModel.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 10.10.25.
//

import Foundation

final class AddEditViewModel {
    
    private let repo: TransactionsRepository
    private let userId: String
    
    let existing: Transaction?
    
    var amountText = ""
    var note = ""
    var date = Date()
    var category: Category = .other
    
    var isSaving = false
    var error: String?
    
    init(repo: TransactionsRepository, userId: String, existing: Transaction? = nil) {
        self.repo = repo
        self.userId = userId
        self.existing = existing
        
        if let item = existing {
            amountText = String(item.amount)
            note = item.note ?? ""
            date = item.date
            category = item.category
        }
    }
    
    func save(onSuccess: @escaping () -> ()) {
        isSaving = true
        error = nil
        Task { [weak self] in
            guard let self else { return }
            do {
                let amount = try Self.parseAmount(self.amountText)
                let tx = Transaction(id: self.existing?.id ?? UUID(),
                                     amount: amount,
                                     date: self.date,
                                     note: self.note.isEmpty ? nil : self.note,
                                     category: self.category,
                                     userId: self.userId)
                if self.existing != nil {
                    try await repo.update(tx)
                } else {
                    try await repo.add(tx)
                }
                onSuccess()
            } catch {
                self.error = error.localizedDescription
            }
            self.isSaving = false
        }
    }
    
    private static func parseAmount(_ s: String) throws -> Double {
        let trimmed = s.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines)
        guard let num = Double(trimmed), num >= 0 else {
            throw NSError(domain: "AddEdit", code: 1, userInfo: [NSLocalizedDescriptionKey: "Invalid amount"])
        }
        return num
    }
}
