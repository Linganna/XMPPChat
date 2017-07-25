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
            
            if let messsage = NSEntityDescription.insertNewObject(forEntityName: "Messages", into: moc) as? Messages {
                messsage.body = serverMsg.body()
                if let timeStamp = serverMsg.delayedDeliveryDate() as NSDate? {
                    messsage.timeStamp = timeStamp
                }else{
                    messsage.timeStamp = NSDate()
                }
                messsage.outGoing = isOutGoing
                messsage.to = serverMsg.to().bare()
                messsage.from = serverMsg.from().bare()
                if isOutGoing == true {
                    if let contact = Contacts.contact(bareJID: messsage.to) {
                        contact.addToMessages(messsage)
                    }
                }else{
                    if let contact = Contacts.contact(bareJID: messsage.from) {
                        contact.addToMessages(messsage)
                    }
                }
            }
            CoreDataManger.shared.saveMainContext()
        }
    }
}
