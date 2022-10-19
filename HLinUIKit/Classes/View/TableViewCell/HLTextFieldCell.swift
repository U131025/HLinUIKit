//
/***********************************************************
            
 File name:     TextFieldCell.swift
 Author:        Mojy
            
 Description:   TexField样式的TableVewlCell
            
 History:  2019/5/8: File created.
            
 ************************************************************/

import UIKit
import RxSwift
import RxCocoa

extension UIColor {
    open class var cellBorderColor: UIColor {
        return .init(hex: "FFFFFF")
    }

    open class var cellPlaceHolderColor: UIColor {
        return .init(hex: "FFFFFF")
    }
}

extension NSAttributedString {
    public
    func calcHeight(for width: CGFloat) -> CGFloat {
        guard self.string.count > 0 else { return 0 }
        let maxHeight: CGFloat = 10000
        let path: CGPath = CGPath(rect: .init(x: 0, y: 0, width: width, height: maxHeight), transform: nil)
        let frame: CTFrame = ctFrame(for: path)
        let lines: [CTLine] = CTFrameGetLines(frame) as! [CTLine]

        var ascent: CGFloat = .zero
        var descent: CGFloat = .zero
        var leading: CGFloat = .zero
        CTLineGetTypographicBounds(lines[lines.count - 1], &ascent, &descent, &leading)
        
        var origins: [CGPoint] = [CGPoint](repeating: .zero, count: lines.count)
        CTFrameGetLineOrigins(frame, CFRangeMake(0, 0), &origins)
        let last: CGPoint = origins[lines.count - 1]

        return ceil(maxHeight - last.y + descent) + 1
    }

    private
    func ctFrame(for path: CGPath) -> CTFrame {
        let cgpath: CGMutablePath = CGMutablePath()
        let rect: CGRect = path.boundingBox

        var tran: CGAffineTransform = CGAffineTransform.identity
        tran = tran.translatedBy(x: rect.origin.x, y: rect.origin.y)
        tran = tran.scaledBy(x: 1, y: -1)
        tran = tran.translatedBy(x: rect.origin.x, y: -rect.height)
        cgpath.addPath(path, transform: tran)
        cgpath.move(to: .zero)
        cgpath.closeSubpath()

        return CTFramesetterCreateFrame(
            CTFramesetterCreateWithAttributedString(self),
            CFRangeMake(0, self.length),
            CGPath(rect: rect, transform: nil),
            nil
        )
    }
}

extension String {

    public func calculateHeight(_ font: UIFont?, _ maxWidth: CGFloat = CGFloat(MAXFLOAT)) -> CGFloat {
        
        return calculateSize(font, maxWidth).height
    }
    
    public func calculateSize(_ font: UIFont?, _ maxWidth: CGFloat = CGFloat(MAXFLOAT)) -> CGSize {
        
        let font = font ?? .pingfang(ofSize: 15)
        let rect = (self as NSString).boundingRect(with: CGSize(width: maxWidth, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)

        return rect.size
    }
}

public class HLTextCellConfig: NSObject {

    public var tag: Int = 0
    public var text: String?
    public var attributedText: NSAttributedString?
    public var placeholder: String?
    public var constraint: HLTextFieldConstraint = .text(maxLen: 50) // 默认支持中英特殊字符
    public var keyboardType: UIKeyboardType = .default
    public var textAlignment = NSTextAlignment.left
    public var clearButtonModel = UITextField.ViewMode.whileEditing

    public var useVerificationCode: Bool = false

    public var rightView: UIView?
    public var allowEdit: Bool = true

    public var textColor: UIColor?
    public var placeholderColor: UIColor? = .systemGray
    public var backgroundColor: UIColor?
    public var inputBackgroundColor: UIColor? /// 输入框背景色

    public var font: UIFont?
    /// 缩进
    public var offsetX: CGFloat?
    /// 是否根据校验类型自动格式化
    public var autoFormat: Bool = false
    /// 是否需要极验行为验证
    public var needActive: Bool = true

    /// 最大输入限制
    public var maxInputCount = 100
    /// 是否显示分隔线
    public var isShowSeparatedLine: Bool = false

    /// 图标
    public var icon: UIImage?

    /// 输入时的提示信息
    public var tip: String?
    /// Cell的高度
    public var height: CGFloat?
    public var size: CGSize?
    /// 自定义Cell类型，需要继承HLTableViewCell或HLCollectionViewCell
    public var cell: AnyClass?
    public var reuseEnable: Bool = true
    
    public var data: Any?
}

extension HLTextCellConfig {

    public func calculateTextHeight(_ maxWidth: CGFloat) -> CGFloat {
        
        if let attrText = attributedText {
            return attrText.calcHeight(for: maxWidth)
        }

        let height = text?.calculateHeight(font, maxWidth) ?? 44
        return height
    }
}

extension HLTextCellConfig: HLCellType {
    public var cellClass: AnyClass { return cell ?? HLTextFieldCell.self }
    public var cellHeight: CGFloat { return height ?? calculateTextHeight(kScreenW - 30) }
    public var cellSize: CGSize { return size ?? .zero }
    public var isReuse: Bool { return reuseEnable }
}

open class HLTextFieldCell: HLTableViewCell {
    
    public var inputBackgroundColor: UIColor? {
        didSet {
            if let color = inputBackgroundColor {
                contentView.backgroundColor = color
                textField.backgroundColor = color
            }
        }
    }

    public let textField = HLTextField().then { (textField) in
        textField.textColor = UIColor.white
        textField.placeholderTextColor = UIColor.systemGray
        textField.clearButtonMode = .whileEditing
        textField.textOffset = 15
    }

