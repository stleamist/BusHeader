//
//  StopViewController.swift
//  BusHeader
//
//  Created by 김동규 on 2018. 8. 15..
//  Copyright © 2018년 Stleam. All rights reserved.
//

import UIKit

class StopViewController: UIViewController {
    @IBOutlet weak var stopSwitchControl: StopSwitchControl!
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        let handler = {
            switch sender.selectedSegmentIndex {
            case 0:
                self.stopSwitchControl.sizeMode = .regular
            case 1:
                self.stopSwitchControl.sizeMode = .compact
            default: ()
            }
            self.stopSwitchControl.layoutIfNeeded()
            self.stopSwitchControl.superview?.layoutIfNeeded()
        }
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: handler)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        stopSwitchControl.setLabelTexts(title: "방이역 방면", detail: "24-396")
    }
}
