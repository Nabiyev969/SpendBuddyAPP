//
//  Coordinator.swift
//  SpendBuddy
//
//  Created by Nabiyev Anar on 20.10.25.
//

import UIKit

protocol Coordinator: AnyObject {
    func start()
}

class BaseCoordinator: Coordinator {
    
    private var childern: [Coordinator] = []
    func start() { }
    
    func store(_ child: Coordinator) {
        childern.append(child)
    }
    func free(_ child: Coordinator) {
        childern.removeAll() { $0 === child }
    }
}
