import UIKit

@IBDesignable public class StopSwitchControl: UIControl, Compactible {
    
    // MARK: - View Properties
    
    var contentView = UIView()
    
    var arrowContainerView = UIView()
    var labelsContainerView = UIView()
    
    var arrowView = UIView()
    var normalArrowImageView = UIImageView()
    var highlightedArrowImageView = UIImageView()

    var titleLabel = UILabel() {
        didSet {
            // .removeFromSuperview()를 호출할 때 관련된 constraints도 함께 제거된다.
            oldValue.removeFromSuperview()
            setupLeftLabel()
            setLabelColors()
        }
    }
    var detailLabel = UILabel() {
        didSet {
            oldValue.removeFromSuperview()
            setupRightLabel()
            setLabelColors()
        }
    }
    
    
    // MARK: Constraints
    
    var regularModeConstraints: Set<NSLayoutConstraint> = []
    var compactModeConstraints: Set<NSLayoutConstraint> = []
    var rightContainerWidthAnchor: NSLayoutConstraint?
    
    
    // MARK: Feedback Generators
    
    var impactFeedbackGenerator: UIImpactFeedbackGenerator?
    
    
    // MARK: Mode Properties
    
    public var sizeMode: CompactibleSizeMode = .regular {
        didSet {
            if (sizeMode == .compact) {
                rightContainerWidthAnchor = labelsContainerView.widthAnchor.constraint(equalToConstant: labelsContainerView.bounds.width)
                rightContainerWidthAnchor?.isActive = true
                self.cornerRadius = 22
            } else {
                rightContainerWidthAnchor?.isActive = false
                self.cornerRadius = 12
            }
            updateConstraintsForMode(animated: isAnimationEnabled)
        }
    }
    
    
    // MARK: Appearance Properties
    
    var backgroundColors: [UIControl.State: UIColor] = [
        .normal: UIColor(white: 0, alpha: 0.2),
        .highlighted: UIColor(white: 0, alpha: 0.4)
        ] {
        didSet {
            updateBackgroundColor(animated: false)
        }
    }
    var labelColors: [UIControl.State: UIColor] = [
        .normal: UIColor(white: 1, alpha: 0.25),
        .highlighted: .white
        ] {
        didSet {
            setLabelColors()
        }
    }
    var arrowColors: [UIControl.State: UIColor] = [
        .normal: UIColor(white: 1, alpha: 0.25),
        .highlighted: .white
        ] {
        didSet {
            setArrowColors()
        }
    }
    
    var cornerRadius: CGFloat = 12 {
        didSet {
            setCornerRadius()
        }
    }
    
    
    // MARK: Constants
    
    let kAnimationOption: UIView.AnimationOptions = .curveEaseInOut
    let kChangeModeDuration: TimeInterval = 0.3
    let kBackgroundHighlightDuration: TimeInterval = 0.1
    
    
    
    // MARK: Bool Properties
    
