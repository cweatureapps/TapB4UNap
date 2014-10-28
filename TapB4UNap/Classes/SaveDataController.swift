//
//  SaveDataController.swift
//  TapB4UNap
//
//  Created by Ken Ko on 28/10/2014.
//  Copyright (c) 2014 Ken Ko. All rights reserved.
//

import Foundation
import UIKit

class SaveDataController : UIViewController {

    let timeKeeper = TimeKeeper()

    @IBOutlet weak var statusMessageLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func saveToHealthStore() {
        if (timeKeeper.canSave()) {
            HealthStore.sharedInstance.saveSleepData(timeKeeper.getSleepStartDate()!, endDate:timeKeeper.getSleepEndDate()!, withCompletion: {
              (success, error) in
                    if (success) {
                        println("sleep data saved successfully!")
                        // TODO: interestingly, changing UI here wont reflect in UI immediately. UI thread vs other thread?
                        self.statusMessageLabel.text = "Saved!"
                        
                        self.timeKeeper.reset()
                    } else {
                        println("Error: \(error)")
                    }
              })

        }
    }
    
    @IBAction func saveHandler(sender: AnyObject) {
        saveToHealthStore() 
    }
    
    
}