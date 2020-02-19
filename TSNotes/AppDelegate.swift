//
//  AppDelegate.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 10/23/15.
//  Copyright © 2015 LCI. All rights reserved.
//

import UIKit
import CoreData
import CloudKit
import UserNotifications

import IQKeyboardManagerSwift


    let appDelegate = UIApplication.shared.delegate as! AppDelegate

    // iCloud Global variables
    let ckID = "iCloud.com.LCI.TSNotes.CloudKit.PushNotify"
    var ckContainer = CKContainer(identifier: ckID)
    var defaultContainer = CKContainer.default()
    var publicCloudDB = defaultContainer.publicCloudDatabase
    var privateCloudDB = defaultContainer.privateCloudDatabase

    // Some more definitions for scanning records
    let documents = CKContainer(identifier: "iCloud.com.LCI.TSNotes.CloudKit.PushNotify.documents")
    let settings = CKContainer(identifier: "iCloud.com.LCI.TSNotes.CloudKit.PushNotify.settings")

    let containerRecordTypes: [CKContainer: [String]] = [
        defaultContainer: ["log", "verboseLog"],
        documents: ["textDocument", "spreadsheet"],
        settings: ["preference", "profile"]
    ]

    let containers = Array(containerRecordTypes.keys)

    //var context = (UIApplication.shared.delegate as! AppDelegate).   //.persistentContainer.viewContext

