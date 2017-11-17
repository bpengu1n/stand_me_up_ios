//
//  FirstViewController.swift
//  StandMeUp_dev2
//
//  Created by Benjamin Yunker on 9/21/17.
//  Copyright © 2017 Benjamin Yunker. All rights reserved.
//

import UIKit
import HealthKitUI

class FirstViewController: UIViewController {

    @IBOutlet weak var viewRings: UIStackView!
    @IBOutlet weak var viewStackItems: UIStackView!
    @IBOutlet weak var standHrLabel: UILabel!
    
    @IBOutlet weak var hourButtons: UICollectionView!
    @IBOutlet weak var ringsView: RingsControl!
    
    
    @IBOutlet var hrButtons: [UIButton]!
    
    @IBOutlet weak var ringButtonMon: UIButton!
    
    @IBAction func getStandHours(_ sender: Any) {
        //for button in self.hourButtons.visibleCells {
            // Modify attributes here
        //}
        GSHealthKitManager.sharedInstance.getStandHoursToday(cells: hrButtons)
        
        GSHealthKitManager.sharedInstance.getStandHoursByDay(dateToQuery: Date()) { (hours: Double, error: Error?) -> Void in
            if error != nil {
                print ("ERROR: \(error.debugDescription)")
                return
            }
            print("Hours stood on \(Date()): \(hours)")
            DispatchQueue.main.async {
                self.standHrLabel.text = String(format: "%d", Int.init(hours))
            }
        }
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //let ringView = HKActivityRingView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
        //let ringView2 = HKActivityRingView()
        //viewRings.addSubview(ringView)
        //viewRings.addSubview(ringView2)
        //ringButtonMon.addSubview(ringView)
        ringsView.backgroundColor = UIColor.black
        ringsView.backgroundColor?.setFill()
        GSHealthKitManager.sharedInstance.attemptAuthorize(completion: testMethod)
        
        let calendar = Calendar.autoupdatingCurrent
        
        var dateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: Date()
        )
        
        // This line is required to make the whole thing work
        dateComponents.calendar = calendar
        
        GSHealthKitManager.sharedInstance.getStandHoursByDay(dateToQuery: Date()) { (hours: Double, error: Error?) -> Void in
            if error != nil {
                print ("ERROR: \(error.debugDescription)")
                return
            }
            print("Hours stood on \(Date()): \(hours)")
        }
        
        GSHealthKitManager.sharedInstance.getActivitySummary { (summary, error) in
            for ring in self.ringsView.rings {
                ring.setActivitySummary(summary, animated: true)
            }
            
            DispatchQueue.main.async {

            }
            print("summary added")
         }
        
        
    }
    
    func testMethod(didComplete: Bool) {
        if (didComplete == true) {
            print("AuthRequest Success")
            

            
            GSHealthKitManager.sharedInstance.getStandHoursByDay(dateToQuery: Date()) { (hours: Double, error: Error?) -> Void in
                if error != nil {
                    print ("ERROR: \(error.debugDescription)")
                    return
                }
                print("Hours stood on \(Date()): \(hours)")
                //GSHealthKitManager.sharedInstance.getStandHoursToday(cells: self.ringFrameCells)
            }
        } else {
            print("AuthRequest Failure")
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

