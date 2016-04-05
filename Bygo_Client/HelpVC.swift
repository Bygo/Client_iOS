//
//  HelpVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/4/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class HelpVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var delegate: HelpDelegate?
    
    @IBOutlet var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.backgroundColor = kCOLOR_THREE
        
        // UI Design
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TableView Data Source
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        
        case 1:
            return "Contact"
        case 2:
            return "Legal"
        default:
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 3
        case 2:
            return 2
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("GeneralHelp", forIndexPath: indexPath) as? BygoGeneralTableViewCell else { return UITableViewCell() }
        
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "How Does Bygo Work?"
            default:
                return cell
            }
        case 1:
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Facebook"
            case 1:
                cell.titleLabel.text = "Twitter"
            case 2:
                cell.titleLabel.text = "Email"
            default:
                return cell
            }
        case 2:
            switch indexPath.row {
            case 0:
                cell.titleLabel.text = "Terms of Service"
            case 1:
                cell.titleLabel.text = "Privacy Policy"
            default:
                return cell
            }
        default:
            return cell
        }
        return cell
    }
    
    // MARK: - TableViewDelegate 
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        switch indexPath.section {
        case 0:
            switch indexPath.row {
            case 0:
                let loginSB = UIStoryboard(name: "HowDoesBygoWork", bundle: NSBundle.mainBundle())
                let howDoesBygoWorkVC = loginSB.instantiateInitialViewController() as? UINavigationController
                presentViewController(howDoesBygoWorkVC!, animated: true, completion: nil)
                
            default:
                break
            }
        case 1:
            switch indexPath.row {
            case 0:
                UIApplication.sharedApplication().openURL(NSURL(string: "fb://profile/1735043573399014")!)

            case 1:
                UIApplication.sharedApplication().openURL(NSURL(string: "twitter://user?screen_name=BygoTeam")!)
                
            case 2:
                UIApplication.sharedApplication().openURL(NSURL(string: "mailto:support@bygo.io")!)
                
            default:
                break
            }
            
        case 2:
            switch indexPath.row {
            case 0:
                break
            case 1:
                break
            default:
                break
            }
        default:
            break
        }
    }
    
    
    // MARK: - UI Actions
    @IBAction func menuButtonTapped(sender: AnyObject) {
        delegate?.openMenu()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}


public protocol HelpDelegate {
    func openMenu()
    func didMoveOneLevelIntoNavigation()
    func didReturnToBaseLevelOfNavigation()
}