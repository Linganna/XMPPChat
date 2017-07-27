//
//  Messages+CoreDataClass.swift
//  XMPPChat
//
//  Created by LInganna on 24/07/17.
//  Copyright © 2017 LInganna. All rights reserved.
//

import Foundation
import XMPPFramework

@objc(Messages)
public class Messages: NSManagedObject {
    
    public class func saveMessage(serverMsg:XMPPMessage, isOutGoing:Bool) {
        
        CoreDataManger.shared.persistentContainer.performBackgroundTask { (moc) in
            
            //  moc.performAndWait {
            if let messsage = NSEntityDescription.insertNewObject(forEntityName: "Messages", into: moc) as? Messages {
                messsage.body = serverMsg.body()
                if let timeStamp = serverMsg.delayedDeliveryDate() as NSDate? {
                    messsage.timeStamp = timeStamp
                }else{
                    messsage.timeStamp = NSDate()
                }
                messsage.outGoing = isOutGoing
                if isOutGoing == true {
                    messsage.to = serverMsg.to().bare()
                    if let contact = Contacts.contact(bareJID: messsage.to, moc: moc) {
                        contact.messages?.adding(messsage)
                        messsage.contacts = contact
                    }
                }else{
                    messsage.from = serverMsg.from().bare()
                    if let contact = Contacts.contact(bareJID: messsage.from, moc: moc) {
                        contact.addToMessages(messsage)
                        messsage.contacts = contact
                    }
                }
            }
            CoreDataManger.shared.saveMainContext(context:moc)
            //  }
        }
    }
}
