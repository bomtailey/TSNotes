//
//  DataController.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 3/9/17.
//  Copyright © 2017 LCI. All rights reserved.
//


import UIKit
import CoreData

var moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)


class DataController: NSObject {
    
   
    override init() {
        
        // This resource is the same name as your xcdatamodeld contained in your project.
        guard let modelURL = Bundle.main.url(forResource: "TSNotes", withExtension:"momd") else {
            fatalError("Error loading model from bundle")
        }
        
        print("\n\nApp Path: \(modelURL.absoluteString)\n\n")

        
        // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        
        // Persistent store coordinator
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        
        // Define the managed obect context
        moc = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        moc.persistentStoreCoordinator = psc
        
      //  DispatchQueue.main.sync //.global(qos: userInteractive).async
       // dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0).  //.asynchronously()
            
            DispatchQueue.global(qos: .userInitiated).async
            {            
            
            let docURL: URL = {
                let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                return urls[(urls.endIndex - 1)] }()
            
            /* The directory the application uses to store the Core Data store file.
             This code uses a file named "DataModel.sqlite" in the application's documents directory.
             */
            let storeURL = docURL.appendingPathComponent("TSNotes.sqlite")  //.URLByAppendingPathComponent("DataModel.sqlite")
                        
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
                //<#T##[AnyHashable : Any]?#>)  //.addPersistentStore(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
            
        }
    }
    
    
}
