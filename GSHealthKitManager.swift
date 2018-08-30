//
//  GSHealthKitManager.swift
//  StandMeUp_dev2
//
//  Created by Benjamin Yunker on 9/21/17.
//  Copyright © 2017 Benjamin Yunker. All rights reserved.
//

import Foundation
import UIKit
import HealthKit

class GSHealthKitManager: NSObject {
    private let healthStore = HKHealthStore()
    private var loaded: Bool = false
    var standUnit: HKUnit = HKUnit.count()
    
    class var sharedInstance: GSHealthKitManager {
        struct Singleton {
            static let instance = GSHealthKitManager()
        }
        return Singleton.instance
    }
    
    class func isHealthKitAvailable() -> Bool {
        return HKHealthStore.isHealthDataAvailable()
    }
    
    func attemptAuthorize(completion: ((_ success: Bool) -> Void)!) {
        let writeTypes: Set<HKSampleType> = [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
                                             HKWorkoutType.workoutType()]
        let readTypes: Set<HKObjectType> = [HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!,
                                            HKWorkoutType.workoutType(),
                                            HKObjectType.activitySummaryType(),
                                            HKActivitySummaryType.activitySummaryType(),
                                            HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier.appleStandHour)!]
        
        guard HKHealthStore.isHealthDataAvailable() else {
            completion(false)
            return
        }
        
        healthStore.requestAuthorization(toShare: writeTypes, read: readTypes, completion: { (success, error) in
            if success {
                completion(true)
                self.loaded = true
            } else {
                completion(false)
                self.loaded = false
                print("Error in auth request")
            }
            })
        
    }
    
    func distanceSampleWithDistance(distance: Double) -> HKQuantitySample {
        let quantityType: HKQuantityType = HKQuantityType.quantityType(forIdentifier: HKQuantityTypeIdentifier.distanceWalkingRunning)!
        
        let distanceUnit: HKUnit = HKUnit(from: LengthFormatter.Unit.meter)
        
        let quantity: HKQuantity = HKQuantity(unit: distanceUnit, doubleValue: distance)
        
        return HKQuantitySample(type: quantityType, quantity: quantity, start: Date(), end: Date())
    }
    
    func getActivitySummary(completion: @escaping (HKActivitySummary, Error?) -> () ) {
        let calendar = Calendar.autoupdatingCurrent
        
        var dateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: Date()
        )
        
        // This line is required to make the whole thing work
        dateComponents.calendar = calendar
        
        let predicate = HKQuery.predicateForActivitySummary(with: dateComponents)
        
        let query = HKActivitySummaryQuery(predicate: predicate) { (query, summaries, error) in
            
            guard let summary = summaries?.first else { return }
            
            
            let energyUnit = HKUnit.kilocalorie()
            let standUnit    = HKUnit.count()
            let exerciseUnit = HKUnit.second()
            
            let energy   = summary.activeEnergyBurned.doubleValue(for: energyUnit)
            let stand    = summary.appleStandHours.doubleValue(for: standUnit)
            let exercise = summary.appleExerciseTime.doubleValue(for: exerciseUnit)
            /*
            let energyGoal   = summary.activeEnergyBurnedGoal.doubleValue(for: energyUnit)
            let standGoal    = summary.appleStandHoursGoal.doubleValue(for: standUnit)
            let exerciseGoal = summary.appleExerciseTimeGoal.doubleValue(for: exerciseUnit)
            */
            //let energyProgress   = energyGoal == 0 ? 0 : energy / energyGoal
            //let standProgress    = standGoal == 0 ? 0 : stand / standGoal
            //let exerciseProgress = exerciseGoal == 0 ? 0 : exercise / exerciseGoal
            
            // print(standProgress)
 
            completion(summary, error)
        }
        healthStore.execute(query)
        
        
    }
    
    func getDateComponents(newDate: Date) -> DateComponents {
        let calendar = Calendar.autoupdatingCurrent
        
        var dateComponents = calendar.dateComponents(
            [ .year, .month, .day ],
            from: newDate
        )
        
        // This line is required to make the whole thing work
        dateComponents.calendar = calendar
        
        return dateComponents
    }
    
    func getDateComponentsWithHour(newDate: Date) -> DateComponents {
        let calendar = Calendar.autoupdatingCurrent
        
        var dateComponents = calendar.dateComponents(
            [ .year, .month, .day, .hour ],
            from: newDate
        )
        
        // This line is required to make the whole thing work
        dateComponents.calendar = calendar
        
        return dateComponents
    }
    
    func getStandHoursToday(cells: [UIButton]!) {
        let appleStandHourType: HKCategoryType = HKCategoryType.categoryType(forIdentifier: HKCategoryTypeIdentifier.appleStandHour)!
        let cal = Calendar.current
        let begin = cal.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        let end = Date()
        /*
        guard var curr = begin else {
            print("Error obtaining date")
            return
        }
         */
        
        /* iterate through all hours today
        repeat {
            print("\(curr)")
            curr = cal.date(byAdding: .hour, value: 1, to: curr)!
        } while curr <= end
        */
        
        //let begin = cal.date(byAdding: Calendar.Component.hour, value: -6, to: Date())
        //Date(
        //let beginComponents = self.getDateComponentsWithHour(newDate: begin!)
        //let end = Date()
        //let endComponents = self.getDateComponentsWithHour(newDate: end!)
        
        let standPred = HKQuery.predicateForSamples(withStart: begin, end: end, options: HKQueryOptions.strictStartDate)
        
        let query = HKSampleQuery(sampleType: appleStandHourType, predicate: standPred, limit: 0, sortDescriptors: nil) {
            (sampleQuery, results, error) -> Void in
            if let result = results {
                for item in result {
                    print("Stood at: \(item.startDate)")
                    
                    DispatchQueue.main.async {
                        let hr = NSCalendar.current.component(Calendar.Component.hour, from: item.startDate)
                        //cells[hr].backgroundColor = UIColor.green
                        //cells[hr].setTitle("", for: UIControlState.normal)
                        //cells[hr].setTitleColor(UIColor.black, for: UIControlState.normal)
                        // cells[hr].setImage(#imageLiteral(resourceName: "Check Single"), for: UIControlState.normal)
                        //cells[hr].setBackgroundImage(#imageLiteral(resourceName: "Check Single"), for: UIControlState.normal)
                        cells[hr].alpha = 1.0
                        cells[hr].isUserInteractionEnabled = false
                        //cells[hr].isEnabled = false
                    }
                    
                }
            }
        }
        healthStore.execute(query)
        
        let standSample: HKCategorySample = HKCategorySample.init(type: appleStandHourType, value: HKCategoryValueAppleStandHour.stood.rawValue, start: begin!, end: Date())
        print("Stood Last six hours: '\(standSample.value)'")
 
        
    }
    
    func getStandHoursByDay(dateToQuery: Date, completion: @escaping (Double, Error?) -> () ) {
        let dateComponents = self.getDateComponents(newDate: dateToQuery)
        let predicate = HKQuery.predicateForActivitySummary(with: dateComponents)
        
        let query = HKActivitySummaryQuery(predicate: predicate) { (query, summaries, error) in
            
            guard let summary = summaries?.first else {
                print("No summary")
                return
            }
            
            // Process and return
            let dayHours = summary.appleStandHours.doubleValue(for: self.standUnit)
            completion(dayHours, error)
            
        }
    
        healthStore.execute(query)
    }

}
