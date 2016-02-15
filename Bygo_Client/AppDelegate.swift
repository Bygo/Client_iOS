//
//  AppDelegate.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 1/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import CoreData
import FBSDKCoreKit
import Google.CloudMessaging

enum IconBadgeFields:String {
    case UnseenRentRequests = "UnseenRentRequests"
    case UnseenScheduledMeetings = "UnseenScheduledMeetings"
}


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GGLInstanceIDDelegate, GCMReceiverDelegate{

    var window: UIWindow?

    var connectedToGCM = false
    var subscribedToTopic = false
    var gcmSenderID: String?
    var registrationToken: String?
    var registrationOptions = [String: AnyObject]()
    
    private let registrationKey     = "onRegistrationCompleted"
    private let messageKey          = "onMessageReceived"
    private let subscriptionTopic   = "/topics/global"
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Configure Facebook SDK
        FBSDKApplicationDelegate.sharedInstance().application(application, didFinishLaunchingWithOptions: launchOptions)
        
        // Configure Google Messaging
        let settings: UIUserNotificationSettings =
        UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: nil)
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        
        var configureError:NSError?
        GGLContext.sharedInstance().configureWithError(&configureError)
        assert(configureError == nil, "Error configuring Google services: \(configureError)")
        gcmSenderID = GGLContext.sharedInstance().configuration.gcmSenderID
        
        if !NSUserDefaults.standardUserDefaults().boolForKey("HasPreviouslyLaunched") { // First launch
            NSUserDefaults.standardUserDefaults().setBool(true, forKey: "HasPreviouslyLaunched")
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: IconBadgeFields.UnseenRentRequests.rawValue)
            NSUserDefaults.standardUserDefaults().setInteger(0, forKey: IconBadgeFields.UnseenScheduledMeetings.rawValue)
            NSUserDefaults.standardUserDefaults().synchronize()
            
        }
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
        // TODO: If user is not registered to receive push notifications, refresh appropriate data
        
        let unseenScheduledMeetings = NSUserDefaults.standardUserDefaults().integerForKey(IconBadgeFields.UnseenScheduledMeetings.rawValue)
        let unseenRentRequests      = NSUserDefaults.standardUserDefaults().integerForKey(IconBadgeFields.UnseenRentRequests.rawValue)
        
        if unseenRentRequests > 0 {
            // TODO: Load rent requests
        }
        
        if unseenScheduledMeetings >  0 {
            // TODO: Load meetings
        }
        
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: IconBadgeFields.UnseenRentRequests.rawValue)
        NSUserDefaults.standardUserDefaults().setInteger(0, forKey: IconBadgeFields.UnseenScheduledMeetings.rawValue)
        NSUserDefaults.standardUserDefaults().synchronize()
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
        
        FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        // SAFE TO DELETE
        // self.saveContext()
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject) -> Bool {
        return FBSDKApplicationDelegate.sharedInstance().application(application, openURL: url, sourceApplication: sourceApplication, annotation: annotation)
    }
    
    
    func subscribeToTopic() {
        // If the app has a registration token and is connected to GCM, proceed to subscribe to the
        // topic
        if(registrationToken != nil && connectedToGCM) {
            GCMPubSub.sharedInstance().subscribeWithToken(self.registrationToken, topic: subscriptionTopic,
                options: nil, handler: {(NSError error) -> Void in
                    if (error != nil) {
                        // Treat the "already subscribed" error more gently
                        if error.code == 3001 {
                            print("Already subscribed to \(self.subscriptionTopic)")
                        } else {
                            print("Subscription failed: \(error.localizedDescription)");
                        }
                    } else {
                        self.subscribedToTopic = true;
                        NSLog("Subscribed to \(self.subscriptionTopic)");
                    }
            })
        }
    }

    func application( application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData ) {
        // [END receive_apns_token]
        // [START get_gcm_reg_token]
            
        // Create a config and set a delegate that implements the GGLInstaceIDDelegate protocol.
        let instanceIDConfig        = GGLInstanceIDConfig.defaultConfig()
        instanceIDConfig.delegate   = self

        // Start the GGLInstanceID shared instance with that config and request a registration
        // token to enable reception of notifications
        GGLInstanceID.sharedInstance().startWithConfig(instanceIDConfig)
            
            
        // FIXME: When going into production, change the sandbox flag to false
        registrationOptions = [kGGLInstanceIDRegisterAPNSOption:deviceToken, kGGLInstanceIDAPNSServerTypeSandboxOption:true]
        
        
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID, scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
            
        // [END get_gcm_reg_token]
    }
    
    func application( application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError ) {
        print("Registration for remote notification failed with error: \(error.localizedDescription)")
        // [END receive_apns_token_error]
        let userInfo = ["error": error.localizedDescription]
        NSNotificationCenter.defaultCenter().postNotificationName(registrationKey, object: nil, userInfo: userInfo)
    }
    
    // [START ack_message_reception]
    func application( application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject]) {
        print("Notification A Received: \(userInfo)")
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo);
        
        // Handle the received message
        // [START_EXCLUDE]
        NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil, userInfo: userInfo)
        // [END_EXCLUDE]
    }
    
    func application( application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject], fetchCompletionHandler handler: (UIBackgroundFetchResult) -> Void) {
        print("Notification B Received: \(userInfo)")
        // This works only if the app started the GCM service
        GCMService.sharedInstance().appDidReceiveMessage(userInfo)
        
        // Handle the received message
        if let type = userInfo["type"] as? String {
            if type == "Rent_Request_Proposed" {
                let unseenRentRequests = NSUserDefaults.standardUserDefaults().integerForKey(IconBadgeFields.UnseenRentRequests.rawValue)
                NSUserDefaults.standardUserDefaults().setInteger(unseenRentRequests+1, forKey: IconBadgeFields.UnseenRentRequests.rawValue)
                
            } else if type == "Rent_Request_Accepted" {
                let unseenScheduledMeetings = NSUserDefaults.standardUserDefaults().integerForKey(IconBadgeFields.UnseenScheduledMeetings.rawValue)
                NSUserDefaults.standardUserDefaults().setInteger(unseenScheduledMeetings+1, forKey: IconBadgeFields.UnseenScheduledMeetings.rawValue)
                
            } else if type == "Rent_Request_Rejected" {
                
            }
            
            NSUserDefaults.standardUserDefaults().synchronize()
        }
        
        // Invoke the completion handler passing the appropriate UIBackgroundFetchResult value
        // [START_EXCLUDE]
        NSNotificationCenter.defaultCenter().postNotificationName(messageKey, object: nil, userInfo: userInfo)
        handler(UIBackgroundFetchResult.NoData)
        // [END_EXCLUDE]
    }
    // [END ack_message_reception]
    
    func registrationHandler(registrationToken: String!, error: NSError!) {
        if (registrationToken != nil && registrationToken.characters.count > 0) {
            self.registrationToken = registrationToken
            print("Registration Token: \(registrationToken)")
            self.subscribeToTopic()
            let userInfo = ["registrationToken": registrationToken]
            NSNotificationCenter.defaultCenter().postNotificationName(self.registrationKey, object: nil, userInfo: userInfo)
        } else {
            print("Registration to GCM failed with error: \(error.localizedDescription)")
            let userInfo = ["error": error.localizedDescription]
            NSNotificationCenter.defaultCenter().postNotificationName(self.registrationKey, object: nil, userInfo: userInfo)
        }
    }
    
    // [START on_token_refresh]
    func onTokenRefresh() {
        // A rotation of the registration tokens is happening, so the app needs to request a new token.
        print("The GCM registration token needs to be changed.")

        // TODO: Update the token in the server
        GGLInstanceID.sharedInstance().tokenWithAuthorizedEntity(gcmSenderID, scope: kGGLInstanceIDScopeGCM, options: registrationOptions, handler: registrationHandler)
    }
    
    // [END on_token_refresh]
    
    // [START upstream_callbacks]
    func willSendDataMessageWithID(messageID: String!, error: NSError!) {
        if (error != nil) {
            // Failed to send the message.
        } else {
            // Will send message, you can save the messageID to track the message
        }
    }
    
    func didSendDataMessageWithID(messageID: String!) {
        // Did successfully send message identified by messageID
    }
    // [END upstream_callbacks]
    
    func didDeleteMessagesOnServer() {
        // Some messages sent to this device were deleted on the GCM server before reception, likely
        // because the TTL expired. The client should notify the app server of this, so that the app
        // server can resend those messages.
    }
}

