//
//  Contacts+CoreDataProperties.swift
//  XMPPChat
//
//  Created by LInganna on 12/08/17.
//  Copyright © 2017 LInganna. All rights reserved.
//

import Foundation
import CoreData


extension Contacts {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Contacts> {
        return NSFetchRequest<Contacts>(entityName: "Contacts")
    }

    @NSManaged public var bareJID: String?
    @NSManaged public var streambare: String?
    @NSManaged public var updateTime: NSDate?
    @NSManaged public var lastmessage: String?
    @NSManaged public var messages: NSSet?

}

// MARK: Generated accessors for messages
extension Contacts {

    @objc(addMessagesObject:)
    @NSManaged public func addToMessages(_ value: Messages)

    @objc(removeMessagesObject:)
    @NSManaged public func removeFromMessages(_ value: Messages)

    @objc(addMessages:)
    @NSManaged public func addToMessages(_ values: NSSet)

    @objc(removeMessages:)
    @NSManaged public func removeFromMessages(_ values: NSSet)

}
