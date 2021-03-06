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
                
                if serverMsg.elements(forName: "attachment").count > 0{
                   let attachment =  saveAttachment(base64String: (serverMsg.elements(forName: "attachment")[0]).stringValue!, in: moc!)
                    attachment?.message = messsage
                    messsage.addToAttachment(attachment!)
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
    
    class func saveAttachment(base64String:String, in moc:NSManagedObjectContext) -> Attachments? {
        if let attachment = NSEntityDescription.insertNewObject(forEntityName: "Attachments", into: moc) as? Attachments{
            let mediaData = Data(base64Encoded: base64String, options: .ignoreUnknownCharacters)
            let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let documentsDirectory = paths[0]
            let fileName = "attachement_\(String(Date().timeIntervalSince1970 * 1000.0)).png"
            let storeDoc = documentsDirectory.appendingPathComponent(fileName)
            if !FileManager.default.fileExists(atPath: (storeDoc.path)) {
                 FileManager.default.createFile(atPath: storeDoc.path, contents: mediaData, attributes: nil)
            }
            attachment.datafilePath = fileName
            return attachment
        }
        return nil
   
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
                self.updateLastMessageAndTimeForId(bareJID: message.contacts?.bareJID, moc: moc)
                CoreDataManger.shared.saveMainContext(context:moc!)
            }
        }
    }
    
    public class func fetchOutGoingPendingMessages(inMoc moc:NSManagedObjectContext) -> [Messages]{
        
        let fetchRequest:NSFetchRequest<Messages> =  NSFetchRequest(entityName: "Messages")
        fetchRequest.predicate = NSPredicate.init(format: "status == %d AND outGoing == 1", MessageStatus.Sending.rawValue)
        return try! moc.fetch(fetchRequest)
    }
    
    public class func updateLastMessageAndTimeForId(bareJID:String?, moc:NSManagedObjectContext?) {
        if let  lastContact = Contacts.getContact(bareJID: bareJID, moc: moc) {
            let fetchRequest:NSFetchRequest<Messages> =  NSFetchRequest(entityName: "Messages")
            fetchRequest.predicate = NSPredicate.init(format: "contacts.bareJID == %@", lastContact.bareJID!)
            
            //set sort descriptor
            let sortDescriptor = NSSortDescriptor(key: "timeStamp", ascending: true)
            fetchRequest.sortDescriptors = [sortDescriptor]
            
            if let messages = try?moc?.fetch(fetchRequest), let message = messages?.last {
                if let contactUpdateTime = message.timeStamp, let contactLastMsg = message.body {
                    lastContact.updateTime =  contactUpdateTime
                    lastContact.lastmessage = contactLastMsg
                }else{
                    lastContact.updateTime =  NSDate()
                    lastContact.lastmessage = ""
                }
            }
        }
    }
}
