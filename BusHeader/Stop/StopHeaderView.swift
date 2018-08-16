import UIKit

@IBDesignable class StopHeaderView: UIView, Compactible {
    
    // MARK: - View Properties
    
    let primaryView = UIView()
    // let secondaryView = UIView()
    
    let totalLabelsContainerView = UIView()
    let detailLabelsContainerView = UIView()
    
    let stopNameLabel = UILabel()
    let stopIDLabel = UILabel()
    let dotLabel = UILabel()
    let nextStopNameLabel = UILabel()
    
    let nodeView = NodeView()
    let stopSwitchControl = StopSwitchControl()
    
    let leadingLabelsAlignmentGuide = UILayoutGuide()
    
    
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
    
    
    // MARK: Data Properties
    
    var stopName: String = ""
    var stopID: String = ""
    var nextStopName: String = ""
    var nodeColors: [UIColor] {
        get { return nodeView.nodeColors }
        set { nodeView.nodeColors = newValue }
    }
    var arrowAngle: CGFloat {
        get { return stopSwitchControl.arrowRotationAngle }
        set { stopSwitchControl.arrowRotationAngle = newValue }
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
        setupLayoutGuides()
        setupConstraints()
        setupAppearance()
    }
    
    func setupSubviews() {
        self.addSubview(primaryView)
        self.addSubview(stopSwitchControl)
        primaryView.addSubview(nodeView)
        primaryView.addSubview(totalLabelsContainerView)
        totalLabelsContainerView.addSubview(stopNameLabel)
        totalLabelsContainerView.addSubview(detailLabelsContainerView)
        detailLabelsContainerView.addSubview(nextStopNameLabel)
        detailLabelsContainerView.addSubview(dotLabel)
        detailLabelsContainerView.addSubview(stopIDLabel)
    }
    
    func setupLayoutGuides() {
        self.addLayoutGuide(leadingLabelsAlignmentGuide)
        
        leadingLabelsAlignmentGuide.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        leadingLabelsAlignmentGuide.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        leadingLabelsAlignmentGuide.leadingAnchor.constraint(equalTo: nodeView.trailingAnchor).isActive = true
        leadingLabelsAlignmentGuide.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
    }
    
    func setupConstraints() {
        self.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        
        [primaryView, stopSwitchControl, nodeView, totalLabelsContainerView, stopNameLabel, detailLabelsContainerView, nextStopNameLabel, dotLabel, stopIDLabel].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        primaryView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        primaryView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
        primaryView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        totalLabelsContainerView.leadingAnchor.constraint(equalTo: leadingLabelsAlignmentGuide.leadingAnchor).isActive = true
        totalLabelsContainerView.centerYAnchor.constraint(equalTo: primaryView.centerYAnchor).isActive = true
        
        stopSwitchControl.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        stopSwitchControl.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        stopSwitchControl.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        nodeView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        nodeView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        nodeView.centerYAnchor.constraint(equalTo: primaryView.centerYAnchor).isActive = true
        nodeView.widthAnchor.constraint(equalTo: nodeView.heightAnchor).isActive = true
        
        
        
        // TODO: 임시 코드, RouteNumberLabel 내 intrinsicContentSize와 contentHuggingPriority 구현 필요
        // routeNumberLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        // routeNumberLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        // nodeView.widthAnchor.constraint(equalToConstant: 83).isActive = true
        // nodeView.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        stopNameLabel.leadingAnchor.constraint(equalTo: leadingLabelsAlignmentGuide.leadingAnchor).isActive = true
        stopNameLabel.activateConstraintsToCenterInSuperview(attributes: [.centerY])
        
        constraintsForMode[.regular] = [
            primaryView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            stopSwitchControl.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            stopSwitchControl.topAnchor.constraint(equalTo: primaryView.bottomAnchor, constant: 12),
            stopSwitchControl.labelsLayoutGuide.leadingAnchor.constraint(equalTo: leadingLabelsAlignmentGuide.leadingAnchor)
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
