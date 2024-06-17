//
//  TEToolExtension.swift
//  TEToolExtension
//
//  Created by wqqqq on 2024/6/17.
//
//
import Foundation
import UIKit
import SnapKit
import SwifterSwift
import DeviceKit

//MARK: UIKit
extension UIFont {
    static let FontName_PierSans = "PierSans"
    static let FontName_PierSans700 = "PierSans-Bold"
    static let FontName_PierSans900 = "PierSans-Bold"
    static let FontName_AvenirMedium = "Avenir-Medium"
    static let FontName_AvenirHeavy = "Avenir-Heavy"
    static let FontName_AvenirBlack = "Avenir-Black"
    static let FontName_NotoSansOriyaBold = "NotoSansOriya-Bold"
    
}

extension UIScreen {
    
    static func width() -> CGFloat {
        return self.main.bounds.size.width
    }
    
    static func height() -> CGFloat {
        return self.main.bounds.size.height
    }
    
    static func isDevice8SE() -> Bool {
        if Device.current.diagonal <= 4.7 {
            return true
        }
        return false
    }
    
    static func isDevice8SEPaid() -> Bool {
        if Device.current.diagonal <= 4.7 || Device.current.diagonal >= 7.0 {
            return true
        }
        return false
    }
    
    static func isDevice8Plus() -> Bool {
        if Device.current.diagonal == 5.5 {
            return true
        }
        return false
    }
}

public extension UIView {
    
    @discardableResult
    public func adhere(toSuperview superview: UIView, _ closure: (_ make: ConstraintMaker) -> Void) -> Self {
        superview.addSubview(self)
        self.snp.makeConstraints(closure)
        return self
    }
    
    @discardableResult
    func shadow (
        color: UIColor?,
        radius: CGFloat? = nil,
        opacity: Float? = nil,
        offset: CGSize? = nil,
        path: CGPath? = nil
    ) -> Self {
        layer.shadowColor = color?.cgColor
        
        if let radius = radius {
            layer.shadowRadius = radius
        }
        
        if let opacity = opacity {
            layer.shadowOpacity = opacity
        }
        
        if let offset = offset {
            layer.shadowOffset = offset
        }
        
        if let path = path {
            layer.shadowPath = path
        }
        
        return self
    }
    
    @discardableResult
    func crop() -> Self {
        contentMode()
        clipsToBounds()
        return self
    }

    @discardableResult
    func cornerRadius(_ value: CGFloat, masksToBounds: Bool = true) -> Self {
        layer.cornerRadius = value
        layer.masksToBounds = masksToBounds
        return self
    }

    @discardableResult
    func borderColor(_ value: UIColor, width: CGFloat = 1) -> Self {
        layer.borderColor = value.cgColor
        layer.borderWidth = width
        return self
    }

    @discardableResult
    func contentMode(_ value: UIView.ContentMode = .scaleAspectFill) -> Self {
        contentMode = value
        return self
    }

    @discardableResult
    func clipsToBounds(_ value: Bool = true) -> Self {
        clipsToBounds = value
        return self
    }

    @discardableResult
    func tag(_ value: Int) -> Self {
        tag = value
        return self
    }

    @discardableResult
    func tintColor(_ value: UIColor) -> Self {
        tintColor = value
        return self
    }

    @discardableResult
    func backgroundColor(_ value: UIColor) -> Self {
        backgroundColor = value
        return self
    }
}


public extension UIImageView {
    @discardableResult
    func image(_ value: String?, _: Bool = false) -> Self {
        guard let value = value else { return self }
        image = UIImage(named: value)
        return self
    }
    
    @discardableResult
    func highlightedImage(_ value: String?, _: Bool = false) -> Self {
        guard let value = value else { return self }
        highlightedImage = UIImage(named: value)
        return self
    }
    
    @discardableResult
    func image(_ valueImg: UIImage?) -> Self {
        guard let valueImg = valueImg else { return self }
        image = valueImg
        return self
    }
    
    @discardableResult
    func isHighlighted(_ value: Bool = false) -> Self {
        isHighlighted = value
        return self
    }
}

extension UILabel {
    @discardableResult
    public func text(_ value: String?) -> Self {
        text = value
        return self
    }

