import UIKit

// View Classes for Debug

@IBDesignable public class StopSwitchControl: UIControl, Compactible {
    
    /*
     VIEW HIERARCHIES
     
     - StopSwitchControl
        - contentView
            - leftContainerView
                - arrowView
                    - normalArrowImageView
                    - highlightedArrowImageView
            - nonLeftContainerView
                - textLabel
                - detailTextLabel
                - (rightSquareLayoutGuide)
                - (labelsLayoutGuide)
     */
    
    // MARK: - View Properties
    
    var contentView: UIView = UIView()
    
    var leftContainerView: UIView = UIView()
    var nonLeftContainerView: UIView = UIView()
    
    var arrowView = UIView()
    var normalArrowImageView = UIImageView()
    var highlightedArrowImageView = UIImageView()

    var textLabel = UILabel() {
        didSet {
            oldValue.removeFromSuperview()
            setupTextLabel(withConstraints: true)
            setLabelColors()
        }
    }
    var detailTextLabel = UILabel() {
        didSet {
            oldValue.removeFromSuperview()
            setupDetailTextLabel(withConstraints: true)
            setLabelColors()
        }
    }
    
    
    // MARK: Layout Guides
    
    let labelsLayoutGuide = UILayoutGuide()
    
    
    // MARK: Constraints
    
    var constraintsForMode: [CompactibleSizeMode: Set<NSLayoutConstraint>] = [
        .regular: [],
        .compact: []
    ]
    
    
    // MARK: Feedback Generators
    
    var impactFeedbackGenerator: UIImpactFeedbackGenerator?
    
    
    // MARK: Mode Properties
    
