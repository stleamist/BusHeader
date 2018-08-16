import UIKit

@IBDesignable class NodeView: UIView {
    private let circleSize: CGFloat = 24
    private let strokeWidth: CGFloat = 4
    
    private var pathSize: CGFloat {
        return circleSize - strokeWidth
    }
    private var pathOffset: CGFloat {
        return strokeWidth / 2
    }
    private var defaultOrigin: CGPoint {
        let x = (bounds.width - circleSize) / 2
        let y = (bounds.height - circleSize) / 2
        return CGPoint(x: x, y: y)
    }
    
    public var nodeColors: [UIColor] = [] {
        didSet {
            updateNodeLayers()
        }
    }
    public var nodeLayers: [CAShapeLayer] = []
    public var nodeNumber: Int? {
        didSet {
            updateNumberLabel()
        }
    }
    public var nodeNumberLabel: UILabel?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        updateNodeLayers()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        updateNodeLayers()
    }
    
    convenience init(nodeColors: [UIColor]) {
        self.init()
        self.nodeColors = nodeColors
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateNodeLayers()
    }
    
    internal func updateNodeLayers() {
        for layer in nodeLayers {
            layer.removeFromSuperlayer()
        }
        nodeLayers.removeAll()
        
        nodeLayers = nodeColors.enumerated().map({ (index, color) -> CAShapeLayer in
            let circleLayer = CAShapeLayer()
            
            
            
            circleLayer.path = UIBezierPath(ovalIn: CGRect(x: pathOffset, y: pathOffset, width: pathSize, height: pathSize)).cgPath
            circleLayer.strokeColor = color.cgColor
            circleLayer.lineWidth = strokeWidth
            circleLayer.fillColor = UIColor.white.cgColor
            
            // offset은 nodeColors.count == 2일 때 8부터 시작하며, 최소 offset은 1이다.
            let offset: CGFloat = max(8 - CGFloat(nodeColors.count - 2), 1)
            
            // offsetFactor는 중앙을 기준으로 nodeColors.count가 홀수일 때는 ±0.5n씩, 짝수일 때는 ±1n씩 증가한다.
            let offsetFactor: CGFloat = CGFloat(index) - CGFloat(nodeColors.count - 1) * 0.5
            
            circleLayer.frame.origin.x = defaultOrigin.x + offset * offsetFactor
            circleLayer.frame.origin.y = defaultOrigin.y + offset * -offsetFactor
            
            self.layer.insertSublayer(circleLayer, at: 0)
            
            return circleLayer
            
            /*
             NOTE:
             nodeColors.count에 따른 offset:
             nodeColors.count == 2: 8
             nodeColors.count == 3: 7
             nodeColors.count == 4: 6
             nodeColors.count == 5: 5
             nodeColors.count == 6: 4
             nodeColors.count == 7: 3
             nodeColors.count == 8: 2
             nodeColors.count == 1: 9
             nodeColors.count에 따른 x 좌표:
             nodeColors.count == 1: (28 + 9 * 0)
             nodeColors.count == 2: (28 + 8 * -0.5), (28 + 8 * 0.5)
             nodeColors.count == 3: (28 + 7 * -1), (28 + 7 * 0), (28 + 7 * 1)
             nodeColors.count == 4: (28 + 6 * -1.5), (28 + 6 * -0.5), (28 + 6 * 0.5), (28 + 6 * 1.5)
             nodeColors.count == 5: (28 + 5 * -2), (28 + 5 * -1), (28 + 5 * 0), (28 + 5 * 1), (28 + 5 * 2)
             nodeColors.count == 6: (28 + 4 * -2.5), (28 + 4 * -1.5), (28 + 4 * -0.5), (28 + 4 * 0.5), (28 + 4 * 1.5), (28 + 4 * 2.5)
             */
        })
        
        updateNumberLabel()
    }
    
    internal func setupNumberLabel() {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 16, height: 16))
        label.font = UIFont.systemFont(ofSize: 12, weight: .bold)
        label.textAlignment = .center
        self.nodeNumberLabel = label
        self.addSubview(label)
    }
    
    internal func updateNumberLabel() {
        if (self.nodeNumberLabel == nil) {
            setupNumberLabel()
        }
        
        if let number = self.nodeNumber {
            self.nodeNumberLabel?.text = String(number)
        } else {
            self.nodeNumberLabel?.text = nil
        }
        
        self.nodeNumberLabel?.textColor = self.nodeColors.first ?? .black
        self.nodeNumberLabel?.isHidden = (self.nodeNumber == nil)
        
        self.nodeNumberLabel?.frame.origin.x = (self.nodeLayers.first?.frame.origin.x ?? self.defaultOrigin.x) + strokeWidth
        self.nodeNumberLabel?.frame.origin.y = (self.nodeLayers.first?.frame.origin.y ?? self.defaultOrigin.y) + strokeWidth
    }
    
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        
        self.nodeColors = [.black]
    }
}
