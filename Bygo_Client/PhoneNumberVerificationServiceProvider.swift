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
    
    func sendPhoneNumberVerificationCode(userID:String, completionHandler:(success:Bool, error: BygoError?)->Void) {
        let urlString = "\(serverURL)/verification/phone_number/send_code/user_id=\(userID)"
        guard let request = URLServiceProvider().getNewGETRequest(withURL: urlString) else { return }
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(request, completionHandler: {
            (data:NSData?, response:NSURLResponse?, error:NSError?) -> Void in
            if error != nil {
                completionHandler(success: false, error: .Unknown)
                return
            }
            
            let statusCode = (response as? NSHTTPURLResponse)!.statusCode
            switch statusCode {
            case 200:
                completionHandler(success: true, error: .VerificationCodeSent)
                
            case 400:
                do {
                    let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                    guard let message = json["message"] as? String else { completionHandler(success: false, error: .Unknown); return }
                    
                    switch message {
                    case "Phone number already verified":
                        completionHandler(success: false, error: .PhoneNumberAlreadyVerified)
                        
                    default:
                        completionHandler(success: false, error: .Unknown)
                    }
                } catch {
                    completionHandler(success: false, error: .Unknown)
                }
                
            case 412:
                completionHandler(success: false, error: .PhoneNumberNotFound)
                
            default:
                print("/verification/phone_number/send_code/ : \(statusCode)")
                completionHandler(success: false, error: .Unknown)
            }
        })
        task.resume()
    }
    
    func checkPhoneNumberVerificationCode(userID: String, code:String, completionHandler:(success:Bool, error: BygoError?)->Void) {
        guard let url = NSURL(string: "\(serverURL)/verification/phone_number/check_code") else { return }
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
                    completionHandler(success: false, error: .Unknown)
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
                    
                    completionHandler(success: true, error: nil)
                    
                case 400:
                    do {
                        let json = try NSJSONSerialization.JSONObjectWithData(data!, options: [])
                        guard let message = json["message"] as? String else { completionHandler(success: false, error: .Unknown); return }
                        
                        switch message {
                        case "Phone number already verified":
                            completionHandler(success: false, error: .PhoneNumberAlreadyVerified)
                            
                        case "Verification code invalid":
                            completionHandler(success: false, error: .VerificationCodeInvalid)
                            
                        default:
                            completionHandler(success: false, error: .Unknown)
                        }
                    } catch {
                        completionHandler(success: false, error: .Unknown)
                    }
                    
                case 412:
                    completionHandler(success: false, error: .PhoneNumberNotFound)
                    
                case 419:
                    completionHandler(success: false, error: .VerificationCodeExpired)
                    
                default:
                    print("/phone_number_verification/check_code : \(statusCode)")
                    completionHandler(success: false, error: .Unknown)
                }
            })
            task.resume()
        } catch {
            completionHandler(success: false, error: .Unknown)
        }
    }
}
