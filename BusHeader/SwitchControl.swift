import UIKit

class SwitchControl: UIControl, Compactible {
    var sizeMode: CompactibleSizeMode = .regular {
        didSet {}
    }
    
    var isAnimationEnabled: Bool = true
    
    
    var contentView = UIView()
    
    var arrowView = UIView()
    var normalArrowImageView = UIImageView()
    var highlightedArrowImageView = UIImageView()
    
    var impactFeedbackGenerator: UIImpactFeedbackGenerator?
    
    var highlightedArrowImageName: String? { return nil }
    var normalArrowImageName: String? { return nil }
    
    
    let kAnimationOption: UIView.AnimationOptions = .curveEaseInOut
    let kChangeModeDuration: TimeInterval = 0.3
    let kBackgroundHighlightDuration: TimeInterval = 0.1
    
    override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor(animated: isAnimationEnabled)
        }
    }
    
    var backgroundColors: [UIControl.State: UIColor] { return [:] }
    
    func updateBackgroundColor(animated: Bool) {
        let handler = {
            self.backgroundColor = self.backgroundColors[self.state]
        }
        
        performAnimationsHandler(animated: animated, withDuration: kBackgroundHighlightDuration, animations: handler)
    }
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    func setup() {
        setupEventHandlers()
        setupArrowView()
    }
    
    func setupEventHandlers() {
        self.addTarget(self, action: #selector(handleTouchDown(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(handleTouchUpInside(_:)), for: .touchUpInside)
    }
    
    func setupArrowView() {
        guard let highlightedArrowImageName = self.highlightedArrowImageName,
            let normalArrowImageName = self.normalArrowImageName else {
                return
        }
        
        self.highlightedArrowImageView.image = UIImage(named: highlightedArrowImageName)
        self.normalArrowImageView.image = UIImage(named: normalArrowImageName)
        
        self.highlightedArrowImageView.sizeToFit()
        self.normalArrowImageView.sizeToFit()
    }
    
    @objc func handleTouchDown(_ sender: BusSwitchControl) {
        self.impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackGenerator?.prepare()
    }
    
    @objc func handleTouchUpInside(_ sender: BusSwitchControl) {
        self.impactFeedbackGenerator?.impactOccurred()
        self.impactFeedbackGenerator = nil
    }
    
    internal func performAnimationsHandler(animated: Bool, withDuration duration: TimeInterval, animations: @escaping () -> Void, completion: ((Bool) -> Void)? = nil) {
        if animated {
            UIView.animate(withDuration: duration, delay: 0, options: kAnimationOption, animations: animations, completion: completion)
        } else {
            animations()
        }
    }
}