var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
 
    var window: UIWindow?
    
        // iCloud Global variables
        /*
        let ckID = "iCloud.com.LCI.TSNotes.CloudKit.PushNotify"
        let defaultContainer = CKContainer.default()
        */

    //    let publicCloudDB = CKContainer.default().publicCloudDatabase


    func application(_ application: UIApplication, willFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        return true
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        // Override point for customization after application launch.
        
         ckContainer = CKContainer(identifier: ckID)
         publicCloudDB = defaultContainer.publicCloudDatabase
         privateCloudDB = defaultContainer.privateCloudDatabase

        managedObjectContext = createMainContext()
        
        // 1/3/2020 will this work to implement cloudkit?
        managedObjectContext.automaticallyMergesChangesFromParent = true
        
        // Establish notification environment
        establishSubscriptions(recordType: "CD_Note")

        // 1/7/2020 Set up push change notifications and subscribing
        // set self (AppDelegate) to handle notification
        UNUserNotificationCenter.current().delegate = self

        // Request permission from user to send notification
        /* Temporarily don't subscribe for notifications
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { authorized, error in
          if authorized {
            DispatchQueue.main.async(execute: {
              application.registerForRemoteNotifications()
            })
          }
        })
        */
               
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("D'oh: \(error.localizedDescription)")
            } else {
                DispatchQueue.main.async {
                    application.registerForRemoteNotifications()
                }
            }
        }
        
       //===> temporary reporting function
        reviewDatabase ()

        // Set up handling move entry fields above keyboard
        IQKeyboardManager.shared.enable = true
        
        return true
    }
    
    
    
    
    func createMainContext() ->  NSManagedObjectContext {
        
        // Initialize NSManagedObjectModel
        guard let modelURL = Bundle.main.url(forResource: "TSNotesDataModel", withExtension: "momd")
            else {
            fatalError("Error loading model from bundle")
            }
        
        guard NSManagedObjectModel(contentsOf: modelURL) != nil else { fatalError("Error initializing model from: \(modelURL)" ) }
        
        // Configure NSPersistentStoreCoordinator with an NSPersistentStore
        // 1/4/2020 - change this to NSPersistentCloudKitContainer
      //  let psc = NSPersistentStoreCoordinator(managedObjectModel: model)
       // let psc = NSPersistentCloudKitContainer(name: "TSNotes")
        
        let viewContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        /*
        let navigationController = self.window?.rootViewController as! UINavigationController
        let mainVC = navigationController.viewControllers[0] //as! MainViewController
        */


        /*
        let storeURL = try! FileManager
            .default
            .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appendingPathComponent("TSNotes.sqlite")
        
        try! psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
        */
        
        // Create and return NSManagedObjectContext
        viewContext.automaticallyMergesChangesFromParent = true

   //       mainVC.managedObjectContext = viewContext
        return viewContext
    }
    
    // iOS-10
    @available(iOS 10.0, *)
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
      //  let container = NSPersistentCloudKitContainer(name: "TSNotes")
        let container = NSPersistentCloudKitContainer(name: "TSNotesDataModel")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
   //     print("\(self.applicationDocumentsDirectory)")
        return container
    }()


    
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.saveContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        
   //     coreDataStack.saveContext()
       self.saveContext()
    }
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
     //   let context = persistentContainer.viewContext
        
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

    
    // App state save and restore
    
 
    func application(_ application: UIApplication, shouldSaveApplicationState coder: NSCoder) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, shouldRestoreSecureApplicationState coder: NSCoder) -> Bool {
   //     return true
        return false
    }
 
  // MARK: - Set up notification subscriptions

    func establishSubscriptions(recordType: String) {
        
        // First see if there are any existing subscriptions in which case nothing
        // needs to be done
        
        let subscription = CKDatabaseSubscription(subscriptionID: recordType)
     /*
        b = subscription.i
     
        if ( subscriptionIslocallyCached) {
            
        }
 */

        clearSubscriptions()

        
    }
    
    // MARK: - CloudKit implementation
    
    // 1/7/2020 Add CloudKit change notification implementation
    
    // When user allowed push notification and the app has gotten the device token
    // (device token is a unique ID that Apple server use to determine which device to send push notification to)
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
    }
    
    // issueSubscription
    func issueSubscription ( recordType: String, alertTitle: String) {
        
        // The predicate lets you define condition of the subscription, eg: only be notified of change if the newly created notification start with "A"
        // the TRUEPREDICATE means any new Notifications record created will be notified
        
    //   Subscribe to NoteBase changes
        let subscription = CKQuerySubscription(recordType: recordType, predicate: NSPredicate(format: "TRUEPREDICATE"), options: [.firesOnRecordCreation, .firesOnRecordUpdate, .firesOnRecordDeletion ] )
        
        // Here we customize the notification message
        let info = CKSubscription.NotificationInfo()
        
        // this will use the 'CD_noteName' field in the Record type 'CD_NoteBase' as the title of the push notification
        info.titleLocalizationKey = "%1$@"
        info.titleLocalizationArgs = [alertTitle]
        
        // if you want to use multiple field combined for the title of push notification
        // info.titleLocalizationKey = "%1$@ %2$@" // if want to add more, the format will be "%3$@", "%4$@" and so on
        // info.titleLocalizationArgs = ["title", "subtitle"]
        
        // this will use the 'content' field in the Record type 'notifications' as the content of the push notification
        info.alertLocalizationKey = "%1$@"
        info.alertLocalizationArgs = [alertTitle]
        
        // increment the red number count on the top right corner of app icon
        info.shouldBadge = true
        
        // use system default notification sound
        info.soundName = "default"
        info.shouldSendContentAvailable = true
        info.alertBody = ""
        
        subscription.notificationInfo = info
        
        // Save the subscription to Public Database in Cloudkit publicCloudDB
        
        publicCloudDB.save(subscription, completionHandler: { subscription, error in
            if error == nil {
                // Subscription saved successfully
                print("Attempt to subscribe succeeded - \(Utils.nowString())")
            } else {
                // Error occurred  CKError
                print("Attempt to subscribe failed: \(Utils.nowString())\(String(describing: error))")
            }
         })
        

    }
    
    // Registration failed
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for notifications: \(error.localizedDescription)")
    }
    
    // Method to delete existing subscriptions
    func clearSubscriptions() {
                
        publicCloudDB.fetchAllSubscriptions(completionHandler: {subscriptions, error in
           
            if error == nil {
                if let subscriptions = subscriptions {
                    for subscription in subscriptions {
                        publicCloudDB.delete(withSubscriptionID: subscription.subscriptionID) { str, error in
                            if error != nil {
                                // do your error handling here!
                                print(error!.localizedDescription)
                            }
                        }

                    }
                }

                self.issueSubscription ( recordType: "CD_NoteBase", alertTitle: "CD_noteName")
                self.issueSubscription ( recordType: "CD_Note", alertTitle: "CD_noteText")

            }
        })
        
    }
    
    // Utility function to display records.
    // Customize it to display records appropriately
    // according to your app's unique record types.
    func printRecords(_ records: [CKRecord]) {
        for record in records {
            for key in record.allKeys() {
                let value = record[key]
                print(key + " = " + (value?.description ?? "") + ")")
            }
        }
    }

    func reviewDatabase () {
        
        
        for container in containers {
            // User data should be stored in the private database.
            let containerID = container.containerIdentifier
            print("Container ID: \(String(describing: containerID))")
            
            if containerID == ckID {
            
                let database = container.privateCloudDatabase
                
                database.fetchAllRecordZones { zones, error in
                    guard let zones = zones, error == nil else {
                        print(error!)
                        return
                    }
                    
                    // The true predicate represents a query for all records.
                    let alwaysTrue = NSPredicate(value: true)
                    for zone in zones {
                        for recordType in containerRecordTypes[container] ?? [] {
                            let query = CKQuery(recordType: recordType, predicate: alwaysTrue)
                            database.perform(query, inZoneWith: zone.zoneID) { records, error in
                                guard let records = records, error == nil else {
                                    print("An error occurred fetching these records.")
                                    return
                                }
                                
                                self.printRecords(records)
                            }
                        }
                    }
                }
            }
        }
    }


}

extension AppDelegate: UNUserNotificationCenterDelegate{
    
 
    // This function will be called when the app receives notification
  func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
    
