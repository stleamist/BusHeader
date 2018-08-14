import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var control: SwitchControl!
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            control.sizeMode = .regular
        case 1:
            control.sizeMode = .compact
            control.selectionMode = .left
        case 2:
            control.sizeMode = .compact
            control.selectionMode = .right
        default:
            ()
        }
        UIView.animate(withDuration: 0.2) {
            self.control.layoutIfNeeded()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    

}

