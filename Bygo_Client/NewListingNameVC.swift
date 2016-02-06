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
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - TextField Delegate
    func textFieldDidChange(sender:AnyObject) {
        tableView.reloadData()
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
        
        if indexPath.row == 0 {
            cell.textLabel?.text = "Continue with name \"\(nameTextField.text!)\""
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