    // show the notification alert (banner), and with sound
    completionHandler([.alert, .sound])
  }
  
  // This function will be called right after user taps on the notification
  func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
    
    // tell the app that we have finished processing the user’s action (eg: tap on notification banner) / response
    completionHandler()
  }
    
    /*
    // Version 1 of handling remote push notifications from CloudKit
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {

           guard let aps = userInfo["aps"] as? [String: AnyObject] else {
             completionHandler(.failed)
             return
           }
           

           let newInfo = aps.description
           
           print ("\n======> from AppDelegate:didReceiveRemoteNotification received notice of cloudkit update  <===========\n")

           print ("Notification description is ===> \(newInfo)")
           
           /*
           var notificationType : String
              notificationType = CloudKit.Notification.Name (rawValue: <#T##String#>).rawValue
          
           var notificationType = CloudKit.Notification.Name.self
           
           if notificationType == CloudKit.isqu {
           }
    
           if CloudKit.Notification.Type.self == CloudKit.isQueryNotification {
           }
           
           if CloudKit.Notification.Type.Type == CloudKit.CKQueryNotification     //.notificationType == CloudKit.QueryNotification   //.isQueryNotification    {
           }
            */
           
           // Try to get all the notifications associated with this change
           /// from [here](https://www.invasivecode.com/weblog/advanced-cloudkit-part-iii))
           fetchNotificationChanges()
           
           
           switch application.applicationState {

            case .inactive:
                print("Inactive")
                //Show the view with the content of the push
                completionHandler(.newData)

            case .background:
                print("Background")
                //Refresh the local model
                completionHandler(.newData)

            case .active:
                print("Active")
                
                // noyify others
                NotificationCenter.default.post(name: .didReceiveData, object: userInfo)
                
                
                //Show an in-app banner
                completionHandler(.newData)
            }
        }
    */

    
    /// from [here](https://www.invasivecode.com/weblog/advanced-cloudkit-part-iii))
 
    // Version 2 of handling remote push notifications from CloudKit
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        
        if cloudKitNotification?.notificationType == .query {
            let queryNotification = cloudKitNotification as! CKQueryNotification
            if queryNotification.queryNotificationReason == .recordDeleted {
                //
                // If the record has been deleted in CloudKit then delete the local copy here
            } else {
                // If the record has been created or changed, we fetch the data from CloudKit
                let database: CKDatabase
      //          if queryNotification.isPublicDatabase        //.databaseScope.self
                
          //      let databaseScope = CKDatabase.Scope.
                let dict = userInfo as! [String: NSObject]

               guard let notification:CKDatabaseNotification = CKNotification(fromRemoteNotificationDictionary:dict) as? CKDatabaseNotification else { return }
                
                switch notification.databaseScope
                {
                case .public:
                    database = CKContainer.default().publicCloudDatabase
                default:
                    database = CKContainer.default().privateCloudDatabase

                }

                database.fetch(withRecordID: queryNotification.recordID!, completionHandler: { (record: CKRecord?, error: NSError?) -> Void in
                    guard error == nil else {
                        // Handle the error here
                        return
                    }
     
                    if queryNotification.queryNotificationReason == .recordUpdated {
                        // Use the information in the record object to modify your local data
                    } else {
                        // Use the information in the record object to create a new local object
                    }
                    } as! (CKRecord?, Error?) -> Void)
            }
        }
    }

    //
    func fetchNotificationChanges() {
        let operation = CKFetchNotificationChangesOperation(previousServerChangeToken: nil)
     
        var notificationIDsToMarkRead = [CKNotification.ID]()
     
        operation.notificationChangedBlock = { (notification: CKNotification) -> Void in
            // Process each notification received
            if notification.notificationType == .query {
                let queryNotification = notification as! CKQueryNotification
                //let reason = queryNotification.queryNotificationReason
                let recordID = queryNotification.recordID
     
                // Do your process here depending on the reason of the change
     
                // Add the notification id to the array of processed notifications to mark them as read
                notificationIDsToMarkRead.append(queryNotification.notificationID!)
            }
        }
     
        operation.fetchNotificationChangesCompletionBlock = { (serverChangeToken: CKServerChangeToken?, operationError: NSError?) -> Void in
            guard operationError == nil else {
                // Handle the error here
                return
            }
     
            // Mark the notifications as read to avoid processing them again
            // CKFetchRecordZoneChangesOperation()
            
            // Mark the notifications as read to avoid processing them again
            let markOperation = CKMarkNotificationsReadOperation(notificationIDsToMarkRead: notificationIDsToMarkRead)
            markOperation.markNotificationsReadCompletionBlock = ({ (notificationIDsMarkedRead: [CKNotification.ID]?, operationError: NSError?) -> Void in
                guard operationError == nil else {
                    // Handle the error here
                    return
                }
                } as! ([CKNotification.ID]?, Error?) -> Void)
                guard operationError == nil else {
                    // Handle the error here
                    return
                }
               // } as? ([CKNotification.ID]?, Error?) -> Void
     
            let operationQueue = OperationQueue()
            operationQueue.addOperation(markOperation)
            } as? (CKServerChangeToken?, Error?) -> Void
     
        /*
        let operationQueue = OperationQueue()
        operationQueue.addOperation(operation)
             as! (CKServerChangeToken?, Error?) -> Void
        */
        }
}



