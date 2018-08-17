import UIKit

@IBDesignable class StopHeaderView: UIView, Compactible {
    
    // MARK: - View Properties
    
    let primaryView = UIView()
    let nodeView = NodeView()
    let stopInfoLabels = StopInfoLabels()
    let stopSwitchControl = StopSwitchControl()
    
    
    // MARK: Layout Guides
    
    let leadingLabelsAlignmentGuide = UILayoutGuide()
    
    
    // MARK: Constraints
    
    var constraintsForMode: [CompactibleSizeMode: Set<NSLayoutConstraint>] = [:]
    
    
    // MARK: Mode Properties
    
    var sizeMode: CompactibleSizeMode = .regular {
        didSet {
            updateVisibilityForMode(animated: true)
            updateConstraintsForMode(animated: true)
            stopSwitchControl.sizeMode = sizeMode
        }
    }
    
    
    // MARK: Data Properties
    
    var stopNameText: String = "" {
        didSet { updateLabelTexts() }
    }
    var nextStopNameText: String = "" {
        didSet { updateLabelTexts() }
    }
    let dotText: String = " · "
    var stopIDText: String = "" {
        didSet { updateLabelTexts() }
    }
    
    
    // MARK: Appearance Properties
    
    var textColor: UIColor = .white {
        didSet {
            setLabelColors()
        }
    }
    var detailTextColor: UIColor = UIColor(white: 1, alpha: 0.75) {
        didSet {
            setLabelColors()
        }
    }
    
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
        primaryView.addSubview(stopInfoLabels)
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
        
        [primaryView, stopSwitchControl, nodeView, stopInfoLabels].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        primaryView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        primaryView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
        primaryView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        // TODO: 임시 코드, NodeView 내 intrinsicContentSize와 contentHuggingPriority 구현 필요
        nodeView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        nodeView.leadingAnchor.constraint(equalTo: self.leadingAnchor).isActive = true
        nodeView.centerYAnchor.constraint(equalTo: primaryView.centerYAnchor).isActive = true
        nodeView.widthAnchor.constraint(equalTo: nodeView.heightAnchor).isActive = true
        
        stopInfoLabels.leadingAnchor.constraint(equalTo: leadingLabelsAlignmentGuide.leadingAnchor).isActive = true
        stopInfoLabels.centerYAnchor.constraint(equalTo: primaryView.centerYAnchor).isActive = true
        
        stopSwitchControl.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        stopSwitchControl.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        stopSwitchControl.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        constraintsForMode[.regular] = [
            primaryView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            stopInfoLabels.bottomAnchor.constraint(equalTo: stopInfoLabels.textLabelsStackView.bottomAnchor),
            stopSwitchControl.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            stopSwitchControl.topAnchor.constraint(equalTo: primaryView.bottomAnchor, constant: 12),
            stopSwitchControl.labelsLayoutGuide.leadingAnchor.constraint(equalTo: leadingLabelsAlignmentGuide.leadingAnchor)
        ]
        
        constraintsForMode[.compact] = [
            primaryView.centerYAnchor.constraint(equalTo: self.layoutMarginsGuide.centerYAnchor),
            primaryView.trailingAnchor.constraint(equalTo: stopSwitchControl.trailingAnchor, constant: 12),
            stopSwitchControl.widthAnchor.constraint(equalTo: stopSwitchControl.heightAnchor)
        ]
        
        updateVisibilityForMode(animated: false)
        updateConstraintsForMode(animated: false)
    }
    
    func setupAppearance() {
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        primaryView.clipsToBounds = false
        nodeView.clipsToBounds = false
        
        self.backgroundColor = UIColor(white: 0.25, alpha: 1) // Default Color
        // FIXME: 테스트용 코드
        self.nodeView.nodeColors = [UIColor(rgb: 0x175CE6), UIColor(rgb: 0x29CC5F), UIColor(rgb: 0x29CCCC)]
        
        setLabelColors()
        setCornerRadius()
    }
    
    
    // MARK: Property Setting Methods
    
    func setLabelColors() {
        stopInfoLabels.textColor = self.textColor
        stopSwitchControl.textColor = self.textColor
        
        stopInfoLabels.detailTextColor = self.detailTextColor
        stopSwitchControl.detailTextColor = self.detailTextColor
    }
    
    func setCornerRadius() {
        self.layer.cornerRadius = self.topCornerRadius
    }
    
    
    // MARK: Update Methods
    
    func updateLabelTexts() {
        self.stopInfoLabels.stopNameText = self.stopNameText
        
        self.stopInfoLabels.nextStopNameText = self.nextStopNameText
        self.stopSwitchControl.textLabel.text = self.nextStopNameText
        
        self.stopInfoLabels.stopIDText = self.stopIDText
        self.stopSwitchControl.detailTextLabel.text = self.stopIDText
    }
    
    func updateVisibilityForMode(animated: Bool) {
        let animationHandler = {
            self.stopInfoLabels.detailLabelsStackView.alpha = (self.sizeMode == .regular) ? 0 : 1
            self.stopSwitchControl.nonLeftContainerView.alpha = (self.sizeMode == .regular) ? 1 : 0
        }
        let completionHandler = { (finished: Bool) in
            self.stopInfoLabels.clipsToBounds = true
        }
        
        self.stopInfoLabels.clipsToBounds = false
        
        if animated {
            UIView.animate(withDuration: kChangeModeDuration, delay: 0, options: kAnimationOption, animations: animationHandler, completion: completionHandler)
        } else {
            animationHandler()
            completionHandler(true)
        }
    }
    
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
