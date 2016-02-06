//
//  MeetingTimeResponderView.swift
//  Bygo_Client
//
//  Created by Nicholas Garfield on 4/2/16.
//  Copyright © 2016 Nicholas Garfield. All rights reserved.
//
//
//  MeetingTimeResponderView.swift
//  MeetingScheduler_iOS
//
//  Created by Nicholas Garfield on 22/12/15.
//  Copyright © 2015 Nicholas Garfield. All rights reserved.
//

import UIKit


private let kHOUR_SPACING:CGFloat = 60.0
private let k10_MINUTE_SPACING:CGFloat = 60.0/6.0

class MeetingTimeResponderView: UIView {
    
    private var timeSlotViews:[UIView] = []
    var proposalIndex:Int = 0
    
    var dataSource:MeetingTimeResponderViewDataSource?
    var delegate:MeetingTimeResponderViewDelegate?
    
    func initialize(requestSendDate:NSDate, timeSlotRenterAvailability:[Bool]) {
        
        // FIXME: Pull from global repo
        layer.cornerRadius = 0.0
        layer.masksToBounds = true
    }
    
    func reload(completionHandler:(success:Bool)->Void) {
//        guard let dataSource = self.dataSource else { return }
//        
//        let calendar = NSCalendar.currentCalendar()
        
//        dataSource.getProposedMeetingTimes(forProposalAtIndex: proposalIndex, completionHandler: {(success:Bool, proposedMeetingTimes:[ProposedMeetingTime]) in
//            if success {
//                print(proposedMeetingTimes)
//                for i in 0..<proposedMeetingTimes.count {
//                    let timeSlotView = UIView()
//                    self.addSubview(timeSlotView)
//                    if proposedMeetingTimes[i].isAvailable {
//                        timeSlotView.backgroundColor = .greenColor()
//                    } else {
//                        timeSlotView.backgroundColor = .redColor()
//                    }
//                    
//                    let heightFactor = (proposedMeetingTimes[i].duration/60.0)
//                    timeSlotView.translatesAutoresizingMaskIntoConstraints = false
//                    timeSlotView.heightAnchor.constraintEqualToConstant(kHOUR_SPACING * CGFloat(heightFactor)).active = true
//                    timeSlotView.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: CGFloat(i)*(kHOUR_SPACING * CGFloat(heightFactor))).active = true
//                    timeSlotView.widthAnchor.constraintEqualToAnchor(self.widthAnchor).active = true
//                    timeSlotView.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
//                    self.timeSlotViews.append(timeSlotView)
//                    self.sendSubviewToBack(timeSlotView)
//                    
//                    // Add time label
//                    if i%2 == 1 {
//                        let time = proposedMeetingTimes[i].time
//                        let components = calendar.components([.Hour, .Minute], fromDate: time)
//                        let hour = components.hour
//                        let minutes = components.minute
//                        let hourLabel = UILabel()
//                        self.addSubview(hourLabel)
//                        hourLabel.textAlignment = .Center
//                        hourLabel.textColor = .whiteColor()
//                        hourLabel.text =  String(format: "%d:%02d", hour, minutes)
//                        hourLabel.sizeToFit()
//                        hourLabel.translatesAutoresizingMaskIntoConstraints = false
//                        hourLabel.widthAnchor.constraintEqualToAnchor(self.widthAnchor).active = true
//                        hourLabel.centerXAnchor.constraintEqualToAnchor(self.centerXAnchor).active = true
//                        hourLabel.topAnchor.constraintEqualToAnchor(self.topAnchor, constant: (kHOUR_SPACING/2) + (CGFloat((i-1)/2)*kHOUR_SPACING) - hourLabel.bounds.height/2.0).active = true
//                    }
//                    
//                    if i == proposedMeetingTimes.count-1 {
//                        print("Setting bottom anchor")
//                        self.bottomAnchor.constraintEqualToAnchor(timeSlotView.bottomAnchor, constant: 0).active = true
//                        completionHandler(success: true)
//                    }
//                }
//            } else {
//                completionHandler(success: true)
//            }
//        })
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    func tapAtLocation(loc:CGPoint) {
        
    }
    
    func panAtLocation(loc:CGPoint) {
        
    }
}


protocol MeetingTimeResponderViewDataSource {
//    func getProposedMeetingTimes(forProposalAtIndex index:Int, completionHandler:(success:Bool, proposedMeetingTimes:[ProposedMeetingTime])->Void)
}

protocol MeetingTimeResponderViewDelegate {
    func didSetSelectedTime(forProposal proposal:Int, atIndex index:Int)
}