//
//  Attachments+CoreDataProperties.swift
//  XMPPChat
//
//  Created by LInganna on 24/07/17.
//  Copyright © 2017 LInganna. All rights reserved.
//

import Foundation
import CoreData


extension Attachments {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Attachments> {
        return NSFetchRequest<Attachments>(entityName: "Attachments")
    }

    @NSManaged public var datafilePath: String?
    @NSManaged public var message: Messages?

}
