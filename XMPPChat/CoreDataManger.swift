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
    
    private override init() {
        super.init()
        self.mainMoc = self.persistentContainer.viewContext
    }
    
    private func mainDatabaseMomdURL() -> URL {
        return Bundle.main.url(forResource: "XMPPChat", withExtension: "momd")!
    }
    
    private func mainDatabaseSqliteURL() -> URL {
        
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        let documentsDirectory = paths[0]
        return documentsDirectory.appendingPathComponent("XMPPChat.sqlite")
    }
    
    // MARK: - Core Data stack
    
    public lazy var persistentContainer: NSPersistentContainer = {
        
        let momdName = "XMPPChat"
        guard let modelURL = Bundle(for: type(of: self)).url(forResource: momdName, withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        let container = NSPersistentContainer(name: momdName, managedObjectModel: mom)
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
    
    public func saveMainContext(){
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
    
    public func saveMainContext(context:NSManagedObjectContext) {
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
