//
//  SettingsVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class SettingsVC: UITableViewController, AccountSettingsDelegate, HomeAddressDelegate {

    // MARK: - Properties
    @IBOutlet var profileImageViewVerticalOffset: NSLayoutConstraint!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var paymentMethodsContainer:UINavigationController!
    
    private let kGENERAL_SECTION                = 0
    private let kHOME_ADDRESS_SECTION           = 1
    private let kLOGOUT_SECTION                 = 2
    
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
        profileImageView.contentMode            = UIViewContentMode.ScaleAspectFill
        profileImageView.clipsToBounds          = true
        profileImageView.layer.cornerRadius     = profileImageView.bounds.width / 2.0
        profileImageView.layer.masksToBounds    = true
        profileImageView.layer.borderWidth      = 0.0
        
        refreshControl = UIRefreshControl()
        refreshControl?.addTarget(self, action: #selector(SettingsVC.configureUserSpecificUI), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl!)
        
        // Configure the user specific settings
        configureUserSpecificUI()
    }
    
    override func viewDidAppear(animated: Bool) {
        delegate?.didReturnToBaseLevelOfNavigation()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
        
        refreshControl?.endRefreshing()
        guard let profileLink = localUser.profileImageLink else { profileImageView.image = nil; return }
        guard let url = NSURL(string: profileLink) else { profileImageView.image = nil; return }
        profileImageView.hnk_setImageFromURL(url)
    }
    
    func configureUserSpecificUI() {
        configureUsernameAndProfileImage()
    }
    
    
    // MARK: - Table View Data Source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        let kNUM_SETTINGS_SECTIONS = 3
        return kNUM_SETTINGS_SECTIONS
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == kGENERAL_SECTION {
            return generalOptions.count
        } else if section == kHOME_ADDRESS_SECTION {
            return 1
        } else if section == kLOGOUT_SECTION {
            return 1
        }
        return 0
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case kGENERAL_SECTION:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("GeneralSetting", forIndexPath: indexPath) as? BygoGeneralTableViewCell else { return UITableViewCell() }
            cell.titleLabel?.text = generalOptions[indexPath.row]
            return cell
            
        case kHOME_ADDRESS_SECTION:
            guard let cell = tableView.dequeueReusableCellWithIdentifier("HomeAddressCell", forIndexPath: indexPath) as? BygoTitleDetailTableViewCell else { return UITableViewCell() }
            guard let user = model?.userServiceProvider.getLocalUser() else { return cell }
            if let detail = user.homeAddress_name {
                cell.titleLabel.text = "Home Address"
                cell.detailLabel.text = detail
            } else {
                cell.titleLabel.text = "Add Your Home Address"
                cell.detailLabel.text = nil
            }
            return cell
            
        case kLOGOUT_SECTION:
            let cell = UITableViewCell()
            cell.textLabel?.text = "Log Out"
            cell.textLabel?.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
            cell.textLabel?.textColor = kCOLOR_TWO
            cell.backgroundColor = .whiteColor()
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
                
            case 2:
                showPaymentMethods()
                
            default: break
            }
            
        case kHOME_ADDRESS_SECTION:
            performSegueWithIdentifier("HomeAddressSegue", sender: nil)
            
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
            if scrollView.contentOffset.y < 0.0 {
                profileImageViewVerticalOffset.constant = 48.0 + scrollView.contentOffset.y/2.0
            }
        }
    }
    
    // MARK: - AccountSettingsDelegate
    func didUpdateAccountSettings() {
        delegate?.didUpdateAccountSettings()
        configureUsernameAndProfileImage()
    }
    
    // MARK: - HomeAddressDelegate
    func didUpdateHomeAddress() {
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .Fade)
    }
    
    // MARK: - Payments
    private func showPaymentMethods() {
        
    }
    
    func userDidCancelPayment() {
        dismissViewControllerAnimated(true, completion: nil)
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
            
        } else if segue.identifier == "HomeAddressSegue" {
            guard let navVC = segue.destinationViewController as? UINavigationController else { return }
            guard let destVC = navVC.topViewController as? HomeAddressVC else { return }
            destVC.model = model
            destVC.delegate = self
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