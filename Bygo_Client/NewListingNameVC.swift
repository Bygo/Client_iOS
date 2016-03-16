//
//  NewListingNameVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit

class NewListingNameVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var model:Model?
    
    @IBOutlet var cancelButton:UIBarButtonItem!
    @IBOutlet var tableView:UITableView!
    @IBOutlet var instructionLabel:UILabel!
    @IBOutlet var spotlightImageView:UIImageView!
    @IBOutlet var nameTextField:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        nameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 48.0
        
        // UI Design
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        nameTextField.tintColor = kCOLOR_ONE
        view.backgroundColor = kCOLOR_THREE
        tableView.backgroundColor = .clearColor()
        
        nameTextField.becomeFirstResponder()
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TextField Delegate
    func textFieldDidChange(sender:AnyObject) {
        tableView.reloadData()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        nameTextField.resignFirstResponder()
        return true
    }
    
    
    // MARK: - TableView Data Source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if nameTextField.text?.characters.count > 0 {
            return 1
        }
        return 0
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // warning: incomplete implementation
        if nameTextField.text?.characters.count > 0 {
            // TODO: Return number of matching item names
            return 1
        }
        
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NameSuggestionCell", forIndexPath: indexPath)
        cell.textLabel?.numberOfLines = 0
        cell.backgroundColor = .whiteColor()
        cell.textLabel?.font = UIFont.systemFontOfSize(16.0)
        
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Continue with name \"\(nameTextField.text!)\""
            cell.backgroundColor = kCOLOR_FIVE
            cell.textLabel?.textColor = .whiteColor()
        }
        
        // TODO: Get matching names from server and load them into the tableview cell
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if indexPath.row == 0 {
            performSegueWithIdentifier("ShowChooseDepartment", sender: nil)
        }
    }
    
    
    @IBAction func cancelButtonTapped(sender:AnyObject!) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowChooseDepartment" {
            guard let destVC = segue.destinationViewController as? NewListingDepartmentVC else { return }
            destVC.model        = model
            destVC.listingName  = nameTextField.text!
        }
    }
}
