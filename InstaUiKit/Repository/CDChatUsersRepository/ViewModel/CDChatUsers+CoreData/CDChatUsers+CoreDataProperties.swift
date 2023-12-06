//
//  CDChatUsers+CoreDataProperties.swift
//  
//
//  Created by IPS-161 on 06/12/23.
//
//

import Foundation
import CoreData


extension CDChatUsers {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDChatUsers> {
        return NSFetchRequest<CDChatUsers>(entityName: "CDChatUsers")
    }

    @NSManaged public var uid: String?
    @NSManaged public var id: UUID?

}
