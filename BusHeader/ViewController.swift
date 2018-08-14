import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var control: SwitchControl!
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.control.sizeMode = .regular
                self.control.layoutIfNeeded()
            })
            
        case 1:
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.control.sizeMode = .compact
                self.control.layoutIfNeeded()
            })
        default:
            ()
        }
    }
    @IBAction func updateDidTap(_ sender: UIButton) {
        UIView.animate(withDuration: 1, delay: 0, options: .curveEaseInOut, animations: {
            self.control.leftLabel.isHighlighted = true
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    

}

