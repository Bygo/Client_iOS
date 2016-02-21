//
//  PhoneNumberVerificationServiceProvider.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 20/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class PhoneNumberVerificationServiceProvider: NSObject {
    let serverURL: String
    
    init(serverURL:String) {
        self.serverURL = serverURL
    }
    
    func sendPhoneNumberVerificationCode(userID:String, completionHandler:(success:Bool)->Void) {
        guard let url = NSURL(string: "\(serverURL)/phone_number_verification/send_code") else { return }
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        let params = ["user_id":userID]
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if error != nil {
                    completionHandler(success: false)
                    return
                }
                
                let statusCode = (response as? NSHTTPURLResponse)!.statusCode
                switch statusCode {
                case 200:
                    completionHandler(success: true)
                default:
                    print("/phone_number_verification/send_code : \(statusCode)")
                    completionHandler(success: false)
                }
            })
            task.resume()
        } catch {
            completionHandler(success: false)
        }
    }
    
    func checkPhoneNumberVerificationCode(userID: String, code:String, completionHandler:(success:Bool)->Void) {
        guard let url = NSURL(string: "\(serverURL)/phone_number_verification/check_code") else { return }
        let request = NSMutableURLRequest(URL: url)
        let session = NSURLSession.sharedSession()
        request.HTTPMethod = "POST"
        let params = ["user_id":userID, "verification_code":code]
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(params, options: [])
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            request.addValue("application/json", forHTTPHeaderField: "Accept")
            
            let task = session.dataTaskWithRequest(request, completionHandler: { (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
                if error != nil {
                    completionHandler(success: false)
                    return
                }
                
                let statusCode = (response as? NSHTTPURLResponse)!.statusCode
                switch statusCode {
                case 200:
                    let realm = try! Realm()
                    guard let user = realm.objects(User).filter("userID == \"\(userID)\"").first else { return }
                    try! realm.write {
                        user.isPhoneNumberVerified = true
                    }
                    
                    completionHandler(success: true)
                    
                default:
                    print("/phone_number_verification/check_code : \(statusCode)")
                    completionHandler(success: false)
                }
            })
            task.resume()
        } catch {
            completionHandler(success: false)
        }
    }
}
