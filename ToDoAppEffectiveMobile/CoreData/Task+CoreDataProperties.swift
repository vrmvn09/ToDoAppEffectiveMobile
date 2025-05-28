//
//  Task+CoreDataProperties.swift
//  ToDoAppEffectiveMobile
//
//  Created by Arman  Urstem on 28.05.2025.
//

import Foundation
import CoreData

extension Task {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Task> {
        return NSFetchRequest<Task>(entityName: "Task")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String
    @NSManaged public var taskDescription: String?
    @NSManaged public var createdAt: Date
    @NSManaged public var completed: Bool
}
