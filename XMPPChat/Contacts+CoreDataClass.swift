//
//  Contacts+CoreDataClass.swift
//  XMPPChat
//
//  Created by LInganna on 24/07/17.
//  Copyright © 2017 LInganna. All rights reserved.
//

import Foundation
import CoreData

@objc(Contacts)
public class Contacts: NSManagedObject {
    
    
    public class func contact(bareJID:String? , moc:NSManagedObjectContext?) -> Contacts? {
        var contact:Contacts?
        // moc?.performAndWait {
        if let  existingContact = self.getContact(bareJID: bareJID, moc: moc) {
            contact = existingContact
        }else{
            contact = (NSEntityDescription.insertNewObject(forEntityName: "Contacts", into: moc!) as! Contacts)
            contact?.bareJID = bareJID
            CoreDataManger.shared.saveMainContext(context: moc!)
        }
        //   }
        return contact;
    }
    
    public class func getContact(bareJID:String?, moc:NSManagedObjectContext?) -> Contacts? {
        
        var existingContact:Contacts?
        
        // moc?.performAndWait {
        let fetchRequest:NSFetchRequest<Contacts> =  NSFetchRequest(entityName: "Contacts")
        fetchRequest.predicate = NSPredicate.init(format: "bareJID == %@", bareJID!)
        if let contacts = try? moc?.fetch(fetchRequest) , (contacts?.count)! > 0{
            existingContact =  contacts?.last
        }
        //  }
        return existingContact;
    }
    
    public class func lastMessage(bareJID:String?, moc:NSManagedObjectContext?) -> String? {
        
        let fetchRequest:NSFetchRequest<Contacts> =  NSFetchRequest(entityName: "Contacts")
        fetchRequest.predicate = NSPredicate.init(format: "bareJID == %@", bareJID!)
        if let contacts = try? moc?.fetch(fetchRequest) , (contacts?.count)! > 0{
            existingContact =  contacts?.last
        }
        return existingContact?.lastmessage;
    }

}
