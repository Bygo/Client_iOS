//
//  DepartmentsServiceProvider.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 3/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class DepartmentsServiceProvider: NSObject {
    let serverURL:String
    
    init(serverURL:String) {
        self.serverURL = serverURL
    }
    
    func refreshDepartments(completionHandler:(success:Bool)->Void) {
        
        print("Refreshing departments")
        
        // If there are Departments in the local cache, return success
        // FIXME: Bad assumptions here. Need to check some dateLastModified attribute
        let realm = try! Realm()
        if realm.objects(Department).count > 0 {
            completionHandler(success: true)
            return
        }
        
        // Create the request
        let urlString       = "\(serverURL)/request/all_departments"
        guard let request   = URLServiceProvider().getNewGETRequest(withURL: urlString) else { return }
        
        // Execute the request
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            
            // Handle the response
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200: // Catching status code 200, success
                do {
                    
                    print("Caught 200")
                    
                    // Parse the JSON response object
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let departmentsData = json["departments"] as? [[String:AnyObject]] else { return }
                    
                    print(json)
                    
                    dispatch_async(GlobalMainQueue, {
                        let realm = try! Realm()
                        
                        for departmentData in departmentsData {
                            
                            guard let name          = departmentData["name"]            as? String else { return }
                            guard let departmentID  = departmentData["department_id"]   as? String else { return }
                            
                            // Create the new Department entity
                            let department          = Department()
                            department.name         = name
                            department.departmentID = departmentID
                            try! realm.write { realm.add(department) }
                        }
                        
                        completionHandler(success: true)
                    })
                } catch {
                    dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
                }
            default:
                print("/request/all_departments : \(statusCode)")
                dispatch_async(dispatch_get_main_queue(), { completionHandler(success: false) })
            }
        })
        task.resume()
    }
}
