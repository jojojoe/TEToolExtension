//
//  TEToolExtension.swift
//  TEToolExtension
//
//  Created by wqqqq on 2024/6/17.
//
//

import Foundation
import UIKit
import Hero
import SnapKit
import SwifterSwift
import DeviceKit
import CommonCrypto
import CoreImage

/// Users/zh/Library/Developer/Xcode/UserData/CodeSnippets


//MARK: UIKit
extension UIFont {
    public static let FontName_PierSans = "PierSans"
    public static let FontName_PierSans700 = "PierSans-Bold"
    public static let FontName_PierSans900 = "PierSans-Bold"
    public static let FontName_AvenirMedium = "Avenir-Medium"
    public static let FontName_AvenirHeavy = "Avenir-Heavy"
    public static let FontName_AvenirBlack = "Avenir-Black"
    public static let FontName_NotoSansOriyaBold = "NotoSansOriya-Bold"
    
}



extension UIScreen {
    
    public static func width() -> CGFloat {
        return self.main.bounds.size.width
    }
    
    public static func height() -> CGFloat {
        return self.main.bounds.size.height
    }
    
    public static func isDevice8SE() -> Bool {
        if Device.current.diagonal <= 4.7 {
            return true
        }
        return false
    }
    
    public static func isDevice8SEPaid() -> Bool {
        if Device.current.diagonal <= 4.7 || Device.current.diagonal >= 7.0 {
            return true
        }
        return false
    }
    
    public static func isDevice8Plus() -> Bool {
        if Device.current.diagonal == 5.5 {
            return true
        }
        return false
    }
    
