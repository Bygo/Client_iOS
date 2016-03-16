//
//  NewListingCategoryVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class NewListingCategoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var model:Model?
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var nextButton: UIBarButtonItem!
    
    var listingName:String?
    var listingDepartment:Department?
    var listingCategory:Category?
    
    private var targetIndex:NSIndexPath?
    
    @IBOutlet var headerView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        model?.categoryServiceProvider.refreshCategories({
            (success:Bool) in
            if success { self.tableView.reloadData() }
            else { print("Error refreshing all Categories") }
        })
        
        
        title = "Category"
        nextButton.enabled = false
//        tableView.backgroundColor = .whiteColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    private func getQueryFilter() -> String {
        let nullQuery = "departmentID == nil"
        guard let departmentID = listingDepartment?.departmentID else { return nullQuery }
        return "departmentID == \"\(departmentID)\""
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        return realm.objects(Category).filter(getQueryFilter()).count
    }
    
    
    func configureCell(cell: ListingCategoryTableViewCell, atIndexPath indexPath: NSIndexPath) {
        let queryFilter = self.getQueryFilter()
        cell.textLabel?.alpha = 0.0
        dispatch_async(GlobalUserInteractiveQueue, {
            let realm       = try! Realm()
            let categories  = realm.objects(Category).filter(queryFilter).sorted("name", ascending: true)
            guard let name  = categories[indexPath.row].name else { return }
            dispatch_async(GlobalMainQueue, {
                cell.textLabel?.text = name
                UIView.animateWithDuration(0.5, delay: 0.05*Double(indexPath.row), options: UIViewAnimationOptions.CurveEaseIn, animations: {
                        cell.textLabel?.alpha = 1.0
                    }, completion: nil)
            })
        })
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("CategoryCell", forIndexPath: indexPath) as? ListingCategoryTableViewCell else { return UITableViewCell() }
        
        configureCell(cell, atIndexPath: indexPath)
        
        return cell
        
    }
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return targetIndex != indexPath
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        targetIndex = indexPath
        nextButton.enabled = true
    }
    
    // MARK: - UI Actions
    @IBAction func nextButtonTapped(sender: AnyObject) {
        if let targetIndex = targetIndex {
            let realm       = try! Realm()
            listingCategory = realm.objects(Category).filter(self.getQueryFilter()).sorted("name", ascending: true)[targetIndex.row]
            performSegueWithIdentifier("ShowTakePhotos", sender: nil)
        }
    }
    
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowTakePhotos" {
            guard let destVC = segue.destinationViewController as? NewListingPhotosVC else { return }
            destVC.model                = model
            destVC.listingName          = listingName
            destVC.listingDepartment    = listingDepartment
            destVC.listingCategory      = listingCategory
        }
    }
}
