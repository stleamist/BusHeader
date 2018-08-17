import UIKit

class StopInfoLabels: UIView {
    let contentStackView = UIStackView()
    
    let textLabelsStackView = UIStackView()
    let detailLabelsStackView = UIStackView()
    
    var contentStackViewSubviews: [UIStackView] {
        return [textLabelsStackView, detailLabelsStackView]
    }
    
    var allLabels: [UILabel] { return textLabels + detailTextLabels }
    var textLabels: [UILabel] { return [stopNameLabel] }
    var detailTextLabels: [UILabel] { return [nextStopNameLabel, dotLabel, stopIDLabel] }
    
    var stopNameLabel: UILabel = UILabel()
    var nextStopNameLabel: UILabel = UILabel()
    var dotLabel: UILabel = UILabel()
    var stopIDLabel: UILabel = UILabel()
    
    var labelClass: UILabel.Type = UILabel.self {
        didSet {
            setupLabels()
        }
    }
    
    var stopNameText: String = "" {
        didSet { updateLabelTexts() }
    }
    var nextStopNameText: String = "" {
        didSet { updateLabelTexts() }
    }
    let dotText: String = " · "
    var stopIDText: String = "" {
        didSet { updateLabelTexts() }
    }
    
    var textColor: UIColor = .black {
        didSet { updateLabelColors() }
    }
    var detailTextColor: UIColor = .black {
        didSet { updateLabelColors() }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    init(labelClass: UILabel.Type) {
        super.init(frame: .zero)
        self.labelClass = labelClass
        setup()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        // 라벨들이 강제 옵셔널 해제 상태이기 때문에 라벨을 먼저 설정해야 한다.
        setupLabels()
        setupContentStackView()
    }
    
    func setupLabels() {
        setupLabel(&stopNameLabel, text: stopNameText, textColor: textColor)
        setupLabel(&nextStopNameLabel, text: nextStopNameText, textColor: detailTextColor)
        setupLabel(&dotLabel, text: dotText, textColor: detailTextColor)
        setupLabel(&stopIDLabel, text: stopIDText, textColor: detailTextColor)
        
        rearrangeStackView(textLabelsStackView, subviews: textLabels)
        rearrangeStackView(detailLabelsStackView, subviews: detailTextLabels)
    }
    
    func setupContentStackView() {
        self.addSubview(contentStackView)
        contentStackViewSubviews.forEach({ contentStackView.addArrangedSubview($0) })
        
        contentStackView.axis = .vertical
        contentStackViewSubviews.forEach({ $0.axis = .horizontal })
        
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        contentStackView.constraintsToFitIntoSuperview().forEach { (_, constraint) in
            // FIXME: 적절한 Priority 찾기
            // .required로 설정하면 StopHeaderView 사이즈 모드 변경 애니메이션에서 detailLabelsStackView가 위에서 아래로 내려오는 문제가 있다.
            constraint.priority = .fittingSizeLevel
            constraint.isActive = true
        }
    }
    
    func rearrangeStackView(_ stackView: UIStackView, subviews: [UIView]) {
        stackView.arrangedSubviews.forEach({ $0.removeFromSuperview() })
        subviews.forEach({ stackView.addArrangedSubview($0) })
    }
    
    func setupLabel(_ label: inout UILabel, text: String, textColor: UIColor) {
        label = labelClass.init()
        label.text = text
        label.textColor = textColor
    }
    
    func updateLabelTexts() {
        stopNameLabel.text = stopNameText
        nextStopNameLabel.text = nextStopNameText
        dotLabel.text = dotText
        stopIDLabel.text = stopIDText
    }
    
    func updateLabelColors() {
        textLabels.forEach({ $0.textColor = textColor })
        detailTextLabels.forEach({ $0.textColor = textColor })
    }
}

class Label: UILabel {}
