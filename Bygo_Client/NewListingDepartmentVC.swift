//
//  NewListingDepartmentVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class NewListingDepartmentVC: UITableViewController  {
    
    var model:Model?
    
    var listingName:String?
    var listingDepartment:Department?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        model?.departmentServiceProvider.refreshDepartments({
            (success:Bool) in
            if success { self.tableView.reloadData() }
            else { print("Error refreshing all Departments") }
        })
    }

    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        return realm.objects(Department).count
    }
    
    
    func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
        dispatch_async(GlobalUserInteractiveQueue, {
            let realm       = try! Realm()
            let deparments  = realm.objects(Department).sorted("name", ascending: true)
            guard let name  = deparments[indexPath.row].name else { return }
            dispatch_async(GlobalMainQueue, { cell.textLabel?.text = name })
        })
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("DepartmentCell", forIndexPath: indexPath)
        configureCell(cell, atIndexPath: indexPath)
        return cell
        
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let realm           = try! Realm()
        listingDepartment   = realm.objects(Department).sorted("name", ascending: true)[indexPath.row]
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowChooseCategory", sender: nil)
    }
    
    // MARK: - UI Actions
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowChooseCategory" {
            guard let destVC = segue.destinationViewController as? NewListingCategoryVC else { return }
            destVC.model                = model
            destVC.listingName          = listingName
            destVC.listingDepartment    = listingDepartment
        }
    }
}
