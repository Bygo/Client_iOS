//
//  SettingsVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import Braintree
import RealmSwift

class SettingsVC: UITableViewController, AccountSettingsDelegate, NewFavoriteMeetingLocationDelegate, EditFavoriteMeetingLocationDelegate, BTDropInViewControllerDelegate {

    // MARK: - Properties
    @IBOutlet var profileImageViewVerticalOffset: NSLayoutConstraint!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var paymentMethodsContainer:UINavigationController!
    
    private let kGENERAL_SECTION                = 0
    private let kFAV_MEETING_LOCATIONS_SECTION  = 1
    private let kLOGOUT_SECTION                 = 2
    
    // FIXME: Pull text from some localized text repo
    let generalOptions = ["Account", "Payment"]
    
    var model:Model?
    var delegate:SettingsDelegate?
    var targetLocation:FavoriteMeetingLocation?
    
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.backgroundColor = kCOLOR_THREE
        
        // UI Design
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Configure the Settings view
        // FIXME: Pull UI constants from design repo
        profileImageView.contentMode            = UIViewContentMode.ScaleAspectFill
        profileImageView.clipsToBounds          = true
        profileImageView.layer.cornerRadius     = profileImageView.bounds.width / 2.0
        profileImageView.layer.masksToBounds    = true
        profileImageView.layer.borderWidth      = 0.0
        
