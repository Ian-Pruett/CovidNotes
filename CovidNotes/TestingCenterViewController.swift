//
//  TestingCenterViewController.swift
//  CovidNotes
//
//  Created by Ian Pruett on 5/6/20.
//  Copyright © 2020 Ian Pruett. All rights reserved.
//

import UIKit

class TestingCenterViewController: UIViewController {

    @IBOutlet weak var testingCenterName: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    var name: String?
    var phoneNumber: String?
    var address: String?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        testingCenterName.text = name!
        phoneNumberLabel.text = phoneNumber ?? "N/A"
        addressLabel.text = address ?? "N/A"
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
