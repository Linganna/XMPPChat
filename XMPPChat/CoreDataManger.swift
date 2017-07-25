//
//  CoreDataManger.swift
//  XMPPChat
//
//  Created by LInganna on 24/07/17.
//  Copyright © 2017 LInganna. All rights reserved.
//

import CoreData


class CoreDataManger: NSObject {
    
    static let shared = CoreDataManger()
    
    var backgroundMoc: NSManagedObjectContext!
    var mainMoc: NSManagedObjectContext!
    
    private override init() {
        super.init()
        self.mainMoc = self.persistentContainer.viewContext
    }
    
    private func mainDatabaseMomdURL() -> URL {
        return Bundle.main.url(forResource: "XMPPChat", withExtension: "momd")!
    }
    
    public func mainDatabaseSqliteURL() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.appendingPathComponent("XMPPChat.sqlite")
    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "XMPPChat")
        
        container.persistentStoreDescriptions = [NSPersistentStoreDescription(url: self.mainDatabaseSqliteURL())]
        
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {

                fatalError("Unresolved error \(error), \(error.userInfo)")
            } else {
                container.viewContext.automaticallyMergesChangesFromParent = true
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveMainContext(){
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {

                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    func saveMainContext(context:NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    

}