    public var sizeMode: CompactibleSizeMode = .regular {
        didSet {
            updateConstraintsForMode(animated: isAnimationEnabled)
            updateCornerRadius(animated: isAnimationEnabled)
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
    var textColor: UIColor = .white {
        didSet {
            setLabelColors()
        }
    }
    var detailTextColor: UIColor = UIColor(white: 1, alpha: 0.25) {
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
    
    var arrowRotationAngle: CGFloat = 0 {
        didSet {
            updateArrowRotation(animated: false)
        }
    }
    
    @IBInspectable var regularModeCornerRadius: CGFloat = 12 {
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
    convenience init(text: String, detailText: String) {
        self.init()
        setLabelTexts(text: text, detailText: detailText)
    }
    
    
    // MARK: Setup Methods
    
    func setup() {
        setupSubviews()
        setupLayoutGuides()
        setupConstraints()
        setupLabels()
        setupControl()
        setupArrowImageViews()
        setupAppearance()
    }
    
    func setupSubviews() {
        self.addSubview(contentView)
        contentView.addSubview(leftContainerView)
        contentView.addSubview(nonLeftContainerView)
        leftContainerView.addSubview(arrowView)
        arrowView.addSubview(normalArrowImageView)
        arrowView.addSubview(highlightedArrowImageView)
    }
    
    func setupLayoutGuides() {
        nonLeftContainerView.addLayoutGuide(labelsLayoutGuide)
        
        labelsLayoutGuide.topAnchor.constraint(equalTo: nonLeftContainerView.topAnchor).isActive = true
        labelsLayoutGuide.bottomAnchor.constraint(equalTo: nonLeftContainerView.bottomAnchor).isActive = true
        labelsLayoutGuide.leadingAnchor.constraint(equalTo: nonLeftContainerView.leadingAnchor).formPriority(.defaultHigh).isActive = true
        labelsLayoutGuide.trailingAnchor.constraint(equalTo: nonLeftContainerView.trailingAnchor).isActive = true
    }
    
    func setupConstraints() {
        // Disable .translatesAutoresizingMaskIntoConstraints
        
        [
            contentView,
            leftContainerView,
            nonLeftContainerView,
            arrowView,
            normalArrowImageView,
            highlightedArrowImageView
        ].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        
        // Make and Activate Required Constraints
        
        contentView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .leading])
        constraintsForMode[.regular]?.insert(
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        )
        
        leftContainerView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .leading])
        constraintsForMode[.regular]?.insert(
            leftContainerView.widthAnchor.constraint(equalTo: leftContainerView.heightAnchor)
        )
        constraintsForMode[.compact]?.insert(
            leftContainerView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        )
        
        nonLeftContainerView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .trailing])
        nonLeftContainerView.leadingAnchor.constraint(equalTo: leftContainerView.trailingAnchor).isActive = true
        
        arrowView.activateConstraintsToCenterInSuperview()
        
        [normalArrowImageView, highlightedArrowImageView].forEach({
            $0.activateConstraintsToCenterInSuperview()
            $0.activateConstraintsToFitIntoSuperview()
        })
        
        
        // Update Constraints for Mode
        
        updateConstraintsForMode(animated: false)
    }
    
    func setupLabels() {
        setupTextLabel(withConstraints: false)
        setupDetailTextLabel(withConstraints: false)
        setupInterLabelConstraints()
    }
    
    func setupTextLabel(withConstraints: Bool) {
        nonLeftContainerView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        textLabel.leadingAnchor.constraint(equalTo: labelsLayoutGuide.leadingAnchor).isActive = true
        textLabel.centerYAnchor.constraint(equalTo: labelsLayoutGuide.centerYAnchor).isActive = true
        
        if withConstraints { setupInterLabelConstraints() }
    }
    
    func setupDetailTextLabel(withConstraints: Bool) {
        nonLeftContainerView.addSubview(detailTextLabel)
        detailTextLabel.translatesAutoresizingMaskIntoConstraints = false
        detailTextLabel.trailingCenterAnchor.constraint(equalTo: nonLeftContainerView.trailingCenterAnchor).isActive = true
        detailTextLabel.centerYAnchor.constraint(equalTo: nonLeftContainerView.centerYAnchor).isActive = true
        
        if withConstraints { setupInterLabelConstraints() }
    }
    
    func setupInterLabelConstraints() {
        // .fittingSizeLevel보다 크면 각각의 라벨 너비가 모호하다는 메시지가 뜬다.
        // .regular 모드에서 서로의 최단거리가 0이 되게 하려면 어느 한 쪽의 너비가 정해저야 하기 때문이다.
        detailTextLabel.leadingAnchor.constraint(equalTo: textLabel.trailingAnchor).formPriority(.fittingSizeLevel).isActive = true
    }
    
    func setupControl() {
        self.contentView.isUserInteractionEnabled = false
        
        self.addTarget(self, action: #selector(handleTouchDown(_:)), for: .touchDown)
        self.addTarget(self, action: #selector(handleTouchUpInside(_:)), for: .touchUpInside)
    }
    
    func setupArrowImageViews() {
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
        updateArrowRotation(animated: false)
        updateCornerRadius(animated: false)
        setLabelColors()
        setArrowColors()
    }
    
    
    // MARK: Property Setting Methods
    
    func setLabelTexts(text: String, detailText: String) {
        self.textLabel.text = text
        self.detailTextLabel.text = detailText
    }
    
    func setLabelColors() {
        self.textLabel.textColor = textColor
        self.detailTextLabel.textColor = detailTextColor
    }
    
    func setArrowColors() {
        self.highlightedArrowImageView.tintColor = arrowColors[.highlighted]
        self.normalArrowImageView.tintColor = arrowColors[.normal]
    }
    
    
    // MARK: Update Methods
    
    func updateConstraintsForMode(animated: Bool) {
        let handler = {
            self.constraintsForMode[.regular]?.forEach({ $0.isActive = false })
            self.constraintsForMode[.compact]?.forEach({ $0.isActive = false })
            
            switch self.sizeMode {
            case .regular: self.constraintsForMode[.regular]?.forEach({ $0.isActive = true })
            case .compact: self.constraintsForMode[.compact]?.forEach({ $0.isActive = true })
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
    
    func updateArrowRotation(animated: Bool) {
        let handler = {
            self.arrowView.transform = CGAffineTransform(rotationAngle: self.arrowRotationAngle)
        }
        
        if animated {
            UIView.animate(withDuration: kChangeModeDuration, delay: 0, options: kAnimationOption, animations: handler)
        } else {
            handler()
        }
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
    
    
    // MARK: Action Methods
    
    @objc func handleTouchDown(_ sender: BusSwitchControl) {
        self.impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        impactFeedbackGenerator?.prepare()
    }
    
    @objc func handleTouchUpInside(_ sender: BusSwitchControl) {
        self.impactFeedbackGenerator?.impactOccurred()
        self.impactFeedbackGenerator = nil
    }
    
    
    // MARK: Lock Non-Left Container View Width (WIP)
    
    var nonLeftContainerViewWidthConstraint: NSLayoutConstraint?
    func lockNonLeftContainerViewWidth(lock: Bool) {
        if lock {
            nonLeftContainerViewWidthConstraint = nonLeftContainerView.widthAnchor.constraint(equalToConstant: nonLeftContainerView.bounds.width)
            nonLeftContainerViewWidthConstraint?.isActive = true
        } else {
            nonLeftContainerViewWidthConstraint?.isActive = false
            nonLeftContainerViewWidthConstraint = nil
        }
    }
}
