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
    let menuOptions = [MenuOptions.Discover, MenuOptions.Dashboard, MenuOptions.History, MenuOptions.Settings, MenuOptions.Help]
    let nonUserMenuOptions = [MenuOptions.Discover, MenuOptions.SignUp]
    
    
    // MARK: - Outlets
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var profileHeader: UIView!
    
    var delegate:MenuDelegate?
    var model:Model? 
    
    
    // MARK: - View Controller Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Configure the user specific settings
        // configureUI()
        
        view.backgroundColor = .clearColor()
        tableView.backgroundColor = .clearColor()
        profileHeader.backgroundColor = .clearColor()
        
        
        let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .ExtraLight))
        visualEffectView.frame = view.bounds
        tableView.addSubview(visualEffectView)
        tableView.sendSubviewToBack(visualEffectView)
        
        view.clipsToBounds          = false
        view.layer.shadowColor      = UIColor.blackColor().CGColor
        view.layer.shadowOffset     = CGSizeMake(1.5, 0.0)
        view.layer.shadowOpacity    = 0.25
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Updating UI
    func userDidLogin() {
        // configureUI()
        tableView.reloadData()
    }
    
    func userDidLogout() {
        // configureUI()
        tableView.reloadData()
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
        
        cell.textLabel?.font = UIFont.systemFontOfSize(20.0)
        
        // Configure the cell
        guard let model = model else { return UITableViewCell() }
        if model.userServiceProvider.isLocalUserLoggedIn() {
            cell.textLabel?.text = stringForMenuOption(menuOptions[indexPath.row])
            switch indexPath.row {
            case 0:
                cell.iconImageView.image = UIImage(named: "Rent")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            case 1:
                cell.iconImageView.image = UIImage(named: "Dashboard")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            case 2:
                cell.iconImageView.image = UIImage(named: "History")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            case 3:
                cell.iconImageView.image = UIImage(named: "Settings")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            case 4:
                cell.iconImageView.image = UIImage(named: "Help")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            default:
                break
            }
        } else {
            cell.textLabel?.text = stringForMenuOption(nonUserMenuOptions[indexPath.row])
            switch indexPath.row {
            case 0:
                cell.iconImageView.image = UIImage(named: "Rent")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            case 1:
                cell.iconImageView.image = UIImage(named: "Login")?.imageWithRenderingMode(UIImageRenderingMode.AlwaysTemplate)
            default:
                break
            }
        }
        cell.iconImageView.tintColor = .blackColor()
        cell.tag = indexPath.row
        
        return cell
    }
    
    
    // MARK: - TableView Delegate
    // Select the correct menu option based on wether or not the user is logged in. There are different menu options in each of these cases.
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        guard let model = model else { return }
        if model.userServiceProvider.isLocalUserLoggedIn() {
            delegate?.didSelectMenuOption(menuOptions[indexPath.row])
            for i in 0..<tableView.numberOfRowsInSection(indexPath.section) {
                guard let cell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: i, inSection: 0)) as? MenuOptionTableViewCell else { return }
                if indexPath.row != i {
                    cell.selectionIndicator.hidden  = true
                    cell.iconImageView.tintColor    = .blackColor()
                    cell.textLabel?.textColor       = .blackColor()
                } else {
                    cell.selectionIndicator.hidden  = false
                    cell.iconImageView.tintColor    = kCOLOR_ONE
                    cell.textLabel?.textColor       = kCOLOR_ONE
                }
            }
        } else {
            delegate?.didSelectMenuOption(nonUserMenuOptions[indexPath.row])
        }
    }
    
    
    // Return the actually string of text that the user will see in the menu
    func stringForMenuOption(option:MenuOptions) -> String {
        // FIXME: This needs to return a localized string
        switch option {
        case .Discover:         return "Discover"
        case .Dashboard:    return "Dashboard"
        case .History:      return "History"
        case .Settings:     return "Settings"
        case .Help:         return "Help"
        case .SignUp:       return "Sign Up"
        }
    }
}



enum MenuOptions {
    case Discover
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