    public override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor(animated: isAnimationEnabled)
        }
    }
    
    var isAnimationEnabled: Bool = true
    
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    convenience init(title: String, detail: String) {
        self.init()
        setLabelTexts(title: title, detail: detail)
    }
    
    
    // MARK: Setup Methods
    
    func setup() {
        setupSubviews()
        setupConstraints()
        setupLabels()
        setupControl()
        setupCenterImageViews()
        setupAppearance()
    }
    
    func setupSubviews() {
        self.addSubview(contentView)
        contentView.addSubview(arrowContainerView)
        contentView.addSubview(labelsContainerView)
        arrowContainerView.addSubview(arrowView)
        arrowView.addSubview(normalArrowImageView)
        arrowView.addSubview(highlightedArrowImageView)
    }
    
    func setupConstraints() {
        // Disable .translatesAutoresizingMaskIntoConstraints
        
        [
            contentView,
            arrowContainerView,
            labelsContainerView,
            arrowView,
            normalArrowImageView,
            highlightedArrowImageView
        ].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        
        // Make and Activate Required Constraints
        
        contentView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .leading])
        
        arrowContainerView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .leading])
        arrowContainerView.widthAnchor.constraint(equalTo: arrowContainerView.heightAnchor).isActive = true
        
        labelsContainerView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .trailing])
        let rightContainerViewLeadingConstraint = labelsContainerView.leadingAnchor.constraint(equalTo: arrowContainerView.trailingAnchor)
        rightContainerViewLeadingConstraint.priority = .defaultHigh
        rightContainerViewLeadingConstraint.isActive = true
        
        arrowView.activateConstraintsToCenterInSuperview()
        
        normalArrowImageView.activateConstraintsToCenterInSuperview()
        highlightedArrowImageView.activateConstraintsToCenterInSuperview()
        
        normalArrowImageView.activateConstraintsToFitIntoSuperview()
        highlightedArrowImageView.activateConstraintsToFitIntoSuperview()
        
        
        // Make and Store Constraints for Modes
        
        regularModeConstraints = [
            self.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        ]
        
        compactModeConstraints = [
            self.trailingAnchor.constraint(equalTo: arrowContainerView.trailingAnchor)
        ]
        
        
        // Update Constraints for Mode
        
        updateConstraintsForMode(animated: false)
    }
    
    func setupLabels() {
        setupLeftLabel()
        setupRightLabel()
    }
    
    func setupLeftLabel() {
        labelsContainerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: labelsContainerView.leadingAnchor, constant: 13).isActive = true
        // leftLabel.activateConstraintsToFitIntoSuperview(attributes: [.leading])
        titleLabel.activateConstraintsToCenterInSuperview(attributes: [.centerY])
    }
    
    func setupRightLabel() {
        labelsContainerView.addSubview(detailLabel)
        detailLabel.translatesAutoresizingMaskIntoConstraints = false
        detailLabel.trailingAnchor.constraint(equalTo: labelsContainerView.trailingAnchor, constant: -13).isActive = true
        detailLabel.activateConstraintsToCenterInSuperview(attributes: [.centerY])
    }
    
    func setupControl() {
        self.contentView.isUserInteractionEnabled = false
        
        self.addTarget(self, action: #selector(handleTouchDown(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(handleTouchUpInside(_:)), for: .touchUpInside)
    }
    
    func setupCenterImageViews() {
        let topRightwardsArrowImage = UIImage(named: "Top Rightwards Arrow")
        let bottomLeftwardsArrowImage = UIImage(named: "Bottom Leftwards Arrow")
        self.highlightedArrowImageView.image = topRightwardsArrowImage
        self.normalArrowImageView.image = bottomLeftwardsArrowImage
        self.highlightedArrowImageView.sizeToFit()
        self.normalArrowImageView.sizeToFit()
    }
    
    func setupAppearance() {
        // FIXME: 사이즈 변경 테스트용. true로 변경해야 함.
        self.clipsToBounds = true
        
        updateBackgroundColor(animated: false)
        updateArrowRotation()
        setLabelColors()
        setArrowColors()
        setCornerRadius()
    }
    
    
    // MARK: Property Setting Methods
    
    func setLabelTexts(title: String, detail: String) {
        self.titleLabel.text = title
        self.detailLabel.text = detail
    }
    
    func setLabelColors() {
        self.titleLabel.textColor = labelColors[.highlighted]
        self.detailLabel.textColor = labelColors[.normal]
    }
    
    func setArrowColors() {
        self.highlightedArrowImageView.tintColor = arrowColors[.highlighted]
        self.normalArrowImageView.tintColor = arrowColors[.normal]
    }
    
    func setCornerRadius() {
        self.layer.cornerRadius = self.cornerRadius
    }
    
    
    // MARK: Update Methods
    
    func updateConstraintsForMode(animated: Bool) {
        let handler = {
            self.regularModeConstraints.forEach({ $0.isActive = false })
            self.compactModeConstraints.forEach({ $0.isActive = false })
            
            switch self.sizeMode {
            case .regular: self.regularModeConstraints.forEach { $0.isActive = true }
            case .compact: self.compactModeConstraints.forEach { $0.isActive = true }
            }
            
            self.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: kChangeModeDuration, delay: 0, options: kAnimationOption, animations: handler)
        } else {
            handler()
        }
    }
    
    func updateBackgroundColor(animated: Bool) {
        let handler = {
            self.backgroundColor = self.backgroundColors[self.state]
        }
        
        if animated {
            UIView.animate(withDuration: kBackgroundHighlightDuration, delay: 0, options: kAnimationOption, animations: handler)
        } else {
            handler()
        }
    }
    
    var arrowRotationAngle: CGFloat = 0 {
        didSet {
            updateArrowRotation()
        }
    }
    
    func updateArrowRotation() {
        self.arrowView.transform = CGAffineTransform(rotationAngle: self.arrowRotationAngle)
    }
    
    
    // MARK: Action Methods
    
    @objc func handleTouchDown(_ sender: BusSwitchControl) {
        self.impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackGenerator?.prepare()
    }
    
    @objc func handleTouchUpInside(_ sender: BusSwitchControl) {
        self.impactFeedbackGenerator?.impactOccurred()
        self.impactFeedbackGenerator = nil
        
        // sendActions(for: .touchUpInside)
    }
}
