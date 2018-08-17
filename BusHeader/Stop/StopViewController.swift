//
//  StopViewController.swift
//  BusHeader
//
//  Created by 김동규 on 2018. 8. 15..
//  Copyright © 2018년 Stleam. All rights reserved.
//

import UIKit

class StopViewController: UIViewController {
    @IBOutlet weak var stopHeaderView: StopHeaderView!
    @IBOutlet weak var testSwitchControl: StopSwitchControl!
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.stopHeaderView.sizeMode = .regular
            self.testSwitchControl.sizeMode = .regular
        case 1:
            self.stopHeaderView.sizeMode = .compact
            self.testSwitchControl.sizeMode = .compact
        default: ()
        }
    }
    @IBAction func updateDidTouchUpInside(_ sender: UIButton) {
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stopHeaderView.stopInfoLabels.stopNameText = "올림픽공원"
        stopHeaderView.stopInfoLabels.nextStopNameText = "방이역 방면"
        stopHeaderView.stopInfoLabels.stopIDText = "24-396"
        stopHeaderView.stopSwitchControl.setLabelTexts(text: "방이역 방면", detailText: "24-396")
        stopHeaderView.stopSwitchControl.arrowRotationAngle = (.pi / -8)
    }
}
