//
//  MeetingsVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit


class MeetingsVC: UICollectionViewController {

    @IBOutlet var noMeetingsLabel:UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureNoRentRequestsLabel()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    private func configureNoRentRequestsLabel() {
        noMeetingsLabel = UILabel(frame: CGRectMake(12.0, 0, view.bounds.width-24.0, view.bounds.height))
        noMeetingsLabel.font = UIFont.systemFontOfSize(18.0)
        noMeetingsLabel.textColor = .darkGrayColor()
        noMeetingsLabel.textAlignment = .Center
        noMeetingsLabel.numberOfLines = 0
        noMeetingsLabel.text = "None of your Listings\nhave any Rent Requests"
        noMeetingsLabel.hidden = true
        view.addSubview(noMeetingsLabel)
        view.sendSubviewToBack(noMeetingsLabel)
    }

    // MARK: UICollectionViewDataSource
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }


    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // FIXME: Load the proper Meeting count
        let count = 0
        
        if count == 0 {
            noMeetingsLabel.hidden = false
            view.bringSubviewToFront(noMeetingsLabel)
        } else {
            noMeetingsLabel.hidden = true
            view.sendSubviewToBack(noMeetingsLabel)
        }
        return 0
    }

    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MeetingCell", forIndexPath: indexPath)
        
        // TODO: Configure the meeting cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        // TODO: Review the meeting
    }

}
