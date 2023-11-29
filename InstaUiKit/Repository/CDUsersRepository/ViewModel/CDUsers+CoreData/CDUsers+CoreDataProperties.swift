//
//  CDUsers+CoreDataProperties.swift
//  
//
//  Created by IPS-161 on 29/11/23.
//
//

import Foundation
import CoreData


extension CDUsers {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDUsers> {
        return NSFetchRequest<CDUsers>(entityName: "CDUsers")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var userName: String?
    @NSManaged public var email: String?
    @NSManaged public var password: String?

}

extension CDUsers : Identifiable {
    
}
