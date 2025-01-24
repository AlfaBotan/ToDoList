//
//  ExtensionForUIResponder.swift
//  ToDoList
//
//  Created by Илья Волощик on 24.01.25.
//

import UIKit

extension UIResponder {
    func findViewController() -> UIViewController? {
        var nextResponder = self.next
        while let responder = nextResponder {
            if let viewController = responder as? UIViewController {
                return viewController
            }
            nextResponder = responder.next
        }
        return nil
    }
}