    lazy public var verificationCodeButton = UIButton().then {
        $0.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        $0.setTitle("获取验证码".localized, for: .normal)
        $0.frame = CGRect.init(x: 0, y: 0, width: 110, height: 45)

        $0.contentHorizontalAlignment = .right
        $0.contentEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)
        $0.setTitleColor(UIColor.systemBlue, for: .normal)
        $0.setTitleColor(UIColor.gray, for: .disabled)
    }
    
    public typealias InputValueLimitBlock = (String) -> String
    public var inputLimitBlock: InputValueLimitBlock?
    public func setInputLimitBlock(_ block: InputValueLimitBlock?) -> Self {
        self.inputLimitBlock = block
        return self
    }

    /// 提示信息
    lazy public var tipLabel = UILabel().then { (label) in
        label.font = .pingfang(ofSize: 10)
        label.textColor = .systemRed
        label.isHidden = true
    }
    
    override open func bindConfig() {
        super.bindConfig()

        textField.textSubject.subscribe(onNext: { [weak self] text in

            guard let weakSelf = self else { return }
            weakSelf.cellEvent.onNext((tag: weakSelf.textField.tag, value: weakSelf.textField.text))
        }).disposed(by: disposeBag)

        /// 输入格式化
        textField.rx.controlEvent(.editingChanged)
            .subscribe(onNext: {[unowned self] _ in

                var text = self.textField.text ?? ""
                if let inputLimitBlock = self.inputLimitBlock {
                    text = inputLimitBlock(text)
                    
                    self.textField.text = text
                    self.textField.sendActions(for: .valueChanged)
                    return
                }
                                
                guard let config = self.data as? HLTextCellConfig else {
                    return
                }

                if case .password = config.constraint, config.tip != nil, text.count > 0 {
                    self.tipLabel.isHidden = Validate.password(text).isRight
                } else {
                    self.tipLabel.isHidden = true
                }

                /// 不自动格式化则直接返回
                if config.autoFormat == false {
                    return
                }

                switch config.constraint {
                case .decimal:

                    self.textField.text = text.formatCoinNumberString(decimalLen: 8)
                case .money:
                    self.textField.text = text.formatPriceString()

                default:
                    break
                }

            }).disposed(by: disposeBag)

    }

    override open func initConfig() {
        contentView.backgroundColor = .white
//        contentView.layer.cornerRadius = 4
    }
    
    // 分割线
    public var line: UIView?

    override open func layoutConfig() {
        
        contentView.snp.remakeConstraints { make in
//            make.center.equalToSuperview()
//            make.height.equalTo(50)
//            make.left.equalTo(HLTableViewCell.defaultCellMarginValue)
//            make.right.equalTo(-HLTableViewCell.defaultCellMarginValue)
            make.edges.equalToSuperview()
        }

        contentView.addSubview(textField)
        textField.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        addSubview(tipLabel)
        tipLabel.snp.makeConstraints { (make) in
            make.left.equalTo(HLTableViewCell.defaultCellMarginValue)
            make.right.equalTo(-HLTableViewCell.defaultCellMarginValue)
            make.top.equalTo(textField.snp.bottom)
            make.bottom.equalToSuperview()
        }
        
        line = textField.addBorderLine(direction: .bottom, color: .systemGray)
        line?.isHidden = true
    }
    
    public func updateConfigValue(_ value: String?) {
        if let config = data as? HLTextCellConfig {
            config.text = value
        }
    }

    override open func updateData() {
        super.updateData()

        if let config = data as? HLTextCellConfig {
            tag = config.tag
            textField.tag = config.tag
            textField.keyboardType = config.keyboardType
            textField.constraint = config.constraint
            textField.clearButtonMode = config.clearButtonModel

            textField.placeholder = config.placeholder
            textField.placeholderTextColor = config.placeholderColor

            textField.textAlignment = config.textAlignment
            textField.textColor = config.textColor
            textField.font = config.font
            
            if let offsetX = config.offsetX {
                textField.textOffset = offsetX
            }

            if case .password = config.constraint {
                textField.isSecureTextEntry = true
            } else {
                textField.isSecureTextEntry = false
            }

            textField.isEnabled = config.allowEdit

            if let rightView = config.rightView {
                textField.rightView = rightView
                textField.rightViewMode = .always
            }

            if let textColor = config.textColor {
                textField.textColor = textColor
            }

            if let content = config.text {
                textField.text = content
            }

            if let backgroudColor = config.backgroundColor {
                contentView.backgroundColor = backgroudColor
            }
            
            if let color = config.inputBackgroundColor {
                textField.backgroundColor = color
            }

            line?.isHidden = !config.isShowSeparatedLine
            
            if let icon = config.icon {
                textField.leftView = UIImageView(image: icon)
                textField.leftViewMode = .always
            } else {
                textField.leftView = nil
                textField.leftViewMode = .never
            }

            if let tip = config.tip {
                tipLabel.text = tip
            }
        }
    }
    
    open func setupVerificationCode() {
        
        verificationCodeButton.removeFromSuperview()
        contentView.addSubview(verificationCodeButton)
        verificationCodeButton.snp.makeConstraints { make in
            make.right.equalToSuperview()
            make.top.bottom.equalToSuperview()
            make.width.equalTo(100)
        }
        
        textField.snp.remakeConstraints { make in
            make.left.top.bottom.equalToSuperview()
            make.right.equalTo(verificationCodeButton.snp.left).offset(-8)
        }
    }
}
