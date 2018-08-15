import UIKit

@IBDesignable class BusHeaderView: UIView, Compactible {
    
    // MARK: - View Properties
    
    let primaryView = UIView()
    // let secondaryView = UIView()
    let routeNumberLabel = RouteNumberLabel()
    let switchControl = BusSwitchControl()
    
    
    // MARK: Constraints
    
    var constraintsForMode: [CompactibleSizeMode: Set<NSLayoutConstraint>] = [:]
    
    
    // MARK: Mode Properties
    
    var sizeMode: CompactibleSizeMode = .regular {
        didSet {
            // TODO: Switch Control 내의 애니메이션 처리를 Selection Mode 변경에 한해서만 허용할지 결정하기
            updateConstraintsForMode(animated: true)
            switchControl.sizeMode = sizeMode
        }
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
        setupConstraints()
        setupAppearance()
    }
    
    func setupSubviews() {
        self.addSubview(primaryView)
        self.addSubview(switchControl)
        primaryView.addSubview(routeNumberLabel)
    }
    
    func setupConstraints() {
        self.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        
        [primaryView, switchControl, routeNumberLabel].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        primaryView.topAnchor.constraint(equalTo: self.layoutMarginsGuide.topAnchor).isActive = true
        primaryView.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor).isActive = true
        primaryView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        switchControl.bottomAnchor.constraint(equalTo: self.layoutMarginsGuide.bottomAnchor).isActive = true
        switchControl.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor).isActive = true
        switchControl.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        routeNumberLabel.activateConstraintsToFitIntoSuperview(attributes: [.leading])
        routeNumberLabel.activateConstraintsToCenterInSuperview(attributes: [.centerY])
        // TODO: 임시 코드, RouteNumberLabel 내 intrinsicContentSize와 contentHuggingPriority 구현 필요
        // routeNumberLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        // routeNumberLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        routeNumberLabel.widthAnchor.constraint(equalToConstant: 83).isActive = true
        routeNumberLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        constraintsForMode[.regular] = [
            primaryView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            switchControl.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            switchControl.topAnchor.constraint(equalTo: primaryView.bottomAnchor, constant: 12)
        ]
        
        constraintsForMode[.compact] = [
            primaryView.centerYAnchor.constraint(equalTo: self.layoutMarginsGuide.centerYAnchor),
            switchControl.centerYAnchor.constraint(equalTo: self.layoutMarginsGuide.centerYAnchor),
            switchControl.leftSquareView.centerXAnchor.constraint(equalTo: self.layoutMarginsGuide.centerXAnchor),
            primaryView.trailingAnchor.constraint(equalTo: switchControl.trailingAnchor, constant: 12)
        ]
        
        updateConstraintsForMode(animated: false)
    }
    
    func setupAppearance() {
        self.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        
        primaryView.clipsToBounds = false
        
        self.backgroundColor = UIColor(white: 0.25, alpha: 1) // Default Color
        self.routeNumberLabel.textColor = .white
        
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

public protocol Compactible {
    var sizeMode: CompactibleSizeMode { get set }
}
public enum CompactibleSizeMode {
    case regular
    case compact
}
