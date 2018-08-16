import UIKit

@IBDesignable public class BusSwitchControl: UIControl, Compactible {
    
    // MARK: - Nested Enums
    
    public enum SelectionMode {
        case left
        case right
    }
    
    
    // MARK: - View Properties
    
    var contentView = UIView()
    
    var centerContainerView = UIView()
    var leftContainerView = UIView()
    var rightContainerView = UIView()
    
    var imagesContainerView = UIView()
    var normalArrowImageView = UIImageView()
    var highlightedArrowImageView = UIImageView()
    
    var labels: [SelectionMode: UILabel] {
        return [.left: leftLabel, .right: rightLabel]
    }
    var leftLabel = UILabel() {
        didSet {
            // .removeFromSuperview()를 호출할 때 관련된 constraints도 함께 제거된다.
            oldValue.removeFromSuperview()
            setupLabel(leftLabel, into: leftContainerView)
            updateLabelStates(animated: false)
            setLabelColors()
        }
    }
    var rightLabel = UILabel() {
        didSet {
            oldValue.removeFromSuperview()
            setupLabel(rightLabel, into: rightContainerView)
            updateLabelStates(animated: false)
            setLabelColors()
        }
    }
    
    
    // MARK: Constraints
    
    var compactLeftModeConstraints: [NSLayoutConstraint.Attribute: NSLayoutConstraint] = [:]
    var compactRightModeConstraints: [NSLayoutConstraint.Attribute: NSLayoutConstraint] = [:]
    var regularModeConstraints: [NSLayoutConstraint.Attribute: NSLayoutConstraint] = [:]
    
    
    // MARK: Feedback Generators
    
    var impactFeedbackGenerator: UIImpactFeedbackGenerator?
    
    
    // MARK: Mode Properties
    
    public var sizeMode: CompactibleSizeMode = .regular {
        didSet {
            updateConstraintsForMode(animated: isAnimationEnabled)
        }
    }
    public var selectionMode: SelectionMode = .right {
        didSet {
            if (oldValue != selectionMode) {
                sendActions(for: .valueChanged)
            }
            updateConstraintsForMode(animated: isAnimationEnabled)
            updateLabelStates(animated: isAnimationEnabled)
            updateArrowRotation(animated: isAnimationEnabled)
        }
    }
    
    
    // MARK: Appearance Properties
    
