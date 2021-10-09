//
//  iCloudFunctions.swift
//  TSNotes
//
//  Created by Jeanne's MacBook on 5/31/19.
//  Copyright © 2019 LCI. All rights reserved.
//

/**
    This class houses the functions that communicate with iCloud
*/


import Foundation
import CloudKit

// Variable declarations



class CKFunctions {
    
    /// Get container ID
    ///
    /// - Returns: <#return value description#>
    /*
    func getCKID () -> String {
       return ckID
    }

        func initCloudDB () {
            let cloudRecord = CKRecord(recordType: "Note")
        }
     */

    /**
      [From Building a Shopping List Application With CloudKit - ENVATO TUTS+](https://code.tutsplus.com/tutorials/building-a-shopping-list-application-with-cloudkit-introduction--cms-24674)
    */
  static  func fetchUserRecordID() {
        
        // Fetch User Record
        defaultContainer.fetchUserRecordID { (recordID, error) -> Void in
            if let responseError = error {
                print(responseError)
                
            } else if let userRecordID = recordID {
                DispatchQueue.main.sync {
                    fetchUserRecord(recordID: userRecordID)
                }
            }
        }
    }
    
    /**
     [From Building a Shopping List Application With CloudKit - ENVATO TUTS+](https://code.tutsplus.com/tutorials/building-a-shopping-list-application-with-cloudkit-introduction--cms-24674)
        [A reference to Markup key words is here](https://nshipster.com/swift-documentation/)

     */
    
    /// Fetch user private record
    ///
    /// - Parameter recordID: <#recordID description#>
    /// - Returns: user record
    
  static  func fetchUserRecord(recordID: CKRecord.ID) {
        
        // Fetch User Record
        privateCloudDB.fetch(withRecordID: recordID) { (record, error) -> Void in
            if let responseError = error {
                print(responseError)
                
            } else if let userRecord = record {
                print(userRecord)
            }
        }
    }
}

/*
enum NoteKey: String {
    case createDateTS
    case noteModifiedDateTime
    case noteModifiedDateTS
    case noteText
    case notesList
}
*/
