//
//  Messages+CoreDataProperties.swift
//  XMPPChat
//
//  Created by LInganna on 27/07/17.
//  Copyright © 2017 LInganna. All rights reserved.
//

import Foundation
import CoreData


extension Messages {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Messages> {
        return NSFetchRequest<Messages>(entityName: "Messages")
    }

    @NSManaged public var body: String?
    @NSManaged public var composing: String?
    @NSManaged public var from: String?
    @NSManaged public var message: String?
    @NSManaged public var outGoing: Bool
    @NSManaged public var timeStamp: NSDate?
    @NSManaged public var to: String?
    @NSManaged public var attachment: NSSet?
    @NSManaged public var contacts: Contacts?

}

// MARK: Generated accessors for attachment
extension Messages {

    @objc(addAttachmentObject:)
    @NSManaged public func addToAttachment(_ value: Attachments)

    @objc(removeAttachmentObject:)
    @NSManaged public func removeFromAttachment(_ value: Attachments)

    @objc(addAttachment:)
    @NSManaged public func addToAttachment(_ values: NSSet)

    @objc(removeAttachment:)
    @NSManaged public func removeFromAttachment(_ values: NSSet)

}
