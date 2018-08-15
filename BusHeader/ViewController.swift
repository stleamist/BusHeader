import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var busHeaderView: BusHeaderView!
    @IBOutlet weak var control: SwitchControl!
    @IBOutlet weak var testAnimatingStackView: UIStackView!
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            self.busHeaderView.sizeMode = .regular
            self.control.sizeMode = .regular
        case 1:
            self.busHeaderView.sizeMode = .compact
            self.control.sizeMode = .compact
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
        busHeaderView.switchControl.leftLabel.text = "양천공영차고지"
        busHeaderView.switchControl.rightLabel.text = "경인교육대학교"
        
        control.setLabelTexts(left: "여의도", right: "장지공영차고지")
    }
}

class Label: UILabel {}