    @discardableResult
    public func color(_ value: UIColor) -> Self {
        textColor = value
        return self
    }

    @discardableResult
    public func font(_ name: String, _ value: CGFloat) -> Self {
        font = UIFont(name: name, size: value) ?? UIFont.systemFont(ofSize: value)
        return self
    }

    @discardableResult
    public func numberOfLines(_ value: Int) -> Self {
        numberOfLines = value
        return self
    }

    @discardableResult
    public func textAlignment(_ value: NSTextAlignment) -> Self {
        textAlignment = value
        return self
    }

    @discardableResult
    public func lineBreakMode(_ value: NSLineBreakMode = .byTruncatingTail) -> Self {
        lineBreakMode = value
        return self
    }
    
    
    @discardableResult
    func adjustsFontSizeToFitWidth(_ value: Bool = true) -> Self {
        adjustsFontSizeToFitWidth = value
        return self
    }
    
    
}

extension UIButton {
    @discardableResult
    public func title(_ value: String?, _ state: UIControl.State = .normal) -> Self {
        setTitle(value, for: state)
        return self
    }

    @discardableResult
    public func titleColor(_ value: UIColor, _ state: UIControl.State = .normal) -> Self {
        setTitleColor(value, for: state)
        return self
    }

    @discardableResult
    public func image(_ value: UIImage?, _ state: UIControl.State = .normal) -> Self {
        setImage(value, for: state)
        return self
    }

    @discardableResult
    public func backgroundImage(_ value: UIImage?, _ state: UIControl.State = .normal) -> Self {
        setBackgroundImage(value, for: state)
        return self
    }

    @discardableResult
    public func backgroundColor(_ value: UIColor, size: CGSize, _ state: UIControl.State = .normal) -> Self {
        setBackgroundImage(UIImage(color: value, size: size), for: state)
        return self
    }
    
    @discardableResult
    public func font(_ name: String, _ value: CGFloat) -> Self {
        titleLabel?.font(name, value)
        return self
    }
    
    @discardableResult
    public func lineBreakMode(_ value: NSLineBreakMode = .byTruncatingTail) -> Self {
        titleLabel?.lineBreakMode(value)

        return self
    }
    
    @discardableResult
    public func target(target: Any?, action: Selector, event: UIControl.Event) -> Self {
        self.addTarget(target, action: action, for: event)
        return self
    }
    
    @discardableResult
    func isEnabled(_ value: Bool = false) -> Self {
        isEnabled = value
        return self
    }
    
    @discardableResult
    func isSelected(_ value: Bool = false) -> Self {
        isSelected = value
        return self
    }
    
    // 禁用按钮并设置超时时间
    func disable(for duration: TimeInterval) {
        self.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isEnabled = true
        }
    }
}

class DBDelayButton: UIButton {
    private var canTap = true

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if canTap {
            super.touchesBegan(touches, with: event)
            canTap = false
            perform(#selector(resetTap), with: nil, afterDelay: 0.15)
        }
    }

    @objc private func resetTap() {
        canTap = true
    }
}

public extension UITextField {
    /**
     Sets the textfield placeholder but in a chainable fashion
     - Returns: Itself for chaining purposes
     */
    @discardableResult
    func placeholder(_ t: String) -> Self {
        placeholder = t
        return self
    }
}

extension UIButton {
    struct Item {
        let title: String
        let icon: String
        let backgroundColor: UIColor
        let handler: () -> Void
    }
    
    private final class ButtonAdapter {
        private let handler: () -> Void
        let controlEvent: UIControl.Event

        init(handler: @escaping () -> Void, controlEvent: UIControl.Event) {
            self.handler = handler
            self.controlEvent = controlEvent
        }

        @objc
        func handle() {
            handler()
        }
    }

    private static var key: UInt8 = 0

