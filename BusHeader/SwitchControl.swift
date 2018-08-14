import UIKit

extension UIView {
    func constraintsToFitIntoSuperview(attributes: Set<NSLayoutConstraint.Attribute> = [.top, .bottom, .leading, .trailing]) -> [NSLayoutConstraint.Attribute: NSLayoutConstraint] {
        
        guard let parent = self.superview else { return [:] }
        
        var constraints: [NSLayoutConstraint.Attribute: NSLayoutConstraint] = [
            .top: self.topAnchor.constraint(equalTo: parent.topAnchor),
            .bottom: self.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
            .leading: self.leadingAnchor.constraint(equalTo: parent.leadingAnchor),
            .trailing: self.trailingAnchor.constraint(equalTo: parent.trailingAnchor)
        ]
        constraints = constraints.filter({ (key, _) -> Bool in
            attributes.contains(key)
        })
        
        return constraints
    }
    
    func constraintsToCenterInSuperview(attributes: Set<NSLayoutConstraint.Attribute> = [.centerX, .centerY]) -> [NSLayoutConstraint.Attribute: NSLayoutConstraint] {
        
        guard let parent = self.superview else { return [:] }
        
        var constraints: [NSLayoutConstraint.Attribute: NSLayoutConstraint] = [
            .centerX: self.centerXAnchor.constraint(equalTo: parent.centerXAnchor),
            .centerY: self.centerYAnchor.constraint(equalTo: parent.centerYAnchor)
        ]
        constraints = constraints.filter({ (key, _) -> Bool in
            attributes.contains(key)
        })
        
        return constraints
    }
    
    @discardableResult func activateConstraintsToFitIntoSuperview(attributes: Set<NSLayoutConstraint.Attribute> = [.top, .bottom, .leading, .trailing]) -> [NSLayoutConstraint.Attribute: NSLayoutConstraint] {
        
        let constraints = self.constraintsToFitIntoSuperview(attributes: attributes)
        constraints.forEach({ $1.isActive = true })
        
        return constraints
    }
    
    @discardableResult func activateConstraintsToCenterInSuperview(attributes: Set<NSLayoutConstraint.Attribute> = [.centerX, .centerY]) -> [NSLayoutConstraint.Attribute: NSLayoutConstraint] {
        
        let constraints = self.constraintsToCenterInSuperview(attributes: attributes)
        constraints.forEach({ $1.isActive = true })
        
        return constraints
    }
}

extension UIControl.State: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

@IBDesignable public class SwitchControl: UIControl {
    
    // MARK: Nested Enums
    
    public enum SelectionMode {
        case left
        case right
    }
    
    public enum SizeMode {
        case compact
        case regular
    }
    
    
    // MARK: View Properties
    
    var contentView = UIView()
    
    var centerContainerView = UIView()
    var leftContainerView = UIView()
    var rightContainerView = UIView()
    
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
    
    
    // MARK: Mode Properties
    
    public var sizeMode: SizeMode = .regular {
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
    
    
    // MARK: Initialization
    
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
        setupCenterImageViews()
        setupAppearance()
    }
    
    func setupSubviews() {
        self.addSubview(contentView)
        contentView.addSubview(centerContainerView)
        contentView.addSubview(leftContainerView)
        contentView.addSubview(rightContainerView)
        centerContainerView.addSubview(normalArrowImageView)
        centerContainerView.addSubview(highlightedArrowImageView)
    }
    
    func setupConstraints() {
        // Disable .translatesAutoresizingMaskIntoConstraints
        
        [
            contentView,
            centerContainerView,
            leftContainerView,
            rightContainerView,
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
        leftContainerView.trailingAnchor.constraint(equalTo: centerContainerView.leadingAnchor).isActive = true
        
        rightContainerView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .trailing])
        rightContainerView.leadingAnchor.constraint(equalTo: centerContainerView.trailingAnchor).isActive = true
        
        leftContainerView.widthAnchor.constraint(equalTo: rightContainerView.widthAnchor).isActive = true
        
        normalArrowImageView.activateConstraintsToCenterInSuperview()
        highlightedArrowImageView.activateConstraintsToCenterInSuperview()
        
        
        // Make and Store Constraints for Modes
        
        regularModeConstraints = contentView.constraintsToFitIntoSuperview(attributes: [.leading, .trailing])
        
        compactLeftModeConstraints[.leading] = self.leadingAnchor.constraint(equalTo: centerContainerView.leadingAnchor)
        compactLeftModeConstraints[.trailing] = self.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        
        compactRightModeConstraints[.leading] = self.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        compactRightModeConstraints[.trailing] = self.trailingAnchor.constraint(equalTo: centerContainerView.trailingAnchor)
        
        
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
        
        self.addTarget(self, action: #selector(handleTouchUpInside(_:)), for: .touchUpInside)
    }
    
    func setupCenterImageViews() {
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
            self.compactLeftModeConstraints.forEach({ $1.isActive = false })
            self.compactRightModeConstraints.forEach({ $1.isActive = false })
            
            switch self.sizeMode {
            case .regular: self.regularModeConstraints.forEach { $1.isActive = true }
            case .compact:
                switch self.selectionMode {
                case .left: self.compactRightModeConstraints.forEach { $1.isActive = true }
                case .right: self.compactLeftModeConstraints.forEach { $1.isActive = true }
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
        let rotationAngle: CGFloat = (self.selectionMode == .right) ? 0 : .pi
        
        let handler = {
            self.centerContainerView.transform = CGAffineTransform(rotationAngle: rotationAngle)
        }
        
        if animated {
            UIView.animate(withDuration: kChangeModeDuration, delay: 0, options: kAnimationOption, animations: handler)
        } else {
            handler()
        }
    }
    
    
    // MARK: Action Methods
    
    @objc func handleTouchUpInside(_ sender: SwitchControl) {
        switch self.selectionMode {
        case .left:
            self.selectionMode = .right
            
        case .right:
            self.selectionMode = .left
        }
    }
}