    var backgroundColors: [UIControl.State: UIColor] = [
        .normal: UIColor(white: 0, alpha: 0.1),
        .highlighted: UIColor(white: 0, alpha: 0.2)
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
    
    @IBInspectable var cornerRadius: CGFloat = 12 {
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
    convenience init(leftLabelText: String, rightLabelText: String) {
        self.init()
        setLabelTexts(left: leftLabelText, right: rightLabelText)
    }
    
    
    // MARK: Setup Methods
    
    func setup() {
        setupSubviews()
        setupConstraints()
        setupLabels()
        setupControl()
        setupArrowImageViews()
        setupAppearance()
    }
    
    func setupSubviews() {
        self.addSubview(contentView)
        contentView.addSubview(centerContainerView)
        contentView.addSubview(leftContainerView)
        contentView.addSubview(rightContainerView)
        centerContainerView.addSubview(imagesContainerView)
        imagesContainerView.addSubview(normalArrowImageView)
        imagesContainerView.addSubview(highlightedArrowImageView)
    }
    
    func setupConstraints() {
        // Disable .translatesAutoresizingMaskIntoConstraints
        
        [
            contentView,
            centerContainerView,
            leftContainerView,
            rightContainerView,
            imagesContainerView,
            normalArrowImageView,
            highlightedArrowImageView
        ].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        
        // Make and Activate Required Constraints
        
        contentView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom])
        
        centerContainerView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom])
        centerContainerView.activateConstraintsToCenterInSuperview(attributes: [.centerX])
        centerContainerView.widthAnchor.constraint(equalTo: centerContainerView.heightAnchor).isActive = true
        
        leftContainerView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .leading])
        leftContainerView.trailingAnchor.constraint(equalTo: imagesContainerView.leadingAnchor).isActive = true
        
        rightContainerView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .trailing])
        rightContainerView.leadingAnchor.constraint(equalTo: imagesContainerView.trailingAnchor).isActive = true
        
        leftContainerView.widthAnchor.constraint(equalTo: rightContainerView.widthAnchor).isActive = true
        
        imagesContainerView.activateConstraintsToCenterInSuperview()
        
        normalArrowImageView.activateConstraintsToCenterInSuperview()
        highlightedArrowImageView.activateConstraintsToCenterInSuperview()
        
        normalArrowImageView.activateConstraintsToFitIntoSuperview()
        highlightedArrowImageView.activateConstraintsToFitIntoSuperview()
        
        
        // Make and Store Constraints for Modes
        
        regularModeConstraints = contentView.constraintsToFitIntoSuperview(attributes: [.leading, .trailing])
        
        compactLeftModeConstraints[.leading] = self.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        compactLeftModeConstraints[.trailing] = self.trailingAnchor.constraint(equalTo: centerContainerView.trailingAnchor)
        
        compactRightModeConstraints[.leading] = self.leadingAnchor.constraint(equalTo: centerContainerView.leadingAnchor)
        compactRightModeConstraints[.trailing] = self.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        
        
        // Update Constraints for Mode
        
        updateConstraintsForMode(animated: false)
    }
    
    func setupLabels() {
        setupLabel(leftLabel, into: leftContainerView)
        setupLabel(rightLabel, into: rightContainerView)
    }
    
    func setupLabel(_ label: UILabel, into containerView: UIView) {
        containerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.activateConstraintsToCenterInSuperview()
    }
    
    func setupControl() {
        self.contentView.isUserInteractionEnabled = false
        
        self.addTarget(self, action: #selector(handleTouchDown(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(handleTouchUpInside(_:)), for: .touchUpInside)
    }
    
    func setupArrowImageViews() {
        assert(self.selectionMode == .right, "Initial selection mode is not '.right'. Arrow can be shown in the opposite direction.")
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
        updateLabelStates(animated: false)
        updateArrowRotation(animated: false)
        setLabelColors()
        setArrowColors()
        setCornerRadius()
    }
    
    
    // MARK: Property Setting Methods
    
    func setLabelTexts(left leftLabelText: String, right rightLabelText: String) {
        self.leftLabel.text = leftLabelText
        self.rightLabel.text = rightLabelText
    }
    
    func setLabelColors() {
        self.labels.forEach({
            $1.textColor = labelColors[.normal]
            $1.highlightedTextColor = labelColors[.highlighted]
        })
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
            self.regularModeConstraints.forEach({ $1.isActive = false })
            self.compactRightModeConstraints.forEach({ $1.isActive = false })
            self.compactLeftModeConstraints.forEach({ $1.isActive = false })
            
            switch self.sizeMode {
            case .regular: self.regularModeConstraints.forEach { $1.isActive = true }
            case .compact:
                switch self.selectionMode {
                case .left: self.compactLeftModeConstraints.forEach { $1.isActive = true }
                case .right: self.compactRightModeConstraints.forEach { $1.isActive = true }
                }
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
    
    func updateLabelStates(animated: Bool) {
        let leftLabelHandler = {
            self.leftLabel.isHighlighted = (self.selectionMode == .left) ? true : false
        }
        let rightLabelHandler = {
            self.rightLabel.isHighlighted = (self.selectionMode == .right) ? true : false
        }
        
        if animated {
            UIView.transition(with: leftLabel, duration: kChangeModeDuration, options: .transitionCrossDissolve, animations: leftLabelHandler)
            UIView.transition(with: rightLabel, duration: kChangeModeDuration, options: .transitionCrossDissolve, animations: rightLabelHandler)
        } else {
            leftLabelHandler()
            rightLabelHandler()
        }
    }
    
    func updateArrowRotation(animated: Bool) {
        let arrowRotationAngle: CGFloat = (self.selectionMode == .right) ? 0 : .pi
        
        let handler = {
            self.imagesContainerView.transform = CGAffineTransform(rotationAngle: arrowRotationAngle)
        }
        
        if animated {
            UIView.animate(withDuration: kChangeModeDuration, delay: 0, options: kAnimationOption, animations: handler)
        } else {
            handler()
        }
    }
    
    
    // MARK: Action Methods
    
    @objc func handleTouchDown(_ sender: BusSwitchControl) {
        self.impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackGenerator?.prepare()
    }
    
    @objc func handleTouchUpInside(_ sender: BusSwitchControl) {
        self.impactFeedbackGenerator?.impactOccurred()
        self.impactFeedbackGenerator = nil
        
        switch self.selectionMode {
        case .left:
            self.selectionMode = .right
            
        case .right:
            self.selectionMode = .left
        }
    }
}
