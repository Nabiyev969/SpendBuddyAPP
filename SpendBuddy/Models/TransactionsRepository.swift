//
//  TransactionsRepository.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 07.10.25.
//

import Foundation
import CoreData

protocol TransactionsRepository {
    func add(_ tx: Transaction) async throws
    func update(_ tx: Transaction) async throws
    func delete(id: UUID, userId: String) async throws
    func fetch(userId: String, range: DateInterval?, categories: [Category]?, query: String?) async throws -> [Transaction]
}

final class TransactionsRepositoryCoreData: TransactionsRepository {
    private let stack: CoreDataStack
    init(coreData: CoreDataStack) { self.stack = coreData }

    func add(_ tx: Transaction) async throws {
        let ctx = stack.context
        try await ctx.perform {
            let obj = CDTransaction(context: ctx)
            obj.id = tx.id
            obj.amount = tx.amount
            obj.date = tx.date
            obj.note = tx.note
            obj.category = tx.category.rawValue
            obj.userId = tx.userId
            try ctx.save()
        }
    }

    func update(_ tx: Transaction) async throws {
        let ctx = stack.context
        try await ctx.perform {
            let req: NSFetchRequest<CDTransaction> = CDTransaction.fetchRequest()
            req.fetchLimit = 1
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "id == %@", tx.id as CVarArg),
                NSPredicate(format: "userId == %@", tx.userId)
            ])
            if let obj = try ctx.fetch(req).first {
                obj.amount = tx.amount
                obj.date = tx.date
                obj.note = tx.note
                obj.category = tx.category.rawValue
                try ctx.save()
            }
        }
    }

    func delete(id: UUID, userId: String) async throws {
        let ctx = stack.context
        try await ctx.perform {
            let req: NSFetchRequest<CDTransaction> = CDTransaction.fetchRequest()
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: [
                NSPredicate(format: "id == %@", id as CVarArg),
                NSPredicate(format: "userId == %@", userId)
            ])
            if let obj = try ctx.fetch(req).first {
                ctx.delete(obj)
                try ctx.save()
            }
        }
    }

    func fetch(userId: String,
               range: DateInterval?,
               categories: [Category]?,
               query: String?) async throws -> [Transaction] {
        let ctx = stack.context
        return try await ctx.perform {
            let req: NSFetchRequest<CDTransaction> = CDTransaction.fetchRequest()
            var preds: [NSPredicate] = [NSPredicate(format: "userId == %@", userId)]
            if let r = range {
                preds.append(NSPredicate(format: "date >= %@ AND date <= %@", r.start as NSDate, r.end as NSDate))
            }
            if let cats = categories, !cats.isEmpty {
                preds.append(NSPredicate(format: "category IN %@", cats.map(\.rawValue)))
            }
            if let q = query, !q.isEmpty {
                preds.append(NSPredicate(format: "note CONTAINS[cd] %@", q))
            }
            req.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: preds)
            req.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

            return try ctx.fetch(req).map { obj in
                Transaction(
                    id: obj.id ?? UUID(),
                    amount: obj.amount,
                    date: obj.date ?? Date(),
                    note: obj.note,
                    category: Category(rawValue: obj.category ?? "other") ?? .other,
                    userId: obj.userId ?? ""
                )
            }
        }
    }
}
