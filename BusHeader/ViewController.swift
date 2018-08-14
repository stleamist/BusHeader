import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var control: SwitchControl!
    
    @IBAction func segmentValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0: self.control.sizeMode = .regular
        case 1: self.control.sizeMode = .compact
        default: ()
        }
    }
    
    @IBAction func updateDidTap(_ sender: UIButton) {
        let label = Label()
        label.text = "Hello"
        control.leftLabel = label
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        control.setLabelTexts(left: "여의도", right: "장지공영차고지")
        // Do any additional setup after loading the view, typically from a nib.
    }
}

class Label: UILabel {}
