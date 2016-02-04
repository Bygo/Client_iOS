//
//  MenuVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 1/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class MenuVC: UITableViewController {
    
    // MARK: - Menu Features
    let menuOptions = [MenuOptions.Rent, MenuOptions.Dashboard, MenuOptions.History, MenuOptions.Settings, MenuOptions.Help]
    let nonUserMenuOptions = [MenuOptions.Rent, MenuOptions.SignUp]
    
    
    // MARK: - Outlets
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var profileHeader: UIView!
    
    var delegate:MenuDelegate?
    var model:Model? {
        didSet { configureUI() }
    }
    
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the user specific settings
        configureUI()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Updating UI
    func userDidLogin() {
        configureUI()
        tableView.reloadData()
    }
    
    func userDidLogout() {
        configureUI()
        tableView.reloadData()
    }
    
    func userDidUpdateAccountSettings() {
        configureUI()
        tableView.reloadData()
    }
    
    func configureUI() {
        guard let model = model else { return }
        
        if model.userServiceProvider.isLocalUserLoggedIn() {
            configureUserSpecificUI()
        } else {
            configureDefaultUI()
        }
    }
    
    func configureUserSpecificUI() {
        // Setup the user profile imageview
        profileImageView.hidden = false
        usernameLabel.hidden = false
        profileHeader.hidden = false
        profileImageView.contentMode = UIViewContentMode.ScaleAspectFill
        profileImageView.backgroundColor = .lightGrayColor()
        profileImageView.clipsToBounds = true
        profileImageView.layer.cornerRadius = 34.0
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 0.0
        
        // Set the user profile name and image
        guard let model = model else { return }
        guard let user = model.userServiceProvider.getLocalUser() else { return }
        guard let firstName = user.firstName else { return }
        guard let lastName = user.lastName else { return }
        usernameLabel.text = "\(firstName) \(lastName)"
        tableView.layoutIfNeeded()
    }
    
    func configureDefaultUI() {
        profileImageView.hidden = true
        usernameLabel.hidden = true
        profileHeader.hidden = true
        tableView.layoutIfNeeded()
    }
    
    
    // MARK: - TableView Data Source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let model = model else { return 0 }
        if model.userServiceProvider.isLocalUserLoggedIn() {
            return menuOptions.count
        } else {
            return nonUserMenuOptions.count
        }
    }
    
    // Create the menu option cells. Dependent on whether the user is logged in or not.
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("MenuOption", forIndexPath: indexPath) as? MenuOptionTableViewCell else { return UITableViewCell() }
        
        // Configure the cell
        guard let model = model else { return UITableViewCell() }
        if model.userServiceProvider.isLocalUserLoggedIn() {
            cell.textLabel?.text = stringForMenuOption(menuOptions[indexPath.row])
        } else {
            cell.textLabel?.text = stringForMenuOption(nonUserMenuOptions[indexPath.row])
        }
        return cell
    }
    
    
    // MARK: - TableView Delegate
    // Select the correct menu option based on wether or not the user is logged in. There are different menu options in each of these cases.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let model = model else { return }
        if model.userServiceProvider.isLocalUserLoggedIn() {
            delegate?.didSelectMenuOption(menuOptions[indexPath.row])
        } else {
            delegate?.didSelectMenuOption(nonUserMenuOptions[indexPath.row])
        }
    }
    
    
    // Return the actually string of text that the user will see in the menu
    func stringForMenuOption(option:MenuOptions) -> String {
        // FIXME: This needs to return a localized string
        switch option {
        case .Rent:         return "Rent"
        case .Dashboard:    return "Dashboard"
        case .History:      return "History"
        case .Settings:     return "Settings"
        case .Help:         return "Help"
        case .SignUp:       return "Sign Up"
        }
    }
}



enum MenuOptions {
    case Rent
    case Dashboard
    case History
    case Settings
    case SignUp
    case Help
}

protocol MenuDelegate {
    func didSelectMenuOption(option:MenuOptions)
    func shouldMenuOpen() -> Bool
}
