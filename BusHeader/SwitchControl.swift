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
        
        self.translatesAutoresizingMaskIntoConstraints = false
        constraints.forEach({ $1.isActive = true })
        
        return constraints
    }
    
    @discardableResult func activateConstraintsToCenterInSuperview(attributes: Set<NSLayoutConstraint.Attribute> = [.centerX, .centerY]) -> [NSLayoutConstraint.Attribute: NSLayoutConstraint] {
        
        let constraints = self.constraintsToCenterInSuperview(attributes: attributes)
        
        self.translatesAutoresizingMaskIntoConstraints = false
        constraints.forEach({ $1.isActive = true })
        
        return constraints
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

public class SwitchControl: UIControl {
    var contentView = UIView()
    var centerContainerView = UIView()
    var leftContainerView = UIView()
    var rightContainerView = UIView()
    var leftLabel = UILabel()
    var rightLabel = UILabel()
    
    public var sizeMode: SizeMode = .regular {
        didSet {
            updateConstraintsForModeChange()
        }
    }
    public var selectionMode: SelectionMode = .left {
        didSet {
            updateConstraintsForModeChange()
        }
    }
    
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
        self.addSubview(contentView)
        contentView.addSubview(centerContainerView)
        contentView.addSubview(leftContainerView)
        contentView.addSubview(rightContainerView)
        leftContainerView.addSubview(leftLabel)
        rightContainerView.addSubview(rightLabel)
    }
    
    func setupConstraints() {
        centerContainerView.activateConstraintsToCenterInSuperview()
        centerContainerView.widthAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        centerContainerView.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true
        
        leftContainerView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .leading])
        leftContainerView.trailingAnchor.constraint(equalTo: centerContainerView.leadingAnchor).isActive = true
        
        rightContainerView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .trailing])
        rightContainerView.leadingAnchor.constraint(equalTo: centerContainerView.trailingAnchor).isActive = true
        
        leftLabel.activateConstraintsToCenterInSuperview()
        rightLabel.activateConstraintsToCenterInSuperview()
        
        //
        centerContainerView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        centerContainerView.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        
        leftContainerView.widthAnchor.constraint(equalTo: rightContainerView.widthAnchor).isActive = true
        
        contentView.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom])
        
        // setup dict constraints
        
        regularModeConstraints = contentView.constraintsToFitIntoSuperview(attributes: [.leading, .trailing])
        
        compactLeftModeConstraints[.leading] = self.leadingAnchor.constraint(equalTo: centerContainerView.leadingAnchor)
        compactLeftModeConstraints[.trailing] = self.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
        
        compactRightModeConstraints[.leading] = self.leadingAnchor.constraint(equalTo: contentView.leadingAnchor)
        compactRightModeConstraints[.trailing] = self.trailingAnchor.constraint(equalTo: centerContainerView.trailingAnchor)
        
        //
        updateConstraintsForModeChange()
        // setupConstraintsForRegularMode()
    }
    
    var compactLeftModeConstraints: [NSLayoutConstraint.Attribute: NSLayoutConstraint] = [:]
    var compactRightModeConstraints: [NSLayoutConstraint.Attribute: NSLayoutConstraint] = [:]
    var regularModeConstraints: [NSLayoutConstraint.Attribute: NSLayoutConstraint] = [:]
    
    func updateConstraintsForModeChange() {
        deactivateAllConstraints()
        
        switch sizeMode {
        case .regular: activateConstraintsForRegularMode()
        case .compact:
            switch selectionMode {
            case .left: activateConstraintsForCompactLeftMode()
            case .right: activateConstraintsForCompactRightMode()
            }
        }
    }
    
    func deactivateAllConstraints() {
        regularModeConstraints.forEach({ $1.isActive = false })
        compactLeftModeConstraints.forEach({ $1.isActive = false })
        compactRightModeConstraints.forEach({ $1.isActive = false })
    }
    
    func activateConstraintsForRegularMode() {
        regularModeConstraints.forEach { $1.isActive = true }
    }
    
    func activateConstraintsForCompactLeftMode() {
        compactRightModeConstraints.forEach { $1.isActive = true }
    }
    
    func activateConstraintsForCompactRightMode() {
        compactLeftModeConstraints.forEach { $1.isActive = true }
    }
    
    
    
    func setupAppearance() {
        self.backgroundColor = .gray
        centerContainerView.backgroundColor = .red
        
        leftLabel.text = "여의도"
        rightLabel.text = "장지공영차고지"
    }
}
