//
//  CoreDataManger.swift
//  XMPPChat
//
//  Created by LInganna on 24/07/17.
//  Copyright © 2017 LInganna. All rights reserved.
//

import CoreData


open class CoreDataManger: NSObject {
    
    public static let shared = CoreDataManger()
    
    var backgroundMoc: NSManagedObjectContext!
    var mainMoc: NSManagedObjectContext!
    var privateMoc:NSManagedObjectContext!

    
    private override init() {
        super.init()
        
        privateMoc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        privateMoc!.persistentStoreCoordinator = persistantCoordinator
        privateMoc!.retainsRegisteredObjects = true
        privateMoc!.undoManager = nil
        
        mainMoc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        mainMoc.parent = privateMoc
        mainMoc!.retainsRegisteredObjects = true
        mainMoc!.undoManager = nil

        backgroundMoc = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        backgroundMoc.parent = mainMoc
        backgroundMoc!.retainsRegisteredObjects = true
        backgroundMoc!.undoManager = nil
    }
    
    private func mainDatabaseMomdURL() -> URL {
        return Bundle.main.url(forResource: "XMPPChat", withExtension: "momd")!
    }
    
    private func mainDatabaseSqliteURL() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        
        let storeDoc = documentsDirectory.appendingPathComponent("XMPPChatData")
        
        if !FileManager.default.fileExists(atPath: (storeDoc.path)) {
            try? FileManager.default.createDirectory(at: storeDoc, withIntermediateDirectories: false, attributes: nil)
        }
        return storeDoc.appendingPathComponent("XMPPChat.sqlite")
    }
    
    // MARK: - Core Data stack
    
   /* public lazy var persistentContainer: NSPersistentContainer! = {
        
        let momdName = "XMPPChat"
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: momdName, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        var container = NSPersistentContainer(name: momdName, managedObjectModel: mom)
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
    */
    // MARK: - Core Data Saving support
    public lazy var persistantCoordinator:NSPersistentStoreCoordinator! = {
    
        let momdName = "XMPPChat"
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: momdName, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        let model = NSManagedObjectModel(contentsOf: modelURL)
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: model!)
        let options:[AnyHashable: Any] = [NSMigratePersistentStoresAutomaticallyOption:true, NSInferMappingModelAutomaticallyOption:true]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: self.mainDatabaseSqliteURL(), options: options)
           
        }
        catch  let error {
            NSLog("unresolved error: \(error)")
        }
        return coordinator
    }()
    
    public func saveMainContext(context:NSManagedObjectContext) {
        if context.hasChanges {
            do {
                try context.save()
                if let parentMoc = context.parent {
                    saveMainContext(context: parentMoc)
                }
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    public func clearData() {
        
        do {
            let storeURL = persistantCoordinator.persistentStores[0].url
            try self.persistantCoordinator.destroyPersistentStore(at: storeURL!, ofType: NSSQLiteStoreType , options: nil)
            
        } catch {
            // Error Handling
        }
        
        self.persistantCoordinator = nil
        self.privateMoc = nil
        self.backgroundMoc = nil
        self.mainMoc = nil
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        let storeDoc = documentsDirectory.appendingPathComponent("XMPPChatData")
        if FileManager.default.fileExists(atPath: (storeDoc.path)) {
            let filePaths = try? FileManager.default.contentsOfDirectory(atPath: storeDoc.path)
            for path in filePaths! {
                try? FileManager.default.removeItem(atPath: path)
            }
        }
    }
    
}
