import UIKit

@IBDesignable class BusHeaderView: UIView {
    enum SizeMode {
        case regular
        case compact
    }
    
    let stackView = UIStackView()
    let titleContainerView = UIView()
    let routeNumberLabel = RouteNumberLabel()
    let switchControl = SwitchControl()
    
    var sizeMode: SizeMode = .regular {
        didSet {
            switch sizeMode {
            case .regular:
                self.stackView.axis = .vertical
                self.switchControl.sizeMode = .regular
            case .compact:
                self.stackView.axis = .horizontal
                self.switchControl.sizeMode = .compact
                self.switchControl.leftSquareView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            }
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
        setupStackView()
        setupSwitchControl()
        setupAppearance()
    }
    
    func setupSubviews() {
        self.addSubview(stackView)
        stackView.addArrangedSubview(titleContainerView)
        stackView.addArrangedSubview(switchControl)
        titleContainerView.addSubview(routeNumberLabel)
    }
    
    func setupConstraints() {
        [stackView, titleContainerView, routeNumberLabel, switchControl].forEach({
            $0.translatesAutoresizingMaskIntoConstraints = false
        })
        
        stackView.activateConstraintsToFitIntoSuperview()
        titleContainerView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        switchControl.heightAnchor.constraint(equalToConstant: 44).isActive = true
        routeNumberLabel.activateConstraintsToFitIntoSuperview(attributes: [.top, .bottom, .leading])
    }
    
    func setupStackView() {
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = 12
        stackView.layoutMargins = UIEdgeInsets(top: 18, left: 18, bottom: 18, right: 18)
        stackView.isLayoutMarginsRelativeArrangement = true
    }
    
    func setupSwitchControl() {
        switchControl.setLabelTexts(left: "양천공영차고지", right: "경인교육대학교")
    }
    
    func setupAppearance() {
        self.backgroundColor = UIColor(named: "Seoul Green")
        self.routeNumberLabel.textColor = .white
        self.routeNumberLabel.numberText = "6515"
    }
}
