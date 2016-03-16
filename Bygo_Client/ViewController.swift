//
//  ViewController.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 1/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class ViewController: UIViewController, MenuContainerDelegate, LoginDelegate, SettingsDelegate, HomeDelegate, DashboardDelegate {

    let model = Model()
    
    @IBOutlet var menuContainer:UIViewController?
    @IBOutlet var settingsContainer:UIViewController?
    @IBOutlet var discoverContainer:UIViewController?
    @IBOutlet var dashboardContainer:UIViewController?
    @IBOutlet var loginContainer:UINavigationController?
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    var locationManager = CLLocationManager()
    var searchRegion:MKCoordinateRegion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        NSUserDefaults.standardUserDefaults().setValue("1", forKey: "LocalUserID")
        
        let loadedData = NSUserDefaults.standardUserDefaults().boolForKey("isDataLoaded")
        
        if !loadedData {
            initWithDemoData()
        }
        
        (UIApplication.sharedApplication().delegate as? AppDelegate)?.model = model
        
        refreshModules()
        
        // Ask for location services
        self.locationManager.requestWhenInUseAuthorization()
        if CLLocationManager.authorizationStatus() == CLAuthorizationStatus.AuthorizedWhenInUse {
            if let currentLocation:CLLocation = self.locationManager.location {
                let kACCEPTABLE_DISTANCE_IN_METERS:Double = 7500
                self.searchRegion = MKCoordinateRegionMakeWithDistance(currentLocation.coordinate, kACCEPTABLE_DISTANCE_IN_METERS, kACCEPTABLE_DISTANCE_IN_METERS)
            }
        } else {
            //TODO: Display message to user that the app will not work without location services
            print("Cannot work without location services")
        }
    }
    
    
    func initWithDemoData() {
        let realm = try! Realm()
        
        let currentUser = User()
        currentUser.userID = "1"
        currentUser.firstName = "Nick"
        currentUser.lastName = "Garfield"
        currentUser.phoneNumber = "+1 309 363 7151"
        currentUser.isPhoneNumberVerified = true
        currentUser.email = "nick@bygo.io"
        currentUser.isEmailVerified = true
        currentUser.dateLastModified = NSDate()
        
        
        let user1 = User()
        user1.userID = "2"
        user1.firstName = "Sayan"
        user1.lastName = "Roychowhdury"
        user1.phoneNumber = "+1 123 456 7890"
        user1.isPhoneNumberVerified = true
        user1.email = "sayan@bygo.io"
        user1.isEmailVerified = true
        user1.dateLastModified = NSDate()
        
        
        let listing1 = Listing()
        listing1.listingID = "1"
        listing1.name = "Accoustic Guitar"
        listing1.categoryID = "5699257587728384"
        listing1.totalValue.value = 150.0
        listing1.hourlyRate.value = 2.0
        listing1.dailyRate.value = 7.0
        listing1.weeklyRate.value = 25.0
        listing1.itemDescription = "A 6-string accoustic guitar"
        
        
        let ad1 = AdvertisedListing()
        ad1.isSnapshot = false
        ad1.score = 1.0
        ad1.name = "2-Person Camping Tent"
        ad1.distance = 0.5
        ad1.ownerID = "2"
        ad1.rating.value = 5.0
        ad1.totalValue.value = 60.0
        ad1.hourlyRate.value = 2.0
        ad1.dailyRate.value = 4.0
        ad1.weeklyRate.value = 12.0
        ad1.categoryID = "5746055551385600"
        ad1.itemDescription = "An easy to-use camping tent perfect for 2 people."
        ad1.listingID = "2"
        
        
        let ad2 = AdvertisedListing()
        ad2.isSnapshot = false
        ad2.score = 2.0
        ad2.name = "Xbox 360"
        ad2.distance = 0.4
        ad2.ownerID = "2"
        ad2.rating.value = 4.0
        ad2.totalValue.value = 300.0
        ad2.hourlyRate.value = 3.0
        ad2.dailyRate.value = 5.0
        ad2.weeklyRate.value = 20.0
        ad2.categoryID = "5684666375864320"
        ad2.itemDescription = "An Xbox 360 from 2013. Includes two controllers, a power cabel, and an HDMI cabel."
        ad2.listingID = "3"
        
        
        let ad3 = AdvertisedListing()
        ad3.isSnapshot = false
        ad3.score = 3.0
        ad3.name = "White Board"
        ad3.distance = 0.4
        ad3.ownerID = "2"
        ad3.rating.value = 3.0
        ad3.totalValue.value = 300.0
        ad3.hourlyRate.value = 3.0
        ad3.dailyRate.value = 5.0
        ad3.weeklyRate.value = 20.0
        ad3.categoryID = "5752754626625536"
        ad3.itemDescription = "3 feet by 6 feet white board. Includes a black marker"
        ad3.listingID = "4"
        
        
        let rentEvent                   = RentEvent()
        rentEvent.eventID               = "1"
        rentEvent.ownerID               = "1"
        rentEvent.renterID              = "2"
        rentEvent.listingID             = "1"
        rentEvent.rentalRate.value      = 2.0
        rentEvent.timeFrame             = "Day"
        rentEvent.proposedBy            = "Renter"
        rentEvent.status                = "Proposed"
        rentEvent.startMeetingEventID   = "0"
        rentEvent.endMeetingEventID     = nil
        
        
        try! realm.write {
            realm.add(currentUser)
            realm.add(user1)
            realm.add(listing1)
            realm.add(rentEvent)
            realm.add(ad1)
            realm.add(ad2)
            realm.add(ad3)
        }
        
        NSUserDefaults.standardUserDefaults().setBool(true, forKey: "isDataLoaded")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func refreshModules() {
        removeModule(&menuContainer)
        removeModule(&settingsContainer)
        removeModule(&discoverContainer)
        removeModule(&dashboardContainer)
        
        addModule("Menu", vc: &menuContainer)
        addModule("Settings", vc: &settingsContainer)
        addModule("Dashboard", vc: &dashboardContainer)
        addModule("Discover", vc: &discoverContainer)
        
        (menuContainer as? MenuContainerVC)?.delegate   = self
        (menuContainer as? MenuContainerVC)?.model      = model
        
        ((settingsContainer as? UINavigationController)?.topViewController as? SettingsVC)?.delegate    = self
        ((settingsContainer as? UINavigationController)?.topViewController as? SettingsVC)?.model       = model
    
        ((dashboardContainer as? UINavigationController)?.topViewController as? DashboardVC)?.model = model
        ((dashboardContainer as? UINavigationController)?.topViewController as? DashboardVC)?.delegate = self
        
        ((discoverContainer as? UINavigationController)?.topViewController as? BygoVC)?.model           = model
        ((discoverContainer as? UINavigationController)?.topViewController as? BygoVC)?.delegate        = self
        
        view.bringSubviewToFront(discoverContainer!.view)
        view.bringSubviewToFront(menuContainer!.view)
        panGestureRecognizer.addTarget(menuContainer!, action: "panGestureRecognized:")
    }
    
    private func removeModule(inout vc:UIViewController?) {
        vc?.view.removeFromSuperview()
        vc?.removeFromParentViewController()
        vc = nil
    }


    private func addModule(moduleName:String, inout vc:UIViewController?) {
        let storyboard = UIStoryboard(name: moduleName, bundle: NSBundle.mainBundle())
        vc = storyboard.instantiateInitialViewController()
        vc?.view.frame = CGRectMake(0, 0, view.bounds.width, view.bounds.height)
        view.addSubview(vc!.view)
        addChildViewController(vc!)
        vc?.didMoveToParentViewController(self)
    }
    
    
    func showLoginMenu() {
        let loginSB = UIStoryboard(name: "Login", bundle: NSBundle.mainBundle())
        loginContainer = loginSB.instantiateInitialViewController() as? UINavigationController
        (loginContainer?.topViewController as? WelcomeVC)?.model = model
        (loginContainer?.topViewController as? WelcomeVC)?.delegate = self
        presentViewController(loginContainer!, animated: true, completion: nil)
    }
    
    
    // MARK: - MenuContainerDelegate
    func didSelectMenuOption(option:MenuOptions) {
        switch option {
        case .Discover:     view.bringSubviewToFront(discoverContainer!.view)
        case .Dashboard:    view.bringSubviewToFront(dashboardContainer!.view)
        case .History:      break
        case .Settings:     view.bringSubviewToFront(settingsContainer!.view)
        case .Help:         break
        case .SignUp:       showLoginMenu()
        }
        view.bringSubviewToFront(menuContainer!.view)
    }
    
    
    private var isMenuAvailable:Bool = true
    
    func shouldMenuOpen() -> Bool {
        return isMenuAvailable
    }
    
    func didMoveOneLevelIntoNavigation() {
        isMenuAvailable = false
    }
    
    func didReturnToBaseLevelOfNavigation() {
        isMenuAvailable = true
    }
    
    
    // MARK: - Rent Delegate    
    func openMenu() {
        (menuContainer as? MenuContainerVC)?.openMenu()
    }
    
    // MARK: - Login Delegate
    func userDidLogin(shouldDismissLogin:Bool) {
        (menuContainer as? MenuContainerVC)?.userDidLogin()
        ((settingsContainer as? UINavigationController)?.topViewController as? SettingsVC)?.userDidLogin()
        ((discoverContainer as? UINavigationController)?.topViewController as? BygoVC)?.userDidLogin()
        ((dashboardContainer as? UINavigationController)?.topViewController as? DashboardVC)?.userDidLogin()
        
        if shouldDismissLogin {
            self.loginContainer?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func phoneNumberDidVerify(shouldDismissLogin:Bool) {
        
        if shouldDismissLogin {
            self.loginContainer?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func facebookButtonTapped(completionHandler:(success:Bool, data:[String:AnyObject]?)->Void) {
        
    }
    
    
    // MARK: - Settings Delegate
    func didUpdateAccountSettings() {
//        (menuContainer as? MenuContainerVC)?.userDidUpdateAccountSettings()
    }
    
    func didLogout() {
        ((discoverContainer as? UINavigationController)?.topViewController as? BygoVC)?.userDidLogout()
        ((dashboardContainer as? UINavigationController)?.topViewController as? DashboardVC)?.userDidLogout()
        (menuContainer as? MenuContainerVC)?.userDidLogout()

        view.bringSubviewToFront(discoverContainer!.view)
        view.bringSubviewToFront(menuContainer!.view)
    }
}

