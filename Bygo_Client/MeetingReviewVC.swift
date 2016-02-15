//
//  MeetingReviewVC.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//

import UIKit
import MapKit
import RealmSwift

class MeetingReviewVC: UIViewController, UIScrollViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var cancelButton: UIBarButtonItem!
    @IBOutlet var meetingLocationLabel: UILabel!
    @IBOutlet var meetingLocationDetailsLabel: UILabel!
    @IBOutlet var meetingTimeDetailsLabel: UILabel!
    @IBOutlet var meetingTimeLabel: UILabel!
    @IBOutlet var endHandoffInstructionLabel: UILabel!
    @IBOutlet var endHandoffScrollView: UIScrollView!
    
    var model:Model?
    var meetingID:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        endHandoffScrollView.contentSize        = CGSizeMake(2.0*endHandoffScrollView.bounds.width, endHandoffScrollView.bounds.height)
        endHandoffScrollView.contentOffset.x    = endHandoffScrollView.bounds.width
        endHandoffScrollView.layer.cornerRadius = endHandoffScrollView.bounds.height/2.0
        
        guard let meetingID                 = meetingID else { return }
        let realm                           = try! Realm()
        guard let meeting                   = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"").first else { return }
        guard let locationID                = meeting.locationID else { return }
        guard let time                      = meeting.time else { return }
        guard let location                  = realm.objects(FavoriteMeetingLocation).filter("locationID == \"\(locationID)\"").first else { return }
        guard let locationName              = location.name else { return }
        meetingLocationDetailsLabel.text    = locationName
        
        let calendar                    = NSCalendar.currentCalendar()
        let components                  = calendar.components([.Hour, .Minute], fromDate: time)
        let hour                        = components.hour
        let minutes                     = components.minute
        meetingTimeDetailsLabel.text    = String(format: "%d:%02d", hour, minutes)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - ScrollView Delegate
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let alpha = (scrollView.contentOffset.x / scrollView.bounds.width)
        scrollView.alpha = alpha
    }
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        let page = Int(scrollView.contentOffset.x/scrollView.bounds.width)
        if page == 0 {
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    // MARK: - UI Actions
    @IBAction func cancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
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
