import UIKit

@IBDesignable class RouteNumberLabel: UIView {
    // MARK: Properties
    var districtLabel: UILabel!
    var numberLabel: UILabel!
    var suffixLabel: UILabel!
    
    var horizontalStackView: UIStackView!
    var verticalStackView: UIStackView!
    
    internal var labels: [UILabel] {
        return [districtLabel, numberLabel, suffixLabel]
    }
    
    
    // MARK: IBInspectables
    var textColor: UIColor = .black {
        didSet {
            setupLabels()
        }
    }
    
    var districtText: String? {
        didSet {
            setupLabels()
        }
    }
    
    var numberText: String? = "0000" {
        didSet {
            setupLabels()
        }
    }
    
    var suffixText: String? {
        didSet {
            setupLabels()
        }
    }
    
    
    // MARK: Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    
    // MARK: Private Methods
    private func setupView() {
        districtLabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 20, weight: .medium)
            return label
        }()
        
        numberLabel = {
            let label = UILabel()
            label.font = UIFont(name: "AvenirNext-DemiBold", size: 30)
            return label
        }()
        
        suffixLabel = {
            let label = UILabel()
            label.font = UIFont.systemFont(ofSize: 25, weight: .bold)
            return label
        }()
        
        horizontalStackView = {
            let stackView = UIStackView(arrangedSubviews: [numberLabel, suffixLabel])
            stackView.axis = .horizontal
            stackView.alignment = .center
            stackView.spacing = 0
            return stackView
        }()
        
        verticalStackView = {
            let stackView = UIStackView(arrangedSubviews: [districtLabel, horizontalStackView])
            stackView.axis = .vertical
            stackView.alignment = .leading
            stackView.spacing = 0
            return stackView
        }()
        
        self.addSubview(verticalStackView)
        verticalStackView.translatesAutoresizingMaskIntoConstraints = false
        verticalStackView.activateConstraintsToFitIntoSuperview()
        
        setupLabels()
    }
    
    private func setupLabels() {
        
        districtLabel.text = districtText
        numberLabel.text = numberText
        suffixLabel.text = suffixText
        
        for label in labels {
            label.textColor = textColor
            label.isHidden = (label.text == nil ? true : false)
        }
        
        if let count = numberText?.count {
            let fontName = (count <= 4 ? "AvenirNext-DemiBold" : "AvenirNextCondensed-DemiBold")
            if let font = UIFont(name: fontName, size: numberLabel.font.pointSize) {
                numberLabel.font = font
            }
        }
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: 83, height: 50)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return CGSize(width: 83, height: 50)
    }

}
