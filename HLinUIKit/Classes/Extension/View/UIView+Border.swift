//
//  UIView+Border.swift
//  Community
//
//  Created by mac on 2019/9/23.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

extension UIView {

    public enum BorderLineType {
        case top
        case bottom
        case left
        case right
    }

    /// 添加渐变透明遮罩
    ///
    /// - Parameter frame: 遮罩区域
    public func addGradientTransparentMask(frame: CGRect) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.black.withAlphaComponent(1.0).cgColor,
                                UIColor.black.withAlphaComponent(0.6).cgColor,
                                UIColor.black.withAlphaComponent(0.0).cgColor]

        gradientLayer.frame = frame
        gradientLayer.locations = [0.5, 0.7, 1]
        self.layer.mask = gradientLayer
    }

    /// 添加边框线
    ///
    /// - Parameters:
    ///   - direction: 方向
    ///   - color: 颜色

    public func addBorderLine(direction: BorderLineType, color: UIColor, offset: Int = 0, width: CGFloat = 1, interval: CGFloat = 0) -> UIView {

        let label = UILabel.init()
        label.backgroundColor = color
        self.addSubview(label)
        label.snp.makeConstraints { (make) in
            if direction == .top {
                make.top.equalTo(self).offset(interval)
                make.left.equalTo(offset)
                make.right.equalTo(-offset)
                make.height.equalTo(width)
            } else if direction == .left {
                make.left.equalTo(self).offset(interval)
                make.top.equalTo(offset)
                make.bottom.equalTo(-offset)
                make.width.equalTo(width)
            } else if direction == .right {
                make.right.equalTo(self).offset(-interval)
                make.top.equalTo(offset)
                make.bottom.equalTo(-offset)
                make.width.equalTo(width)
            } else {
                make.bottom.equalTo(self).offset(-interval)
                make.left.equalTo(offset)
                make.right.equalTo(-offset)
                make.height.equalTo(width)
            }
        }

        return label
    }
    
    /// 添加虚线边框
    /// - Parameters:
    ///   - color: 颜色
    ///   - cornerRadius: 圆角
    ///   - frame: 视图Rect
    public func setDashiedBorder(color: UIColor, cornerRadius: CGFloat = 4, frame: CGRect? = nil) {
        let borderLayer = CAShapeLayer()
        borderLayer.bounds = frame ?? self.bounds
        borderLayer.position = CGPoint(x: self.bounds.size.width/2, y: self.bounds.size.height/2)
        borderLayer.path = UIBezierPath(roundedRect: borderLayer.bounds, cornerRadius: 0).cgPath
        borderLayer.lineWidth = 0.5
        borderLayer.lineDashPattern = [2, 2]
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.strokeColor = color.cgColor
        borderLayer.cornerRadius = cornerRadius
        self.layer.addSublayer(borderLayer)
    }
}
