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
    
    var model:Model?
    var meetingID:String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UI Design
        navigationController?.navigationBar.barTintColor    = kCOLOR_ONE
        navigationController?.navigationBar.translucent     = false
        navigationController?.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Do any additional setup after loading the view.
        guard let meetingID                 = meetingID else { return }
        let realm                           = try! Realm()
        guard let meeting                   = realm.objects(MeetingEvent).filter("meetingID == \"\(meetingID)\"").first                 else { return }
        guard let locationID                = meeting.locationID                                                                        else { return }
        guard let time                      = meeting.time                                                                              else { return }
        let location                        = realm.objects(FavoriteMeetingLocation).filter("locationID == \"\(locationID)\"").first
        if let locationName                 = location?.name {
            meetingLocationDetailsLabel.text    = locationName
        }
        
        let calendar                    = NSCalendar.currentCalendar()
        let components                  = calendar.components([.Hour, .Minute], fromDate: time)
        let hour                        = components.hour
        let minutes                     = components.minute
        meetingTimeDetailsLabel.text    = String(format: "%d:%02d", hour, minutes)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.LightContent
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