    private var adapters: [ButtonAdapter] {
        get {
            objc_getAssociatedObject(self, &Self.key) as? [ButtonAdapter] ?? []
        }
        set {
            objc_setAssociatedObject(self, &Self.key, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }

    convenience init(buttonItem: Item) {
        self.init(frame: .zero)

        backgroundColor = buttonItem.backgroundColor
        setTitle(buttonItem.title, for: .normal)
        setImage(UIImage(named: buttonItem.icon), for: .normal)
        addEventHandler(handler: buttonItem.handler, controlEvent: .touchUpInside)
    }

    func addEventHandler(handler: @escaping () -> Void, controlEvent: UIControl.Event) {
        let adapter = ButtonAdapter(handler: handler, controlEvent: controlEvent)
        addTarget(adapter, action: #selector(ButtonAdapter.handle), for: controlEvent)
        adapters.append(adapter)
    }
}

extension UITextView {

    /// Resize the placeholder when the UITextView bounds change
    override open var bounds: CGRect {
        didSet {
//            self.resizePlaceholder()
        }
    }

    /// The UITextView placeholder text
    public var placeholder: String? {
        get {
            var placeholderText: String?

            if let placeholderLabel = self.viewWithTag(100) as? UILabel {
                placeholderText = placeholderLabel.text
            }

            return placeholderText
        }
        set {
            // swiftlint:disable:next force_cast
            if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
                placeholderLabel.text = newValue
                placeholderLabel.sizeToFit()
            } else {
                self.addPlaceholder(newValue!)
            }
        }
    }

    /// When the UITextView did change, show or hide the label based on if the UITextView is empty or not
    ///
    /// - Parameter textView: The UITextView that got updated
    
    /// Resize the placeholder UILabel to make sure it's in the same position as the UITextView text
    private func resizePlaceholder() {
        // swiftlint:disable:next force_cast
//        if let placeholderLabel = self.viewWithTag(100) as! UILabel? {
//
//            let labelWidth = self.frame.width - (labelX * 2)
//            let labelHeight = placeholderLabel.frame.height
//
//            placeholderLabel.frame = CGRect(x: labelX, y: labelY, width: labelWidth, height: labelHeight)
//        }
    }

    /// Adds a placeholder UILabel to this UITextView
    private func addPlaceholder(_ placeholderText: String) {
        let placeholderLabel = UILabel()

        placeholderLabel.text = placeholderText
        placeholderLabel.sizeToFit()

        placeholderLabel.font = self.font
        placeholderLabel.textColor = self.textColor?.withAlphaComponent(0.3)
        placeholderLabel.tag = 100
        placeholderLabel.numberOfLines = 0
        placeholderLabel.isHidden = !self.text.isEmpty

        self.addSubview(placeholderLabel)
//        self.resizePlaceholder()
        
        let labelX = self.textContainerInset.left + textContainer.lineFragmentPadding + 2
        let labelY = self.textContainerInset.top + 2
        placeholderLabel.snp.makeConstraints {
            $0.left.equalToSuperview().offset(labelX)
            $0.top.equalToSuperview().offset(labelY)
            $0.centerX.equalToSuperview()
            $0.bottom.lessThanOrEqualTo(self.snp.bottom).offset(-labelY)
        }
        
        setupTextViewNotification()
    }
    func setupTextViewNotification() {
        NotificationCenter.default.addObserver(self, selector: #selector(textViewNotifitionAction), name: UITextView.textDidChangeNotification, object: nil);
    }
    
    @objc
    func textViewNotifitionAction(userInfo:NSNotification){
        
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !self.text.isEmpty
        }
    }
}



//MARK: Foundation
extension Double {
   func roundTo(places:Int) -> Double {
       let divisor = pow(10.0, Double(places))
       return (self * divisor).rounded() / divisor

   }
}

public class Once {
    var already: Bool = false
    public init() {}
    public func run(_ block: () -> Void) {
        guard !already else {
            return
        }
        block()
        already = true
    }
}

extension UIView {
    /// 设置渐变颜色背景
    /// - Parameters:
    ///   - colors: 渐变颜色数组
    ///   - locations: 颜色位置数组，可选，默认为nil
    ///   - startPoint: 渐变开始点
    ///   - endPoint: 渐变结束点
    func applyGradient(colors: [UIColor], locations: [NSNumber]? = nil, startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.locations = locations
        gradientLayer.startPoint = startPoint
        gradientLayer.endPoint = endPoint
        gradientLayer.frame = self.bounds
        
        // 检查是否已经有渐变层，如果有则替换，否则添加
        if let gradient = self.layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
            gradient.colors = colors.map { $0.cgColor }
            gradient.locations = locations
            gradient.startPoint = startPoint
            gradient.endPoint = endPoint
        } else {
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}

