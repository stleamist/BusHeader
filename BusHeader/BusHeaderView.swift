import UIKit

@IBDesignable class BusHeaderView: UIView, Compactible {
    var sizeMode: CompactibleSizeMode = .regular {
        didSet {
            updateConstraintsForMode(animated: true)
            switchControl.sizeMode = sizeMode
        }
    }
    
    var isAnimationEnabled: Bool = true
    var topCornerRadius: CGFloat = 12
    
    let primaryView = UIView()
    let routeNumberLabel = RouteNumberLabel()
    let switchControl = SwitchControl()
    
    var regularModeConstraints: Set<NSLayoutConstraint> = []
    var compactModeConstraints: Set<NSLayoutConstraint> = []
    
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
        setupSwitchControl()
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
        // 임시 코드, RouteNumberLabel 내 intrinsicContentSize와 contentHuggingPriority 구현 필요
        routeNumberLabel.widthAnchor.constraint(equalToConstant: 83).isActive = true
        routeNumberLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        // routeNumberLabel.setContentHuggingPriority(.defaultHigh, for: .horizontal)
        // routeNumberLabel.setContentHuggingPriority(.defaultHigh, for: .vertical)
        
        regularModeConstraints = [
            primaryView.trailingAnchor.constraint(equalTo: self.layoutMarginsGuide.trailingAnchor),
            switchControl.leadingAnchor.constraint(equalTo: self.layoutMarginsGuide.leadingAnchor),
            switchControl.topAnchor.constraint(equalTo: primaryView.bottomAnchor, constant: 12)
        ]
        
        compactModeConstraints = [
            primaryView.centerYAnchor.constraint(equalTo: self.layoutMarginsGuide.centerYAnchor),
            switchControl.centerYAnchor.constraint(equalTo: self.layoutMarginsGuide.centerYAnchor),
            switchControl.leftSquareView.centerXAnchor.constraint(equalTo: self.layoutMarginsGuide.centerXAnchor),
            primaryView.trailingAnchor.constraint(equalTo: switchControl.trailingAnchor, constant: 12)
        ]
        
        updateConstraintsForMode(animated: false)
    }
    
    func updateConstraintsForMode(animated: Bool) {
        self.regularModeConstraints.forEach({ $0.isActive = false })
        self.compactModeConstraints.forEach({ $0.isActive = false })
        
        switch self.sizeMode {
        case .regular: self.regularModeConstraints.forEach { $0.isActive = true }
        case .compact: self.compactModeConstraints.forEach { $0.isActive = true }
        }
    }
    
    func setupSwitchControl() {
        switchControl.setLabelTexts(left: "양천공영차고지", right: "경인교육대학교")
    }
    
    func setupAppearance() {
        primaryView.clipsToBounds = false
        self.backgroundColor = UIColor(named: "Seoul Green")
        self.routeNumberLabel.textColor = .white
        self.routeNumberLabel.districtText = "서울"
        self.routeNumberLabel.numberText = "6515"
        self.routeNumberLabel.suffixText = "대"
    }
}

public protocol Compactible {
    var sizeMode: CompactibleSizeMode { get set }
}
public enum CompactibleSizeMode {
    case regular
    case compact
}
