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

    var rings: [HKActivityRingView] = []
    
    @IBOutlet weak var viewRings: UIStackView!
    @IBOutlet weak var viewStackItems: UIStackView!
    @IBOutlet weak var standHrLabel: UILabel!
    
    @IBOutlet weak var ringsView: RingsControl!
    
    @IBOutlet weak var btnMon: UIButton!
    
    @IBOutlet var hrButtons: [UIButton]!
    
    @IBOutlet var ringButtons: [UIButton]!
    
    enum Day_t: Int {
        case Mon, Tues, Wed, Thurs, Fri, Sat, Sun
    }
    
    @IBAction func getStandHours(_ sender: Any) {
        //for button in self.hourButtons.visibleCells {
            // Modify attributes here
        //}
         GSHealthKitManager.sharedInstance.getStandHoursToday(cells: hrButtons)
        
        GSHealthKitManager.sharedInstance.getStandHoursByDay(dateToQuery: Date())
        { (hours: Double, error: Error?) -> Void in
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
    @IBAction func updateHourSheet(_ sender: UIButton) {
        switch sender {
        case ringButtons[Day_t.Mon.rawValue]:
            print("Display Mon")
        case ringButtons[Day_t.Tues.rawValue]:
            print("Display Tues")
        case ringButtons[Day_t.Wed.rawValue]:
            print("Display Wed")
        case ringButtons[Day_t.Thurs.rawValue]:
            print("Display Thurs")
        case ringButtons[Day_t.Fri.rawValue]:
            print("Display Fri")
        case ringButtons[Day_t.Sat.rawValue]:
            print("Display Sat")
        case ringButtons[Day_t.Sun.rawValue]:
            print("Display Sun")
        default:
            print("none")
            
        }
    }
    
    @IBAction func addStandHour(_ sender: HourButton) {
        /*
        switch sender.hrComponents {
        default:
            print("Invalid time value")
        }
        */
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        ringsView.backgroundColor = UIColor.black
        ringsView.backgroundColor?.setFill()
        GSHealthKitManager.sharedInstance.attemptAuthorize(completion: testMethod)
        
        let calendar = Calendar.autoupdatingCurrent
        
        
        /* Ring Buttons setup */
        for button in self.ringButtons {
            let ringView = HKActivityRingView(frame: CGRect(x: 0, y: 0, width: 40, height: 40))
            ringView.isUserInteractionEnabled = false
            
            rings.append(ringView)
           
            button.addSubview(ringView)
            button.isUserInteractionEnabled = true
        }
        
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
            for ring in self.rings {
                ring.setActivitySummary(summary, animated: true)
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
                GSHealthKitManager.sharedInstance.getStandHoursToday(cells: self.hrButtons)
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

