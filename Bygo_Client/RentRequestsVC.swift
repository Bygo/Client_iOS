//
//  RentRequestsVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit


class RentRequestsVC: UICollectionViewController {
    
    var model:Model?
    
    @IBOutlet var noRentRequestsLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNoRentRequestsLabel()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    private func configureNoRentRequestsLabel() {
        noRentRequestsLabel = UILabel(frame: CGRectMake(12.0, 0, view.bounds.width-24.0, view.bounds.height))
        noRentRequestsLabel.font = UIFont.systemFontOfSize(18.0)
        noRentRequestsLabel.textColor = .darkGrayColor()
        noRentRequestsLabel.textAlignment = .Center
        noRentRequestsLabel.numberOfLines = 0
        noRentRequestsLabel.text = "None of your Listings\nhave any Rent Requests"
        noRentRequestsLabel.hidden = true
        view.addSubview(noRentRequestsLabel)
        view.sendSubviewToBack(noRentRequestsLabel)
    }
    
    // MARK: UICollectionViewDataSource
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = 0
        
        if count == 0 {
            noRentRequestsLabel.hidden = false
            view.bringSubviewToFront(noRentRequestsLabel)
        } else {
            noRentRequestsLabel.hidden = true
            view.sendSubviewToBack(noRentRequestsLabel)
        }
        
        return count
    }
    
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        if indexPath.row == 0 {
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("HeaderCell", forIndexPath: indexPath) as? RentRequestsHeaderCollectionViewCell else { return UICollectionViewCell() }
            
//            guard let rentEvent = fetchedResultsController.objectAtIndexPath(indexPath) as? RentEvent else { return cell }
//            
//            model?.queryForItems([rentEvent.itemID], completionHandler: {(success:Bool, items:[Item]) in
//                if success {
//                    if let item = items.first {
//                        cell.itemNameLabel.text = item.name
//                    }
//                } else {
//                    print("Error querying for item")
//                }
//            })
//            
//            let numRequests = collectionView.numberOfItemsInSection(indexPath.section) - 1
//            
//            if numRequests == 1 {
//                cell.numRequestsLabel.text = "1 Request"
//            } else {
//                cell.numRequestsLabel.text = "\(numRequests) Requests"
//            }
            
            return cell
        } else {
            guard let cell = collectionView.dequeueReusableCellWithReuseIdentifier("RequestCell", forIndexPath: indexPath) as? RentRequestsCollectionViewCell else { return UICollectionViewCell() }
            
//            guard let rentEvent = fetchedResultsController.objectAtIndexPath(NSIndexPath(forItem: indexPath.item - 1, inSection: indexPath.section)) as? RentEvent else { return cell }
//            
//            model?.queryForUser(rentEvent.renterID, completionHandler: {(success:Bool, user:User?) in
//                if success {
//                    cell.userNameLabel.text = "\(user!.firstName) \(user!.lastName)"
//                    cell.rentalRateLabel.text = String(format: "$%.2f", rentEvent.rentalRate)
//                    
//                    // Set cell image
//                    cell.userProfileImageView.layer.cornerRadius = cell.userProfileImageView.bounds.width/2.0
//                    cell.userProfileImageView.contentMode = UIViewContentMode.ScaleAspectFill
//                    cell.userProfileImageView.clipsToBounds = true
//                    cell.userProfileImageView.layer.masksToBounds = true
//                    cell.userProfileImageView.layer.borderWidth = 0.0
//                    
//                    
//                } else {
//                    print("Error fetching user \(rentEvent.renterID)")
//                }
//            })
            
            return cell
        }
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row != 0 {
//            guard let rentEvent = fetchedResultsController.objectAtIndexPath(NSIndexPath(forItem: indexPath.item-1, inSection: indexPath.section)) as? RentEvent else { return }
//            showMeetingResponder(rentEvent.itemID, proposalIndex: indexPath.item-1)
        }
    }
    
    func showMeetingResponder(focusItemID:String, proposalIndex:Int) {
//        guard let meetingSchedulerBundler = NSBundle(identifier: "com.NicholasGarfield.MeetingScheduler-iOS") else {
//            print("MeetingScheduler bundle not found")
//            return
//        }
//        let meetingSchedulerSB = UIStoryboard(name: "MeetingScheduler", bundle: meetingSchedulerBundler)
//        guard let navVC = meetingSchedulerSB.instantiateViewControllerWithIdentifier("MeetingResponse") as? UINavigationController else {
//            print("Could not get the navVC")
//            return
//        }
//        guard let meetingResponderVC = navVC.topViewController as? MeetingResponderVC else {
//            print("Could not get the meeting proposalVC")
//            return
//        }
//        
//        meetingResponderVC.model = self.model
//        meetingResponderVC.initialProposalIndex = proposalIndex
//        meetingResponderVC.focusItemID = focusItemID
//        
//        presentViewController(navVC, animated: true, completion: {
//            meetingResponderVC.reload()
//        })
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
    }
}


// MARK: - UICollectionViewDelegate
extension RentRequestsVC : UICollectionViewDelegateFlowLayout {
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        if indexPath.row == 0 {
            return CGSizeMake(view.bounds.width, 64.0)
        } else {
            return CGSizeMake(view.bounds.width, view.bounds.height/4.0)
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(0, 0, 0, 0)
    }
}

protocol RentRequestsDelegate {
    
}