//
//  EditListingNameVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class EditListingNameVC: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate {
    
    var model:Model?
    var listing:Listing?
    var delegate:EditListingNameDelegate?
    
    @IBOutlet var tableView:UITableView!
    @IBOutlet var instructionLabel:UILabel!
    @IBOutlet var spotlightImageView:UIImageView!
    @IBOutlet var nameTextField:UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        nameTextField.addTarget(self, action: "textFieldDidChange:", forControlEvents: .EditingChanged)
        
        guard let name = listing?.name else { return }
        nameTextField.placeholder = name
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
            cell.textLabel?.text = "Update name to \"\(nameTextField.text!)\""
        }
        
        // TODO: Get matching names from server and load them into the tableview cell
        
        return cell
    }
    
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row == 0 {
            if nameTextField.text!.characters.count > 0 {
                
                guard let listingID         = listing?.listingID        else { return }
                guard let name              = nameTextField.text        else { return }
                guard let categoryID        = listing?.categoryID       else { return }
                guard let totalValue        = listing?.totalValue.value else { return }
                guard let hourlyRate        = listing?.hourlyRate.value else { return }
                guard let dailyRate         = listing?.dailyRate.value  else { return }
                guard let weeklyRate        = listing?.weeklyRate.value else { return }
                guard let itemDescription   = listing?.itemDescription  else { return }
                
                model?.listingServiceProvider.updateListing(listingID, name: name, categoryID: categoryID, totalValue: totalValue, hourlyRate: hourlyRate, dailyRate: dailyRate, weeklyRate: weeklyRate, itemDescription: itemDescription, completionHandler: {
                    (success:Bool) in
                    if success {
                        self.delegate?.didUpdateItemName()
                        self.navigationController?.popViewControllerAnimated(true)
                    } else {
                        print("Error updating the Listing")
                    }
                })
            }
        }
    }
}


protocol EditListingNameDelegate {
    func didUpdateItemName()
}