        // Configure the user specific settings
        configureUserSpecificUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        delegate?.didReturnToBaseLevelOfNavigation()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func viewWillAppear(animated: Bool) {
        // shouldMenuOpen = true
        // TODO: This should probably be delegate function
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        // shouldMenuOpen = false
        // TODO: This should probably be a delegate function
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - User Specific Settings
    func userDidLogin() {
        configureUserSpecificUI()
        tableView.reloadData()
    }
    
    private func configureUsernameAndProfileImage() {
        guard let localUser = model?.userServiceProvider.getLocalUser() else { return }
        guard let firstName = localUser.firstName else { return }
        guard let lastName  = localUser.lastName else { return }
        usernameLabel.text  = "\(firstName) \(lastName)"
        
        guard let profileLink = localUser.profileImageLink else { profileImageView.image = nil; return }
        guard let url = NSURL(string: profileLink) else { profileImageView.image = nil; return }
        profileImageView.hnk_setImageFromURL(url)
    }
    
    private func configureUserSpecificUI() {
        configureUsernameAndProfileImage()
        
        // Reload the user's favorite meeting locations
        guard let localUser = model?.userServiceProvider.getLocalUser() else { return }
        guard let userID    = localUser.userID else { return }
        
        model?.favoriteMeetingLocationServiceProvider.fetchUsersFavoriteMeetingLocations(userID, completionHandler: {
            (success:Bool) in
            if success {
                dispatch_async(dispatch_get_main_queue(), {
                    self.tableView.reloadSections(NSIndexSet(index: self.kFAV_MEETING_LOCATIONS_SECTION), withRowAnimation: .Fade)
                })
            }
        })
    }
    
    
    // MARK: - Table View Data Source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let kNUM_SETTINGS_SECTIONS = 3
        return kNUM_SETTINGS_SECTIONS
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == kGENERAL_SECTION {
            let kNUM_GENERAL_SETTINGS_OPTIONS = 2
            return kNUM_GENERAL_SETTINGS_OPTIONS
            
        } else if section == kFAV_MEETING_LOCATIONS_SECTION {
            guard let localUser = model?.userServiceProvider.getLocalUser() else { return 0 }
            guard let userID    = localUser.userID else { return 0 }
            let realm           = try! Realm()
            return realm.objects(FavoriteMeetingLocation).filter("userID == \"\(userID)\"").count + 1
            
        } else if section == kLOGOUT_SECTION {
            let kNUM_LOGOUT_BUTTONS = 1
            return kNUM_LOGOUT_BUTTONS
        }
        return 0
    }
    
    
//    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
//        // FIXME: Pull text from some localized text repo
//        switch section {
//        case kGENERAL_SECTION:
//            return "General"
//        case kFAV_MEETING_LOCATIONS_SECTION:
//            return "Favorite Meeting Places"
//        default:
//            return ""
//        }
//    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // FIXME: Pull text from some localized text repo
        switch indexPath.section {
        case kGENERAL_SECTION:
            let cell = tableView.dequeueReusableCellWithIdentifier("GeneralSetting", forIndexPath: indexPath)
            cell.textLabel?.text = generalOptions[indexPath.row]
            return cell
            
        case kFAV_MEETING_LOCATIONS_SECTION:
            
            let indexOfNewFavoriteLocationButton = tableView.numberOfRowsInSection(kFAV_MEETING_LOCATIONS_SECTION)-1
            if indexPath.row == indexOfNewFavoriteLocationButton {
                let cell = UITableViewCell()
                cell.textLabel?.text = "Add New Favorite Location"
                cell.backgroundColor    = kCOLOR_FIVE
                cell.textLabel?.textColor = .whiteColor()
                cell.textLabel?.textAlignment = .Center
                return cell
            }
            
            // Configure the cell
            guard let cell = tableView.dequeueReusableCellWithIdentifier("FavoriteMeetingPlace", forIndexPath: indexPath) as? FavoriteMeetingLocationTableViewCell else { return UITableViewCell() }
            guard let localUser     = model?.userServiceProvider.getLocalUser() else { return cell }
            guard let userID        = localUser.userID else { return cell }
            let realm               = try! Realm()
            let results             = realm.objects(FavoriteMeetingLocation).filter("userID == \"\(userID)\"")
            let location            = results[indexPath.row]
            guard let name          = location.name else { return cell }
            cell.titleLabel.text    = name
            return cell
            
        case kLOGOUT_SECTION:
            let cell = UITableViewCell()
            // FIXME: Pull text form some localized text repo
            cell.textLabel?.text = "Log Out"
            cell.textLabel?.textAlignment = .Center
            cell.textLabel?.textColor = .whiteColor()
            cell.backgroundColor = kCOLOR_TWO
            return cell
            
        default:
            return UITableViewCell()
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch indexPath.section {
        case kGENERAL_SECTION:
            switch indexPath.row {
            case 0:
                performSegueWithIdentifier("ShowAccountSettings", sender: nil)
            case 1:
                showPaymentMethods()
            default: break
            }
            
        case kFAV_MEETING_LOCATIONS_SECTION:
            switch indexPath.row {
            case tableView.numberOfRowsInSection(1)-1:
                performSegueWithIdentifier("ShowNewFavoriteMeetingLocation", sender: nil)
            default:
                guard let localUser = model?.userServiceProvider.getLocalUser() else { return }
                guard let userID    = localUser.userID else { return }
                let realm           = try! Realm()
                let results         = realm.objects(FavoriteMeetingLocation).filter("userID == \"\(userID)\"")
                targetLocation      = results[indexPath.row]
                performSegueWithIdentifier("ShowEditFavoriteMeetingLocation", sender: nil)
            }
            
        case kLOGOUT_SECTION:
            model?.userServiceProvider.logout({(success:Bool)->Void in
                if success {
                    self.tableView.reloadData()
                    self.delegate?.didLogout()
                } else {
                    print("Error logging out")
                }
            })
        default: break
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func scrollViewDidScroll(scrollView: UIScrollView) {
        if scrollView == tableView {
            profileImageViewVerticalOffset.constant = 16.0 + scrollView.contentOffset.y/2.0
        }
    }
    
    // MARK: - AccountSettingsDelegate
    func didUpdateAccountSettings() {
        delegate?.didUpdateAccountSettings()
        configureUsernameAndProfileImage()
    }
    
    // MARK: - Payments
    private func showPaymentMethods() {
        /*
        let meetingSB = UIStoryboard(name: "Payments", bundle: NSBundle.mainBundle())
        paymentMethodsContainer = meetingSB.instantiateViewControllerWithIdentifier("PaymentMethods") as? UINavigationController
        (paymentMethodsContainer?.topViewController as? PaymentMethodsVC)?.model = model
        presentViewController(paymentMethodsContainer, animated: true, completion: nil)
        */
        
        // Create a BTDropInViewController
        model?.paymentsServiceProvider.getBraintreeClient({
            (braintreeClient:BTAPIClient?) in
            print(braintreeClient)
        })
        
        
//        braintreeClient {
//            let dropInViewController = BTDropInViewController(APIClient: braintreeClient)
//            dropInViewController.delegate = self
//            
//            // This is where you might want to customize your view controller (see below)
//            
//            // The way you present your BTDropInViewController instance is up to you.
//            // In this example, we wrap it in a new, modally-presented navigation controller:
//            dropInViewController.navigationItem.leftBarButtonItem = UIBarButtonItem(
//                barButtonSystemItem: UIBarButtonSystemItem.Cancel,
//                target: self, action: "userDidCancelPayment")
//            let navigationController = UINavigationController(rootViewController: dropInViewController)
//            presentViewController(navigationController, animated: true, completion: nil)
//        }
    }
    
    func userDidCancelPayment() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dropInViewController(viewController: BTDropInViewController, didSucceedWithTokenization paymentMethodNonce: BTPaymentMethodNonce) {
        // Send payment method nonce to your server for processing
        // postNonceToServer(paymentMethodNonce.nonce)
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func dropInViewControllerDidCancel(viewController: BTDropInViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - NewFavoriteMeetingLocationDelegate 
    func didAddNewFavoriteMeetingLocation() {
        tableView.reloadSections(NSIndexSet(index: kFAV_MEETING_LOCATIONS_SECTION), withRowAnimation: .Fade)
    }
    
    
    // MARK: - EditFavoriteMeetingLocationDelegate
    func didUpdateFavoriteMeetingLocation() {
        tableView.reloadSections(NSIndexSet(index: kFAV_MEETING_LOCATIONS_SECTION), withRowAnimation: .Fade)
    }
    
    func didDeleteFavoriteMeetingLocation() {
        tableView.reloadSections(NSIndexSet(index: kFAV_MEETING_LOCATIONS_SECTION), withRowAnimation: .Fade)
    }
    
    // MARK: - UI Actions
    @IBAction func menuButtonTapped(sender: AnyObject) {
        delegate?.openMenu()
    }

    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "ShowAccountSettings" {
            guard let navVC = segue.destinationViewController as? UINavigationController else { return }
            guard let destVC = navVC.topViewController as? AccountSettingsVC else { return }
            destVC.model = model
            destVC.delegate = self
        } else if segue.identifier == "ShowNewFavoriteMeetingLocation" {
            guard let navVC = segue.destinationViewController as? UINavigationController else { return }
            guard let destVC = navVC.topViewController as? NewFavoriteMeetingLocationVC else { return }
            destVC.delegate = self
            destVC.model = model
        } else if segue.identifier == "ShowEditFavoriteMeetingLocation" {
            guard let navVC = segue.destinationViewController as? UINavigationController else { return }
            guard let destVC = navVC.topViewController as? EditFavoriteMeetingLocationVC else { return }
            destVC.model = model
            destVC.delegate = self
            destVC.location = targetLocation
        }
        
        delegate?.didMoveOneLevelIntoNavigation()
    }
}

public protocol SettingsDelegate {
    func openMenu()
    func didUpdateAccountSettings()
    func didLogout()
    func didMoveOneLevelIntoNavigation()
    func didReturnToBaseLevelOfNavigation()
}