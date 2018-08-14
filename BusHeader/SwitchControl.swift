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

public class SwitchControl: UIControl {
    
    
    // MARK: View Properties
    
    var contentView = UIView()
    
    var centerContainerView = UIView()
    var leftContainerView = UIView()
    var rightContainerView = UIView()
    
    var centerButton = UIButton()
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
            updateConstraintsForMode()
            updateColorsForMode()
        }
    }
    
    
    // MARK: Appearance Properties
    
    var backgroundColors: [UIControl.State: UIColor] = [
        .normal: .lightGray,
        .highlighted: .gray
    ]
    var titleColors: [UIControl.State: UIColor] = [
        .normal: .blue,
        .selected: .red
    ]
    var arrowColors: [UIControl.State: UIColor] = [
        .normal: .red,
        .selected: .blue
    ]
    
    var cornerRadius: CGFloat = 8 {
        didSet {
            updateCornerRadius()
        }
    }
    
    
    // MARK: Computed Properties
    
    public override var isHighlighted: Bool {
        didSet {
            updateColorsForState()
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
        setupAppearance()
    }
    
    func setupSubviews() {
        self.addSubview(contentView)
        contentView.addSubview(centerContainerView)
        contentView.addSubview(leftContainerView)
        contentView.addSubview(rightContainerView)
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
        
        let longPressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGestureRecognizer.minimumPressDuration = 0
        self.addGestureRecognizer(longPressGestureRecognizer)
    }
    
    func setupAppearance() {
        centerContainerView.backgroundColor = .red
        
        leftLabel.text = "Left"
        rightLabel.text = "Right"
        
        self.clipsToBounds = true
        updateColorsForState()
        updateColorsForMode()
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
    
    func updateColorsForState() {
        self.backgroundColor = self.backgroundColors[self.state]
    }
    
    func updateColorsForMode() {
        switch selectionMode {
        case .left:
            leftLabel.textColor = titleColors[.selected]
            rightLabel.textColor = titleColors[.normal]
        case .right:
            leftLabel.textColor = titleColors[.normal]
            rightLabel.textColor = titleColors[.selected]
        }
    }
    
    func updateCornerRadius() {
        self.layer.cornerRadius = self.cornerRadius
    }
    
    
    // MARK: Action Methods
    
    @objc func handleLongPress(_ sender: UILongPressGestureRecognizer) {
        switch sender.state {
        case .began:
            self.isHighlighted = true
        case .ended, .cancelled:
            self.isHighlighted = false
            switchSelection()
        default:
            ()
        }
    }
    
    
    // MARK: Other Methods
    
    func switchSelection() {
        switch self.selectionMode {
        case .left:
            self.selectionMode = .right
        case .right:
            self.selectionMode = .left
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
