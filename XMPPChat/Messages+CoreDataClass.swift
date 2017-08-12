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
        let moc =  CoreDataManger.shared.backgroundMoc
        moc?.performAndWait {
            if let messsage = NSEntityDescription.insertNewObject(forEntityName: "Messages", into: moc!) as? Messages {
                messsage.id = serverMsg.elementID()
                messsage.body = serverMsg.body()
                if let timeStamp = serverMsg.delayedDeliveryDate() as NSDate? {
                    messsage.timeStamp = timeStamp
                }else{
                    messsage.timeStamp = NSDate()
                }
                messsage.outGoing = isOutGoing
                var contactInfo:Contacts?
                if isOutGoing == true {
                    messsage.to = serverMsg.to().bare()
                    if let contact = Contacts.contact(bareJID: messsage.to, moc: moc) {
                        contactInfo = contact
                        contactInfo?.messages?.adding(messsage)
                        messsage.contacts = contactInfo
                    }
                    messsage.status = MessageStatus.Sending.rawValue
                }else{
                    messsage.from = serverMsg.from().bare()
                    if let contact = Contacts.contact(bareJID: messsage.from, moc: moc) {
                        contactInfo = contact
                        contactInfo?.addToMessages(messsage)
                        messsage.contacts = contactInfo
                    }
                }
                if let contactUpdateTime = contactInfo?.updateTime {
                    if contactUpdateTime.compare(messsage.timeStamp! as Date) == .orderedAscending {
                        
                        contactInfo?.updateTime =  messsage.timeStamp
                        contactInfo?.lastmessage = messsage.body
                    }
                    
                }else{
                    contactInfo?.updateTime =  messsage.timeStamp
                    contactInfo?.lastmessage = messsage.body
                }
            }
            CoreDataManger.shared.saveMainContext(context:moc!)
        }
    }
    
    public class func updateMessage(satue:MessageStatus, for messageId:String?) {
        let moc =   CoreDataManger.shared.backgroundMoc
        moc?.performAndWait {
            let fetchRequest:NSFetchRequest<Messages> =  NSFetchRequest(entityName: "Messages")
            fetchRequest.predicate = NSPredicate.init(format: "id == %@", messageId!)
            if let msgs = try? moc?.fetch(fetchRequest) ,let message = msgs?.last {
                message.status = satue.rawValue
                CoreDataManger.shared.saveMainContext(context:moc!)
            }
        }
    }
    
    public class func deleteMessage(messageId:String?) {
        let moc =   CoreDataManger.shared.backgroundMoc
        moc?.performAndWait {
            let fetchRequest:NSFetchRequest<Messages> =  NSFetchRequest(entityName: "Messages")
            fetchRequest.predicate = NSPredicate.init(format: "id == %@", messageId!)
            if let msgs = try? moc?.fetch(fetchRequest) ,let message = msgs?.last {
                moc?.delete(message)
                CoreDataManger.shared.saveMainContext(context:moc!)
            }
        }
    }
    
    public class func fetchOutGoingPendingMessages(inMoc moc:NSManagedObjectContext) -> [Messages]{
        
        let fetchRequest:NSFetchRequest<Messages> =  NSFetchRequest(entityName: "Messages")
        fetchRequest.predicate = NSPredicate.init(format: "status == %d AND outGoing == 1", MessageStatus.Sending.rawValue)
        return try! moc.fetch(fetchRequest)
    }
}
