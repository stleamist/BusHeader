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
    
    
    // MARK: View Properties
    
    var contentView = UIView()
    
    var centerContainerView = UIView()
    var leftContainerView = UIView()
    var rightContainerView = UIView()
    
    var centerBelowImageView = UIImageView()
    var centerAboveImageView = UIImageView()
    var leftLabel = UILabel()
    var rightLabel = UILabel()
    
    
    // MARK: Constraints
    
    var compactLeftModeConstraints: [NSLayoutConstraint.Attribute: NSLayoutConstraint] = [:]
    var compactRightModeConstraints: [NSLayoutConstraint.Attribute: NSLayoutConstraint] = [:]
    var regularModeConstraints: [NSLayoutConstraint.Attribute: NSLayoutConstraint] = [:]
    
    
    // MARK: Mode Properties
    
    public var sizeMode: SizeMode = .regular {
        didSet {
            updateConstraintsForMode()
        }
    }
    public var selectionMode: SelectionMode = .left {
        didSet {
            if (oldValue != selectionMode) {
                sendActions(for: .valueChanged)
            }
            updateConstraintsForMode()
            updateLabelStates()
        }
    }
    
    
    // MARK: Appearance Properties
    
    var backgroundColors: [UIControl.State: UIColor] = [
        .normal: UIColor(white: 0, alpha: 0.1),
        .highlighted: UIColor(white: 0, alpha: 0.2)
        ] {
        didSet {
            updateBackgroundColor()
        }
    }
    var labelColors: [UIControl.State: UIColor] = [
        .normal: UIColor(white: 1, alpha: 0.25),
        .highlighted: .white
        ] {
        didSet {
            updateLabelColors()
        }
    }
    var arrowColors: [UIControl.State: UIColor] = [
        .normal: UIColor(white: 1, alpha: 0.25),
        .highlighted: .white
        ] {
        didSet {
            updateArrowColors()
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat = 12 {
        didSet {
            updateCornerRadius()
        }
    }
    
    
    // MARK: Computed Properties
    
    public override var isHighlighted: Bool {
        didSet {
            updateBackgroundColor()
        }
    }
    
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    
    // MARK: Setup Methods
    
    func setup() {
        setupSubviews()
        setupConstraints()
        setupControl()
        setupCenterImageViews()
        setupAppearance()
    }
    
    func setupSubviews() {
        self.addSubview(contentView)
        contentView.addSubview(centerContainerView)
        contentView.addSubview(leftContainerView)
        contentView.addSubview(rightContainerView)
        centerContainerView.addSubview(centerBelowImageView)
        centerContainerView.addSubview(centerAboveImageView)
        leftContainerView.addSubview(leftLabel)
        rightContainerView.addSubview(rightLabel)
    }
    
    func setupConstraints() {
        // Disable .translatesAutoresizingMaskIntoConstraints
        
        [
            contentView,
            centerContainerView,
            leftContainerView,
            rightContainerView,
            centerBelowImageView,
            centerAboveImageView,
            leftLabel,
            rightLabel
        ].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        
        // Make and Activate Required Constraints
        
        contentView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom])
        
        centerContainerView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom])
        centerContainerView.activateConstraintsToCenterInSuperview()
        centerContainerView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        centerContainerView.widthAnchor.constraint(equalTo: centerContainerView.heightAnchor).isActive = true
        
        leftContainerView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .leading])
        leftContainerView.trailingAnchor.constraint(equalTo: centerContainerView.leadingAnchor).isActive = true
        
        rightContainerView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .trailing])
        rightContainerView.leadingAnchor.constraint(equalTo: centerContainerView.trailingAnchor).isActive = true
        
        leftContainerView.widthAnchor.constraint(equalTo: rightContainerView.widthAnchor).isActive = true
        
        centerBelowImageView.activateConstraintsToCenterInSuperview()
        centerAboveImageView.activateConstraintsToCenterInSuperview()
        leftLabel.activateConstraintsToCenterInSuperview()
        rightLabel.activateConstraintsToCenterInSuperview()
        
        
        // Make and Store Constraints for Modes
        
        regularModeConstraints = contentView.constraintsToFitIntoSuperview(attributes: [.leading, .trailing])
        
        compactLeftModeConstraints[.leading] = self.leadingAnchor.constraint(equalTo: centerContainerView.leadingAnchor)
        compactLeftModeConstraints[.trailing] = self.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        
        compactRightModeConstraints[.leading] = self.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        compactRightModeConstraints[.trailing] = self.trailingAnchor.constraint(equalTo: centerContainerView.trailingAnchor)
        
        
        // Update Constraints for Mode
        
        updateConstraintsForMode()
    }
    
    func setupControl() {
        self.contentView.isUserInteractionEnabled = false
        
        self.addTarget(self, action: #selector(handleTouchUpInside(_:)), for: .touchUpInside)
    }
    
    func setupCenterImageViews() {
        let topRightwardsArrowImage = UIImage(named: "Top Rightwards Arrow")
        let bottomLeftwardsArrowImage = UIImage(named: "Bottom Leftwards Arrow")
        self.centerAboveImageView.image = topRightwardsArrowImage
        self.centerBelowImageView.image = bottomLeftwardsArrowImage
        self.centerAboveImageView.sizeToFit()
        self.centerBelowImageView.sizeToFit()
    }
    
    func setupAppearance() {
        leftLabel.text = "Left"
        rightLabel.text = "Right"
        
        self.clipsToBounds = true
        updateBackgroundColor()
        updateLabelColors()
        updateLabelStates()
        updateArrowColors()
        updateCornerRadius()
    }
    
    
    // MARK: Update Methods
    
    func updateConstraintsForMode() {
        regularModeConstraints.forEach({ $1.isActive = false })
        compactLeftModeConstraints.forEach({ $1.isActive = false })
        compactRightModeConstraints.forEach({ $1.isActive = false })
        
        switch sizeMode {
        case .regular: regularModeConstraints.forEach { $1.isActive = true }
        case .compact:
            switch selectionMode {
            case .left: compactRightModeConstraints.forEach { $1.isActive = true }
            case .right: compactLeftModeConstraints.forEach { $1.isActive = true }
            }
        }
    }
    
    func updateBackgroundColor() {
        self.backgroundColor = backgroundColors[self.state]
    }
    
    func updateLabelColors() {
        let labels = [leftLabel, rightLabel]
        labels.forEach({
            $0.textColor = labelColors[.normal]
            $0.highlightedTextColor = labelColors[.highlighted]
        })
    }
    
    func updateArrowColors() {
        self.centerAboveImageView.tintColor = arrowColors[.highlighted]
        self.centerBelowImageView.tintColor = arrowColors[.normal]
    }
    
    func updateLabelStates() {
        // TODO: UILabel에도 highlightedTextColor를 설정할 수 있음.
        switch selectionMode {
        case .left:
            leftLabel.isHighlighted = true
            rightLabel.isHighlighted = false
        case .right:
            leftLabel.isHighlighted = false
            rightLabel.isHighlighted = true
        }
    }
    
    func updateCornerRadius() {
        self.layer.cornerRadius = self.cornerRadius
    }
    
    
    // MARK: Action Methods
    
    @objc func handleTouchUpInside(_ sender: SwitchControl) {
        switchSelection(animated: true)
    }
    
    
    // MARK: Other Methods
    
    func setSize(to sizeMode: SizeMode, animated: Bool) {
        let handler = {
            self.sizeMode = sizeMode
            self.layoutIfNeeded()
        }
        if animated {
            UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseInOut, animations: handler)
        } else {
            handler()
        }
    }
    
    func setSelection(to selectionMode: SelectionMode, animated: Bool) {
        let handler = {
            self.selectionMode = selectionMode
            self.layoutIfNeeded()
        }
        if animated {
            
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: handler)
        } else {
            handler()
        }
    }
    
    func switchSelection(animated: Bool) {
        switch self.selectionMode {
        case .left:
            setSelection(to: .right, animated: animated)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.centerContainerView.transform = CGAffineTransform(rotationAngle: 0)
            })
            
        case .right:
            setSelection(to: .left, animated: animated)
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseInOut, animations: {
                self.centerContainerView.transform = CGAffineTransform(rotationAngle: .pi)
            })
        }
    }
}

extension SwitchControl {
    public enum SelectionMode {
        case left
        case right
    }
    
    public enum SizeMode {
        case compact
        case regular
    }
}
