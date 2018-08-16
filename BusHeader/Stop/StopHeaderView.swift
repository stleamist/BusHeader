import UIKit

// View Classes for Debug

class PrimaryView: UIView {}

@IBDesignable class StopHeaderView: UIView, Compactible {
    
    // MARK: - View Properties
    
    let primaryView = PrimaryView()
    // let secondaryView = UIView()
    let nodeView = NodeView()
    let stopNameLabel = UILabel()
    let stopSwitchControl = StopSwitchControl()
    
    let space1 = UILayoutGuide()
    
    
    // MARK: Constraints
    
    var constraintsForMode: [CompactibleSizeMode: Set<NSLayoutConstraint>] = [:]
    
    
    // MARK: Mode Properties
    
    var sizeMode: CompactibleSizeMode = .regular {
        didSet {
            if sizeMode == .compact {
                // stopSwitchControl.lockLabelsContainerViewWidth(lock: true)
            }
            
            updateConstraintsForMode(animated: true)
            stopSwitchControl.sizeMode = sizeMode
            
            if sizeMode == .regular {
                // stopSwitchControl.lockLabelsContainerViewWidth(lock: false)
            }
        }
    }
    
    
    // MARK: Appearance Properties
    
    var topCornerRadius: CGFloat = 12 {
        didSet {
            setCornerRadius()
        }
    }
    
    
    // MARK: Bool Properties
    
    var isAnimationEnabled: Bool = true
    
    
    // MARK: Constants
    
    let kAnimationOption: UIView.AnimationOptions = .curveEaseInOut
    let kChangeModeDuration: TimeInterval = 0.3
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        setupSubviews()
        setupConstraints()
        setupAppearance()
    }
    
    func setupSubviews() {
        self.addSubview(primaryView)
        self.addSubview(stopSwitchControl)
        self.addLayoutGuide(space1)
        primaryView.addSubview(nodeView)
        primaryView.addSubview(stopNameLabel)
    }
    
    func setupConstraints() {
        self.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        
        [primaryView, stopSwitchControl, nodeView, stopNameLabel].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        primaryView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        primaryView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
        primaryView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        stopSwitchControl.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        stopSwitchControl.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        stopSwitchControl.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        nodeView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        nodeView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        nodeView.centerYAnchor.constraint(equalTo: primaryView.centerYAnchor).isActive = true
        nodeView.widthAnchor.constraint(equalTo: nodeView.heightAnchor).isActive = true
        
        space1.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        space1.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        space1.leadingAnchor.constraint(equalTo: nodeView.trailingAnchor).isActive = true
        space1.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        
        // TODO: 임시 코드, RouteNumberLabel 내 intrinsicContentSize와 contentHuggingPriority 구현 필요
        // routeNumberLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        // routeNumberLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        // nodeView.widthAnchor.constraint(equalToConstant: 83).isActive = true
        // nodeView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        stopNameLabel.leadingAnchor.constraint(equalTo: space1.leadingAnchor).isActive = true
        stopNameLabel.activateConstraintsToCenterInSuperview(attributes: [.centerY])
        
        constraintsForMode[.regular] = [
            primaryView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            stopSwitchControl.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            stopSwitchControl.topAnchor.constraint(equalTo: primaryView.bottomAnchor, constant: 12),
            stopSwitchControl.labelsContainerView.leadingAnchor.constraint(equalTo: space1.leadingAnchor)
        ]
        
        constraintsForMode[.compact] = [
            primaryView.centerYAnchor.constraint(equalTo: self.layoutMarginsGuide.centerYAnchor),
            primaryView.trailingAnchor.constraint(equalTo: stopSwitchControl.trailingAnchor, constant: 12),
            stopSwitchControl.widthAnchor.constraint(equalTo: stopSwitchControl.heightAnchor)
            //, stopSwitchControl.centerYAnchor.constraint(equalTo: self.layoutMarginsGuide.centerYAnchor)
        ]
        
        updateConstraintsForMode(animated: false)
    }
    
    func setupAppearance() {
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        primaryView.clipsToBounds = false
        stopNameLabel.textColor = .white
        self.backgroundColor = UIColor(white: 0.25, alpha: 1) // Default Color
        self.nodeView.nodeColors = [UIColor(rgb: 0x175CE6), UIColor(rgb: 0x29CC5F), UIColor(rgb: 0x29CCCC)]
        
        setCornerRadius()
    }
    
    
    // MARK: Property Setting Methods
    
    func setCornerRadius() {
        self.layer.cornerRadius = self.topCornerRadius
    }
    
    
    // MARK: Update Methods
    
    func updateConstraintsForMode(animated: Bool) {
        let handler = {
            self.constraintsForMode.forEach({ $1.forEach({ $0.isActive = false }) })
            self.constraintsForMode[self.sizeMode]?.forEach({ $0.isActive = true })
            
            self.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: kChangeModeDuration, delay: 0, options: kAnimationOption, animations: handler)
        } else {
            handler()
        }
    }
}
