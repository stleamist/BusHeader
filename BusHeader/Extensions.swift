import UIKit

extension UIControl.State: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(rawValue)
    }
}

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

extension NSLayoutConstraint {
    func formPriority(_ priority: UILayoutPriority) -> Self {
        self.priority = priority
        return self
    }
}

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int, alpha: CGFloat = 1) {
        self.init(
            red: CGFloat(red) / 255,
            green: CGFloat(green) / 255,
            blue: CGFloat(blue) / 255,
            alpha: alpha
        )
    }
    
    convenience init(rgb: Int, alpha: CGFloat = 1) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF,
            alpha: alpha
        )
    }
}

extension UIView {
    var topCenterAnchor: NSLayoutYAxisAnchor {
        return self.squareLayoutGuide(attribute: .top).centerYAnchor
    }
    
    var bottomCenterAnchor: NSLayoutYAxisAnchor {
        return self.squareLayoutGuide(attribute: .bottom).centerYAnchor
    }
    
    var leadingCenterAnchor: NSLayoutXAxisAnchor {
        return self.squareLayoutGuide(attribute: .leading).centerXAnchor
    }
    
    var trailingCenterAnchor: NSLayoutXAxisAnchor {
        return self.squareLayoutGuide(attribute: .trailing).centerXAnchor
    }
    
    private func squareLayoutGuide(attribute: NSLayoutConstraint.Attribute) -> UILayoutGuide {
        // TODO: last가 가장 최근에 추가한 가이드인지 확인해야 함.
        let layoutGuide = self.layoutGuides.filter({ $0.identifier == squareLayoutGuideIdentifier(attribute: attribute) }).last
        
        // 기존 squareLayoutGuide가 없으면 새로 가이드를 만든다.
        guard let existingSquareLayoutGuide = layoutGuide else {
            return newAddedSquareLayoutGuide(attribute: attribute)
        }
        
        return existingSquareLayoutGuide
    }
    
    private func newAddedSquareLayoutGuide(attribute: NSLayoutConstraint.Attribute) -> UILayoutGuide {
        let layoutGuide = UILayoutGuide()
        
        layoutGuide.identifier = squareLayoutGuideIdentifier(attribute: attribute)
        
        var constraintsDict: [NSLayoutConstraint.Attribute: NSLayoutConstraint] = [
            .top: layoutGuide.topAnchor.constraint(equalTo: self.topAnchor),
            .bottom: layoutGuide.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            .leading: layoutGuide.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            .trailing: layoutGuide.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            .width: layoutGuide.widthAnchor.constraint(equalTo: self.heightAnchor),
            .height: layoutGuide.heightAnchor.constraint(equalTo: self.widthAnchor)
        ]
        
        switch attribute {
        case .top:
            constraintsDict.removeValue(forKey: .bottom)
            constraintsDict.removeValue(forKey: .width)
        case .bottom:
            constraintsDict.removeValue(forKey: .top)
            constraintsDict.removeValue(forKey: .width)
        case .leading:
            constraintsDict.removeValue(forKey: .trailing)
            constraintsDict.removeValue(forKey: .height)
        case .trailing:
            constraintsDict.removeValue(forKey: .leading)
            constraintsDict.removeValue(forKey: .height)
        default: ()
        }
        
        let constraintsArray = Array(constraintsDict.values)
        
        self.addLayoutGuide(layoutGuide)
        NSLayoutConstraint.activate(constraintsArray)
        
        return layoutGuide
    }
    
    private func squareLayoutGuideIdentifier(attribute: NSLayoutConstraint.Attribute) -> String {
        return "squareLayoutGuide\(attribute.rawValue)"
    }
}
