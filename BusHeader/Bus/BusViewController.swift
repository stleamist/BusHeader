import UIKit

class BusViewController: UIViewController {
    @IBOutlet weak var busHeaderView: BusHeaderView!
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.busHeaderView.sizeMode = .regular
        case 1:
            self.busHeaderView.sizeMode = .compact
        default: ()
        }
    }
    
    @IBAction func updateDidTap(_ sender: UIButton) {
        UIView.animate(withDuration: 3) {
            self.busHeaderView.sizeMode = (self.busHeaderView.sizeMode == .compact) ? .regular : .compact
            self.busHeaderView.layoutIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        busHeaderView.backgroundColor = UIColor(named: "Seoul Green")
        busHeaderView.routeNumberLabel.numberText = "6515"
        busHeaderView.switchControl.startStopNameLabel.text = "양천공영차고지"
        busHeaderView.switchControl.turningStopNameLabel.text = "경인교육대학교"
    }
}
