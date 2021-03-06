//
//  User+CoreDataProperties.swift
//  malaria-ios
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension User {

    @NSManaged var firstName: String
    @NSManaged var lastName: String
    @NSManaged var gender: String
    @NSManaged var age: Int64
    @NSManaged var location: String?
    @NSManaged var email: String
    @NSManaged var phone: String?

}
