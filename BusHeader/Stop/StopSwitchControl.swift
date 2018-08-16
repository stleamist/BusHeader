import UIKit

// View Classes for Debug

class ContentView: UIView {}
class ArrowContainerView: UIView {}
class LabelsContainerView: UIView {}
class ArrowView: UIView {}

@IBDesignable public class StopSwitchControl: UIControl, Compactible {
    
    // MARK: - View Properties
    
    var contentView: UIView = ContentView()
    
    var arrowContainerView: UIView = ArrowContainerView()
    var labelsContainerView: UIView = LabelsContainerView()
    var rightSquareView: UIView = UIView()
    
    var arrowView = ArrowView()
    var normalArrowImageView = UIImageView()
    var highlightedArrowImageView = UIImageView()

    var titleLabel = UILabel() {
        didSet {
            oldValue.removeFromSuperview()
            setupTitleLabel()
            setLabelColors()
        }
    }
    var detailLabel = UILabel() {
        didSet {
            oldValue.removeFromSuperview()
            setupDetailLabel()
            setLabelColors()
        }
    }
    
    
    // MARK: Constraints
    
    var regularModeConstraints: Set<NSLayoutConstraint> = []
    var compactModeConstraints: Set<NSLayoutConstraint> = []
    var labelsContainerViewWidthConstraint: NSLayoutConstraint?
    
    
    // MARK: Feedback Generators
    
    var impactFeedbackGenerator: UIImpactFeedbackGenerator?
    
    
    // MARK: Mode Properties
    
    public var sizeMode: CompactibleSizeMode = .regular {
        didSet {
            updateConstraintsForMode(animated: isAnimationEnabled)
            updateCornerRadius(animated: isAnimationEnabled)
        }
    }
    
    func lockLabelsContainerViewWidth(lock: Bool) {
        if lock {
            labelsContainerViewWidthConstraint = labelsContainerView.widthAnchor.constraint(equalToConstant: labelsContainerView.bounds.width)
            labelsContainerViewWidthConstraint?.isActive = true
        } else {
            labelsContainerViewWidthConstraint?.isActive = false
            labelsContainerViewWidthConstraint = nil
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
    
    var regularModeCornerRadius: CGFloat = 12 {
        didSet {
            updateCornerRadius(animated: false)
        }
    }
    var compactModeCornerRadius: CGFloat {
        return (self.bounds.height / 2)
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
        //arrowContainerView.widthAnchor.constraint(equalTo: arrowContainerView.heightAnchor).isActive = true
        
        labelsContainerView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .trailing])
        let labelsContainerViewLeadingConstraint = labelsContainerView.leadingAnchor.constraint(equalTo: arrowContainerView.trailingAnchor)
        labelsContainerViewLeadingConstraint.priority = .defaultHigh
        labelsContainerViewLeadingConstraint.isActive = true
        
        arrowView.activateConstraintsToCenterInSuperview()
        
        normalArrowImageView.activateConstraintsToCenterInSuperview()
        highlightedArrowImageView.activateConstraintsToCenterInSuperview()
        
        normalArrowImageView.activateConstraintsToFitIntoSuperview()
        highlightedArrowImageView.activateConstraintsToFitIntoSuperview()
        
        
        // Make and Store Constraints for Modes
        
        regularModeConstraints = [
            trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            arrowContainerView.widthAnchor.constraint(equalTo: arrowContainerView.heightAnchor)
        ]
        
        compactModeConstraints = [
            titleLabel.trailingAnchor.constraint(equalTo: detailLabel.leadingAnchor),
            self.trailingAnchor.constraint(equalTo: arrowContainerView.trailingAnchor)
        ]
        
        
        // Update Constraints for Mode
        
        updateConstraintsForMode(animated: false)
    }
    
    func setupLabels() {
        setupTitleLabel()
        setupDetailLabel()
    }
    
    func setupTitleLabel() {
        labelsContainerView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.leadingAnchor.constraint(equalTo: labelsContainerView.leadingAnchor).isActive = true
        // leftLabel.activateConstraintsToFitIntoSuperview(attributes: [.leading])
        titleLabel.activateConstraintsToCenterInSuperview(attributes: [.centerY])
    }
    
    func setupDetailLabel() {
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
        self.clipsToBounds = true
        
        updateBackgroundColor(animated: false)
        updateCornerRadius(animated: false)
        updateArrowRotation()
        setLabelColors()
        setArrowColors()
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
    
    func updateCornerRadius(animated: Bool) {
        let handler = {
            switch self.sizeMode {
            case .regular: self.layer.cornerRadius = self.regularModeCornerRadius
            case .compact: self.layer.cornerRadius = self.compactModeCornerRadius
            }
        }
        
        if animated {
            UIView.animate(withDuration: kChangeModeDuration, delay: 0, options: kAnimationOption, animations: handler)
        } else {
            handler()
        }
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
    }
}