    public static func isDevice8PlusAnd8SEPaid() -> Bool {
        if Device.current.diagonal == 5.5 || Device.current.diagonal <= 4.7 || Device.current.diagonal >= 7.0 {
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
    public func shadow (
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
    public func crop() -> Self {
        contentMode()
        clipsToBounds()
        return self
    }

    @discardableResult
    public func cornerRadius(_ value: CGFloat, masksToBounds: Bool = true) -> Self {
        layer.cornerRadius = value
        layer.masksToBounds = masksToBounds
        return self
    }
    
    @discardableResult
    public func isUserInteractionEnabled(_ value: Bool) -> Self {
        isUserInteractionEnabled = value
        return self
    }
    
    
    @discardableResult
    public func borderColor(_ value: UIColor, width: CGFloat = 1) -> Self {
        layer.borderColor = value.cgColor
        layer.borderWidth = width
        return self
    }

    @discardableResult
    public func contentMode(_ value: UIView.ContentMode = .scaleAspectFill) -> Self {
        contentMode = value
        return self
    }

    @discardableResult
    public func clipsToBounds(_ value: Bool = true) -> Self {
        clipsToBounds = value
        return self
    }

    @discardableResult
    public func tag(_ value: Int) -> Self {
        tag = value
        return self
    }

    @discardableResult
    public func tintColor(_ value: UIColor) -> Self {
        tintColor = value
        return self
    }

    @discardableResult
    public func backgroundColor(_ value: UIColor) -> Self {
        backgroundColor = value
        return self
    }
    
    @discardableResult
    public func backgroundColor(_ hexvalue: String) -> Self {
        backgroundColor = UIColor(hexString: hexvalue) ?? .white
        return self
    }
    
    @discardableResult
    public func alpha(_ value: CGFloat) -> Self {
        alpha = value
        return self
    }
    
}


public extension UIImageView {
    @discardableResult
    public func image(_ value: String?, _: Bool = false) -> Self {
        guard let value = value else { return self }
        image = UIImage(named: value)
        return self
    }
    
    @discardableResult
    public func highlightedImage(_ value: String?, _: Bool = false) -> Self {
        guard let value = value else { return self }
        highlightedImage = UIImage(named: value)
        return self
    }
    
    @discardableResult
    public func image(_ valueImg: UIImage?) -> Self {
        guard let valueImg = valueImg else { return self }
        image = valueImg
        return self
    }
    
    @discardableResult
    public func isHighlighted(_ value: Bool = false) -> Self {
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
    public func attributedText(_ value: NSMutableAttributedString?) -> Self {
        attributedText = value
        return self
    }
    
    
    @discardableResult
    public func color(_ value: UIColor) -> Self {
        textColor = value
        return self
    }
    
    @discardableResult
    public func color(_ hexValue: String) -> Self {
        textColor = UIColor(hexString: hexValue)
        return self
    }

    
    @discardableResult
    public func highlightedTextColor(_ value: UIColor) -> Self {
        highlightedTextColor = value
        return self
    }
    
    
    @discardableResult
    public func highlightedTextColor(_ hexValue: String) -> Self {
        highlightedTextColor = UIColor(hexString: hexValue)
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
    public func adjustsFontSizeToFitWidth(_ value: Bool = true) -> Self {
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
    public func titleColor(_ hexvalue: String, _ state: UIControl.State = .normal) -> Self {
        setTitleColor(UIColor(hexString: hexvalue) ?? .white, for: state)
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
    public func isEnabled(_ value: Bool = false) -> Self {
        isEnabled = value
        return self
    }
    
    @discardableResult
    public func isSelected(_ value: Bool = false) -> Self {
        isSelected = value
        return self
    }
    
    // 禁用按钮并设置超时时间
    public func disable(for duration: TimeInterval) {
        self.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            self.isEnabled = true
        }
    }
}
public extension UIButton {
    
    /**
     Sets the title of the button for normal State
     
     Essentially a shortcut for `setTitle("MyText", forState: .Normal)`
     
     - Returns: Itself for chaining purposes
    */
    @discardableResult
    func text(_ t: String) -> Self {
        setTitle(t, for: .normal)
        return self
    }
    
    /**
     Sets the localized key for the button's title in normal State
     
     Essentially a shortcut for `setTitle(NSLocalizedString("MyText", comment: "")
     , forState: .Normal)`
     
     - Returns: Itself for chaining purposes
     */
    @discardableResult
    func textKey(_ t: String) -> Self {
        text(NSLocalizedString(t, comment: ""))
        return self
    }
    
    /**
     Sets the image of the button in normal State
     
     Essentially a shortcut for `setImage(UIImage(named:"X"), forState: .Normal)`
     
     - Returns: Itself for chaining purposes
     */
    @discardableResult
    func image(_ s: String) -> Self {
        setImage(UIImage(named: s), for: .normal)
        return self
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
    public func placeholder(_ t: String) -> Self {
        placeholder = t
        return self
    }
    
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
    public func color(_ hexValue: String) -> Self {
        textColor = UIColor(hexString: hexValue)
        return self
    }

    @discardableResult
    public func font(_ name: String, _ value: CGFloat) -> Self {
        font = UIFont(name: name, size: value) ?? UIFont.systemFont(ofSize: value)
        return self
    }
    
    @discardableResult
    public func textAlignment(_ value: NSTextAlignment) -> Self {
        textAlignment = value
        return self
    }
    
    @discardableResult
    public func delegate(_ value: Any) -> Self {
        delegate = value as! any UITextFieldDelegate
        return self
    }
    
    @discardableResult
    public func returnKeyType(_ value: UIReturnKeyType) -> Self {
        returnKeyType = value
        return self
    }
    
}

extension UIButton {
    public struct Item {
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

    public convenience init(buttonItem: Item) {
        self.init(frame: .zero)

        backgroundColor = buttonItem.backgroundColor
        setTitle(buttonItem.title, for: .normal)
        setImage(UIImage(named: buttonItem.icon), for: .normal)
        addEventHandler(handler: buttonItem.handler, controlEvent: .touchUpInside)
    }

    public func addEventHandler(handler: @escaping () -> Void, controlEvent: UIControl.Event) {
        let adapter = ButtonAdapter(handler: handler, controlEvent: controlEvent)
        addTarget(adapter, action: #selector(ButtonAdapter.handle), for: controlEvent)
        adapters.append(adapter)
    }
}

extension UITextView {
 
    
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
    public func color(_ hexValue: String) -> Self {
        textColor = UIColor(hexString: hexValue)
        return self
    }

    @discardableResult
    public func font(_ name: String, _ value: CGFloat) -> Self {
        font = UIFont(name: name, size: value) ?? UIFont.systemFont(ofSize: value)
        return self
    }
    
    @discardableResult
    public func textAlignment(_ value: NSTextAlignment) -> Self {
        textAlignment = value
        return self
    }
    
    @discardableResult
    public func delegate(_ value: Any) -> Self {
        delegate = value as! any UITextViewDelegate
        return self
    }
    
    @discardableResult
    public func returnKeyType(_ value: UIReturnKeyType) -> Self {
        returnKeyType = value
        return self
    }
    
    @discardableResult
    public func placeholder(_ value: String) -> Self {
        placeholder = value
        return self
    }
    
    //
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
        let labelY = self.textContainerInset.top + 0.5
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
        checkPlachholderShowStatus()
    }
    
    func checkPlachholderShowStatus() {
        if let placeholderLabel = self.viewWithTag(100) as? UILabel {
            placeholderLabel.isHidden = !self.text.isEmpty
        }
    }
}


extension UIView {
    /// 设置渐变颜色背景
    /// - Parameters:
    ///   - colors: 渐变颜色数组
    ///   - locations: 颜色位置数组，可选，默认为nil
    ///   - startPoint: 渐变开始点
    ///   - endPoint: 渐变结束点
    public func applyGradient(colors: [UIColor], locations: [NSNumber]? = nil, startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0), endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0)) {
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

extension UIImage {
    /// Fix image orientaton to protrait up
    func fixedOrientation() -> UIImage? {
        guard imageOrientation != UIImage.Orientation.up else {
            // This is default orientation, don't need to do anything
            return self.copy() as? UIImage
        }

        guard let cgImage = self.cgImage else {
            // CGImage is not available
            return nil
        }

        guard let colorSpace = cgImage.colorSpace, let ctx = CGContext(data: nil, width: Int(size.width), height: Int(size.height), bitsPerComponent: cgImage.bitsPerComponent, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else {
            return nil // Not able to create CGContext
        }

        var transform: CGAffineTransform = CGAffineTransform.identity

        switch imageOrientation {
        case .down, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: size.height)
            transform = transform.rotated(by: CGFloat.pi)
        case .left, .leftMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.rotated(by: CGFloat.pi / 2.0)
        case .right, .rightMirrored:
            transform = transform.translatedBy(x: 0, y: size.height)
            transform = transform.rotated(by: CGFloat.pi / -2.0)
        case .up, .upMirrored:
            break
        @unknown default:
            fatalError("Missing...")
            break
        }

        // Flip image one more time if needed to, this is to prevent flipped image
        switch imageOrientation {
        case .upMirrored, .downMirrored:
            transform = transform.translatedBy(x: size.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, .rightMirrored:
            transform = transform.translatedBy(x: size.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .up, .down, .left, .right:
            break
        @unknown default:
            fatalError("Missing...")
            break
        }

        ctx.concatenate(transform)

        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            break
        }

        guard let newCGImage = ctx.makeImage() else { return nil }
        return UIImage.init(cgImage: newCGImage, scale: 1, orientation: .up)
    }
    
}

extension UIImage {
    func resizeAndCropImage(targetSize: CGSize, contentAlignment: NSTextAlignment = .center) -> UIImage {
        // c = center  l = leading t = trailing
        let originalWidth = self.size.width
        let originalHeight = self.size.height
        let targetWidth = targetSize.width
        let targetHeight = targetSize.height

        // 1. 计算缩放比例
        let scale = max(targetWidth / originalWidth, targetHeight / originalHeight)

        // 2. 计算新的图片尺寸
        let newWidth = originalWidth * scale
        let newHeight = originalHeight * scale

        // 3. 创建新的图像上下文
        UIGraphicsBeginImageContextWithOptions(targetSize, false, UIScreen.mainScreenScale)

        // 4. 绘制缩放后的图片到新的图像上下文
        var xoffset: CGFloat = 0
        var yoffset: CGFloat = 0
        if contentAlignment == .center {
            xoffset = (targetWidth - newWidth) / 2
            yoffset = (targetHeight - newHeight) / 2
        } else if contentAlignment == .left {
            xoffset = 0
            yoffset = 0
        } else if contentAlignment == .right {
            xoffset = (targetWidth - newWidth)
            yoffset = (targetHeight - newHeight)
        }
        self.draw(in: CGRect(x: xoffset, y: yoffset, width: newWidth, height: newHeight))

        // 5. 从图像上下文中获取新的图片
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()

        // 6. 关闭图像上下文
        UIGraphicsEndImageContext()

        return resizedImage ?? self // 返回裁剪后的图片或原始图片
    }
}

extension UIImage {
    // 图片边缘也会被模糊
    func applyGaussianBlur(withBlurLevel blur: Double) -> UIImage? {
        // 创建CIImage
        guard let ciInputImage = CIImage(image: self) else { return nil }

        // 创建高斯模糊核心图像滤镜
        guard let blurFilter = CIFilter(name: "CIGaussianBlur") else { return nil }
        
        // 设置滤镜的输入图像
        blurFilter.setValue(ciInputImage, forKey: kCIInputImageKey)
        
        // 设置模糊半径
        blurFilter.setValue(blur, forKey: kCIInputRadiusKey)
        
        // 获取滤镜输出图像
        guard let outputImage = blurFilter.outputImage else { return nil }
        
        // 创建一个CIContext
        let context = CIContext(options: nil)
        
        // 将CIImage转换为CGImage
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        
        // 将CGImage转换为UIImage
        let blurredImage = UIImage(cgImage: cgImage)
        
        return blurredImage
    }
    
    // 图片边缘 不会被模糊
    func gaussianBlur(radius: CGFloat) -> UIImage? {
        // 1. 将 UIImage 转换为 CIImage
        guard let ciImage = CIImage(image: self) else { return nil }

        // 2. 使用 CIAffineClamp 滤镜对 CIImage 进行扩展
        let affineClampFilter = CIFilter(name: "CIAffineClamp")!
        affineClampFilter.setValue(ciImage, forKey: kCIInputImageKey)
        guard let clampedImage = affineClampFilter.outputImage else { return nil }

        // 3. 使用 CIGaussianBlur 滤镜对扩展后的 CIImage 进行高斯模糊
        let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")!
        gaussianBlurFilter.setValue(clampedImage, forKey: kCIInputImageKey)
        gaussianBlurFilter.setValue(radius, forKey: kCIInputRadiusKey)
        guard let blurredImage = gaussianBlurFilter.outputImage else { return nil }

        // 4. 将模糊后的 CIImage 转换为 UIImage
        let ciContext = CIContext()
        guard let cgImage = ciContext.createCGImage(blurredImage, from: ciImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }

}

public extension UIView {
    
    struct CustomLoadingViewConstants {
        static let Tag = 10001
    }

    func customShowLoading(loadingImgName: String, sizeWidth: CGFloat, duration: Double = 1) {

        if self.viewWithTag(CustomLoadingViewConstants.Tag) != nil {
            // If loading view is already found in current view hierachy, do nothing
            return
        }
        
        let loadingImgV = UIImageView(image: UIImage(named: loadingImgName))
        loadingImgV.bounds = CGRect(origin: CGPoint(x: 0, y: 0), size: CGSize(width: sizeWidth, height: sizeWidth))
        loadingImgV.center = CGPoint(x: self.bounds.size.width / 2, y: self.bounds.size.height / 2)
        self.addSubview(loadingImgV)
        //
        let animation = CABasicAnimation()
        animation.keyPath = "transform.rotation.z"
        animation.fromValue = degreesToRadians(degrees: 0)
        animation.toValue = degreesToRadians(degrees: 360)
        animation.duration = duration
        animation.repeatCount = HUGE
        //
        loadingImgV.layer.add(animation, forKey: "")
        loadingImgV.tag = CustomLoadingViewConstants.Tag
        
        loadingImgV.alpha = 1
         
    }

    func customHideLoading() {

        if let indicatorView = self.viewWithTag(CustomLoadingViewConstants.Tag) {
            indicatorView.alpha = 1
            UIView.animate(withDuration: 0.3) {
                indicatorView.alpha = 0
                indicatorView.transform = CGAffineTransform(scaleX: 0.3, y: 0.3)
            } completion: { completed in
                indicatorView.removeFromSuperview()
            }

             
        }
    }
    func degreesToRadians(degrees: CGFloat) -> CGFloat {
        return degrees * CGFloat(CGFloat.pi / 180)
    }
}


extension UIViewController {
    struct AlertItem {
        let btnName: String
        var handler: ((UIAlertAction) -> Void)? = nil
    }
    func showAlert(title: String, message: String, btnActions: [AlertItem]) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        if btnActions.count == 1 {
            let item = btnActions[0]
            let button = UIAlertAction(title: item.btnName, style: .cancel, handler: item.handler)
            alert.addAction(button)
        } else if btnActions.count == 2 {
            let item1 = btnActions[0]
            let button1 = UIAlertAction(title: item1.btnName, style: .cancel, handler: item1.handler)
            alert.addAction(button1)
            //
            let item2 = btnActions[1]
            let button2 = UIAlertAction(title: item2.btnName, style: .default, handler: item2.handler)
            alert.addAction(button2)
        }
        
        self.present(alert, animated: true, completion: nil)
    }
    
    func showFrom(leaderVC: UIViewController, animaType: HeroDefaultAnimationType, isAnimation: Bool = true) {
        self.isHeroEnabled = true
        leaderVC.navigationController?.isHeroEnabled = true
        leaderVC.navigationController?.heroNavigationAnimationType = animaType
        leaderVC.navigationController?.pushViewController(self, animated: isAnimation)
    }
    
    func popVC(animaType: HeroDefaultAnimationType) {
        self.navigationController?.heroNavigationAnimationType = animaType
        self.navigationController?.popViewController(animated: true)
    }
    
}


class GLLinkLabel: UIView, UITextViewDelegate {

    var contentText: String
    let textV = UITextView()
    
    init(frame: CGRect, contentText: String, font: UIFont, alignment: NSTextAlignment = .left, textColor: UIColor, linkColor: UIColor) {
        self.contentText = contentText
        super.init(frame: frame)
        self.backgroundColor(.clear)
        let para = NSMutableParagraphStyle()
        para.alignment = alignment
        let attributedText = NSMutableAttributedString(string: contentText, attributes: [.foregroundColor : textColor, .font : font, .paragraphStyle : para])
        textV.backgroundColor(.clear)
        textV.attributedText = attributedText
        textV.delegate = self
        textV.isEditable = false
        textV.linkTextAttributes = [.foregroundColor : linkColor]
        textV.adhere(toSuperview: self) {
            $0.edges.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addLink(linkName: String, linkStr: String, hasUndleLine: Bool = true) {
        
        if let range = contentText.range(of: linkName, options: .caseInsensitive) {
            let nsRange = NSRange(range, in: contentText)
            let attribute = NSMutableAttributedString(attributedString: textV.attributedText)
            attribute.addAttribute(.link, value: linkStr, range: nsRange)
            if hasUndleLine {
                attribute.addAttributes([.underlineStyle : 1], range: nsRange)
            }
            textV.attributedText = attribute
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        debugPrint("shouldInteractWith - \(URL)")
        
        return true
    }
    
}

extension NSObject {
    func goSystemSetting() {
        let url = URL(string: UIApplication.openSettingsURLString)!
        UIApplication.shared.open(url, options: [:])
    }
}

extension Array {

    func item(before index: Int) -> Element? {
        if index < 1 {
            return nil
        }

        if index > count {
            return nil
        }

        return self[index - 1]
    }

    func item(after index: Int) -> Element? {
        if index < -1 {
            return nil
        }

        if index <= count - 2 {
            return self[index + 1]
        }

        return nil
    }
}

class DelayedTaskManager {
    private var task: DispatchWorkItem?
    private var delayInSeconds: Double

    init(delayInSeconds: Double, performTask: @escaping () -> Void) {
        self.delayInSeconds = delayInSeconds
        // 创建一个 DispatchWorkItem 来包装任务
        task = DispatchWorkItem(block: performTask)

        // 在指定的延时时间后执行任务
        DispatchQueue.main.asyncAfter(deadline: .now() + delayInSeconds) { [weak self] in
            self?.task?.perform()
        }
    }

    
    func cancelTask() {
        // 取消已经安排的任务
        task?.cancel()
        task = nil
    }
}

//MARK: Foundation

extension String {
    func pushNotification() {
        NotificationCenter.default.post(
            name: NSNotification.Name(rawValue: self),
            object: nil,
            userInfo: nil)
    }
}

extension String {
    func hmac(by algorithm: Algorithm, key: [UInt8]) -> [UInt8] {
        var result = [UInt8](repeating: 0, count: algorithm.digestLength())
        CCHmac(algorithm.algorithm(), key, key.count, self.bytes, self.bytes.count, &result)
        return result
    }
    
    func hashHex(by algorithm: Algorithm) -> String {
        return algorithm.hash(string: self).hexString
    }
    
     func hash(by algorithm: Algorithm) -> [UInt8] {
        return algorithm.hash(string: self)
     }
}


enum Algorithm {
    case MD5, SHA1, SHA224, SHA256, SHA384, SHA512
    
    func algorithm() -> CCHmacAlgorithm {
        var result: Int = 0
        switch self {
        case .MD5:    result = kCCHmacAlgMD5
        case .SHA1:   result = kCCHmacAlgSHA1
        case .SHA224: result = kCCHmacAlgSHA224
        case .SHA256: result = kCCHmacAlgSHA256
        case .SHA384: result = kCCHmacAlgSHA384
        case .SHA512: result = kCCHmacAlgSHA512
        }
        return CCHmacAlgorithm(result)
    }
    
    func digestLength() -> Int {
        var result: CInt = 0
        switch self {
        case .MD5:    result = CC_MD5_DIGEST_LENGTH
        case .SHA1:   result = CC_SHA1_DIGEST_LENGTH
        case .SHA224: result = CC_SHA224_DIGEST_LENGTH
        case .SHA256: result = CC_SHA256_DIGEST_LENGTH
        case .SHA384: result = CC_SHA384_DIGEST_LENGTH
        case .SHA512: result = CC_SHA512_DIGEST_LENGTH
        }
        return Int(result)
    }
    
    func hash(string: String) -> [UInt8] {
        var hash = [UInt8](repeating: 0, count: self.digestLength())
        switch self {
        case .MD5:    CC_MD5(   string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA1:   CC_SHA1(  string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA224: CC_SHA224(string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA256: CC_SHA256(string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA384: CC_SHA384(string.bytes, CC_LONG(string.bytes.count), &hash)
        case .SHA512: CC_SHA512(string.bytes, CC_LONG(string.bytes.count), &hash)
        }
        return hash
    }
}

extension Array where Element == UInt8 {
    var hexString: String {
        return self.reduce(""){$0 + String(format: "%02x", $1)}
    }
    
    var base64String: String {
        return self.data.base64EncodedString(options: Data.Base64EncodingOptions.lineLength76Characters)
    }
    
    var data: Data {
        return Data(self)
    }
}

extension String {
    var bytes: [UInt8] {
        return [UInt8](self.utf8)
    }
}

extension Data {
    var bytes: [UInt8] {
        return [UInt8](self)
    }
}


extension Double {
   public func roundTo(places:Int) -> Double {
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

extension Double {
    func rounded(digits: Int) -> Double {
        let multiplier = pow(10.0, Double(digits))
        return (self * multiplier).rounded() / multiplier
    }
    
    func accuracyToString(position: Int) -> String {
        
        let roundingBehavior = NSDecimalNumberHandler(roundingMode: .plain, scale: Int16(position), raiseOnExactness: false, raiseOnOverflow: false, raiseOnUnderflow: false, raiseOnDivideByZero: true)
        let ouncesDecimal: NSDecimalNumber = NSDecimalNumber(value: self)
        let roundedOunces: NSDecimalNumber = ouncesDecimal.rounding(accordingToBehavior: roundingBehavior)
        var formatterString : String = "0."
        if position > 0 {
            for _ in 0 ..< position {
                formatterString.append("0")
            }
        }else {
            formatterString = "0"
        }
        let formatter : NumberFormatter = NumberFormatter()
        formatter.positiveFormat = formatterString
        var roundingStr = formatter.string(from: roundedOunces) ?? "0.00"
        if roundingStr.range(of: ".") != nil {
            let sub1 = String(roundingStr.suffix(1))
            if sub1 == "0" {
                roundingStr = String(roundingStr.prefix(roundingStr.count-1))
                let sub2 = String(roundingStr.suffix(1))
                if sub2 == "0" {
                    roundingStr = String(roundingStr.prefix(roundingStr.count-2))
                }
            }
        }
        
        return roundingStr
    }
    
}

extension Float {
   var bytes: [UInt8] {
       withUnsafeBytes(of: self, Array.init)
   }
}

extension Date {
    func unixTimestampString() -> String {
        let timestamp = self.unixTimestamp
        let fileName = CLongLong(round(timestamp*1000)).string
        return fileName
    }
}
 
extension NSObject {
    func topMostViewController(base: UIViewController? = UIApplication.shared.windows.filter {$0.isKeyWindow}.first?.rootViewController) -> UIViewController? {
        if let nav = base as? UINavigationController {
            return topMostViewController(base: nav.visibleViewController)
        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return topMostViewController(base: selected)
        } else if let presented = base?.presentedViewController {
            return topMostViewController(base: presented)
        } else {
            return base
        }
    }
}

extension String {
    func animatedGIFToImages() -> [UIImage] {
        do {
            let gifData = try Data(contentsOf: Bundle.main.url(forResource: self, withExtension: "gif")!)
            guard let source = CGImageSourceCreateWithData(gifData as CFData, nil) else {
                return []
            }
            let count = CGImageSourceGetCount(source)
            var images = [UIImage](repeating: UIImage(), count: count)

            for i in 0..<count {
                if let cgImage = CGImageSourceCreateImageAtIndex(source, i, nil) {
                    images[i] = UIImage(cgImage: cgImage)
                }
            }
            return images
        } catch {
            return []
        }
        
    }
}

extension String {
    func customAttriString(font: UIFont, textColor: UIColor, lineSpacing: CGFloat = 4, _ alig: NSTextAlignment = .left) -> NSMutableAttributedString {
        // 创建NSMutableAttributedString
        let attributedString = NSMutableAttributedString(string: self)
        // 设置行间距
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 4 // 这里设置行间距为10点
        paragraphStyle.alignment = alig
        // 应用属性到文本
        let range = NSRange(location: 0, length: attributedString.length)
        attributedString.addAttribute(.paragraphStyle, value: paragraphStyle, range: range)
        attributedString.addAttribute(.font, value: font, range: range)
        attributedString.addAttribute(.foregroundColor, value: textColor, range: range)
        
        // 设置UILabel的属性文本
        return attributedString
    }
}

extension UIBezierPath {

    public convenience init(roundedRect rect: CGRect,
                            topLeftRadius: CGFloat?,
                            topRightRadius: CGFloat?,
                            bottomLeftRadius: CGFloat?,
                            bottomRightRadius: CGFloat?) {
        self.init()

        if (((bottomLeftRadius ?? 0) + (bottomRightRadius ?? 0)) <= rect.size.width) && (((topLeftRadius ?? 0) + (topRightRadius ?? 0)) <= rect.size.width) && (((topLeftRadius ?? 0) + (bottomLeftRadius ?? 0)) <= rect.size.height) && (((topRightRadius ?? 0) + (bottomRightRadius ?? 0)) <= rect.size.height) {
            
            // corner centers
            let tl = CGPoint(x: rect.minX + (topLeftRadius ?? 0), y: rect.minY + (topLeftRadius ?? 0))
            let tr = CGPoint(x: rect.maxX - (topRightRadius ?? 0), y: rect.minY + (topRightRadius ?? 0))
            let bl = CGPoint(x: rect.minX + (bottomLeftRadius ?? 0), y: rect.maxY - (bottomLeftRadius ?? 0))
            let br = CGPoint(x: rect.maxX - (bottomRightRadius ?? 0), y: rect.maxY - (bottomRightRadius ?? 0))

            let topMidpoint = CGPoint(x: rect.midX, y: rect.minY)

            do {
                self.move(to: topMidpoint)

                if let topRightRadius = topRightRadius {
                    self.addLine(to: CGPoint(x: rect.maxX - topRightRadius, y: rect.minY))
                    self.addArc(withCenter: tr, radius: topRightRadius, startAngle: -CGFloat.pi * 0.5, endAngle: 0, clockwise: true)
                } else {
                    self.addLine(to: tr)
                }

                if let bottomRightRadius = bottomRightRadius {
                    self.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - bottomRightRadius))
                    self.addArc(withCenter: br, radius: bottomRightRadius, startAngle: 0, endAngle: CGFloat.pi * 0.5, clockwise: true)
                } else {
                    self.addLine(to: br)
                }

                if let bottomLeftRadius = bottomLeftRadius {
                    self.addLine(to: CGPoint(x: rect.minX + bottomLeftRadius, y: rect.maxY))
                    self.addArc(withCenter: bl, radius: bottomLeftRadius, startAngle: CGFloat.pi * 0.5, endAngle: CGFloat.pi, clockwise: true)
                } else {
                    self.addLine(to: bl)
                }

                if let topLeftRadius = topLeftRadius {
                    self.addLine(to: CGPoint(x: rect.minX, y: rect.minY + topLeftRadius))
                    self.addArc(withCenter: tl, radius: topLeftRadius, startAngle: CGFloat.pi, endAngle: -CGFloat.pi * 0.5, clockwise: true)
                } else {
                    self.addLine(to: tl)
                }

                self.close()
            }
        }
         

    }
}
 

