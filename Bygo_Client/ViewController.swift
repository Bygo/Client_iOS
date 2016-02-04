//
//  ViewController.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 1/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController, MenuContainerDelegate, LoginDelegate, SettingsDelegate {

    let model = Model()
    
    @IBOutlet var menuContainer:UIViewController?
    @IBOutlet var settingsContainer:UIViewController?
    @IBOutlet var rentContainer:UIViewController?
    @IBOutlet var dashboardContainer:UIViewController?
    @IBOutlet var loginContainer:UINavigationController?
    
    @IBOutlet var panGestureRecognizer: UIPanGestureRecognizer!
    
    var locationManager = CLLocationManager()
    var searchRegion:MKCoordinateRegion?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
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

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    private func refreshModules() {
        removeModule(&menuContainer)
        removeModule(&settingsContainer)
        removeModule(&rentContainer)
        removeModule(&dashboardContainer)
        
        addModule("Menu", vc: &menuContainer)
        addModule("Settings", vc: &settingsContainer)
        addModule("Dashboard", vc: &dashboardContainer)
        addModule("Rent", vc: &rentContainer)
        
        (menuContainer as? MenuContainerVC)?.delegate   = self
        (menuContainer as? MenuContainerVC)?.model      = model
        
//        ((settingsContainer as? UINavigationController)?.topViewController as? SettingsVC)?.delegate    = self
        ((settingsContainer as? UINavigationController)?.topViewController as? SettingsVC)?.model       = model
    
        ((dashboardContainer as? UINavigationController)?.topViewController as? DashboardVC)?.model = model
        ((rentContainer as? UINavigationController)?.topViewController as? RentVC)?.model = model
        
        view.bringSubviewToFront(rentContainer!.view)
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
        (loginContainer?.topViewController as? SignUpVC)?.model = model
        (loginContainer?.topViewController as? SignUpVC)?.delegate = self
        presentViewController(loginContainer!, animated: true, completion: nil)
    }
    
    
    // MARK: - MenuContainerDelegate
    func didSelectMenuOption(option:MenuOptions) {
        switch option {
        case .Rent:         view.bringSubviewToFront(rentContainer!.view)
        case .Dashboard:    view.bringSubviewToFront(dashboardContainer!.view)
        case .History:      break
        case .Settings:     view.bringSubviewToFront(settingsContainer!.view)
        case .Help:         break
        case .SignUp:       showLoginMenu()
        }
        view.bringSubviewToFront(menuContainer!.view)
    }
    
    func shouldMenuOpen() -> Bool {
        return true
    }
    
    
    // MARK: - Login Delegate
    func userDidLogin(shouldDismissLogin:Bool) {
        (menuContainer as? MenuContainerVC)?.userDidLogin()
        ((settingsContainer as? UINavigationController)?.topViewController as? SettingsVC)?.userDidLogin()
        ((rentContainer as? UINavigationController)?.topViewController as? RentVC)?.userDidLogin()
        ((dashboardContainer as? UINavigationController)?.topViewController as? DashboardVC)?.userDidLogin()
        
        if shouldDismissLogin {
            self.loginContainer?.dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    func phoneNumberDidVerify(shouldDidmissLogin:Bool) {
        
    }
    
    func facebookButtonTapped(completionHandler:(success:Bool, data:[String:AnyObject]?)->Void) {
        
    }
    
    
    // MARK: - Settings Delegate
    func didUpdateAccountSettings() {
        
    }
    
    func didLogout() {
        
    }
}

