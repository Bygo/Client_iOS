//
//  HistoryVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 2/4/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import RealmSwift

class HistoryVC: UIViewController, UITableViewDelegate, UITableViewDataSource {

    var model: Model?
    @IBOutlet var noHistoryLabel: UILabel!
    @IBOutlet var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        configureNoHistoryLabel()
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return }
        model?.historyServiceProvider.fetchUsersHistoricalRentEvents(userID, completionHandler: {
            (success:Bool) in
            dispatch_async(GlobalMainQueue, {
                self.tableView.reloadData()
            })
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configureNoHistoryLabel() {
        noHistoryLabel.text = "You have no history on Bygo"
        noHistoryLabel.font = UIFont.systemFontOfSize(16.0, weight: UIFontWeightMedium)
        noHistoryLabel.backgroundColor = kCOLOR_THREE
    }
    
    private func getQueryFilter() -> String {
        let nullFilter = "ownerID == nil"
        guard let userID = model?.userServiceProvider.getLocalUser()?.userID else { return nullFilter }
        return "((renterID == \"\(userID)\") OR (ownerID == \"\(userID)\")) AND ((status == \"Concluded\"))"
    }

    // MARK: - Table view data source
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let realm = try! Realm()
        let count = realm.objects(Listing).filter(self.getQueryFilter()).count
        
        // FIXME: Animate in/out the noHistoryLabel
        if count == 0 {
            noHistoryLabel.hidden = false
            view.bringSubviewToFront(noHistoryLabel)
        } else {
            noHistoryLabel.hidden = true
            view.sendSubviewToBack(noHistoryLabel)
        }
        
        return count
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCellWithIdentifier("HistoryCell", forIndexPath: indexPath) as? HistoryTableViewCell else { return UITableViewCell() }
        
        // Configure the cell...

        return cell
    }

    // MARK: - UI Actions
    @IBAction func backButtonTapped(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    

}
