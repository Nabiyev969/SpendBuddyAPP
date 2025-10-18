//
//  CoreDataStack.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 07.10.25.
//

import CoreData

final class CoreDataStack {
    let container: NSPersistentContainer
    
    init(modelName: String) {
        container = NSPersistentContainer(name: modelName)
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData error: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    var context: NSManagedObjectContext { container.viewContext }
    
    func save() {
        guard context.hasChanges else { return }
        do {
            try context.save()
        } catch {
            print("Save error: \(error.localizedDescription)")
        }
    }
}
