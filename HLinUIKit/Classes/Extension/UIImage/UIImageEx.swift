//
//  UIImageEx.swift
//  IM_XMPP
//
//  Created by mojingyu on 2018/9/14.
//  Copyright © 2018年 mac. All rights reserved.
//
// swiftlint:disable line_length

import Foundation
import UIKit

extension UIImage {
    /**
     *  重设图片大小
     */
    public func reSizeImage(reSize: CGSize) -> UIImage {

        UIGraphicsBeginImageContextWithOptions(reSize, false, UIScreen.main.scale)
        self.draw(in: CGRect.init(x: 0, y: 0, width: reSize.width, height: reSize.height))
        let reSizeImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return reSizeImage
    }
    /**
     *  等比率缩放
     */
    public func scaleImage(scaleSize: CGFloat) -> UIImage {
        let reSize = CGSize.init(width: self.size.width * scaleSize, height: self.size.height * scaleSize)
        return reSizeImage(reSize: reSize)
    }
    
    //切圆角
    public func tailoring(radius: CGFloat) -> UIImage? {
        //开启上下文
        UIGraphicsBeginImageContext(size)
        //设置一个圆形的裁剪区域
        let path = UIBezierPath(roundedRect: CGRect(x: 0,
                                                    y: 0,
                                                    width: size.width,
                                                    height: size.height), cornerRadius: radius)

        //把路径设置为裁剪区域(超出裁剪区域以外的内容会被自动裁剪掉)
        path.addClip()
        //把图片绘制到上下文当中
        draw(at: CGPoint.zero)
        //从上下文当中生成一张图片
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        return newImage
    }
    
    // 按比例裁剪
    public func cropCoverImage(ratio: CGFloat) -> UIImage? {
        
//        let ratio: CGFloat = 230.0 / 358.0
        
        //计算最终尺寸
        var newSize: CGSize
        if size.width/size.height > ratio {
            newSize = CGSize(width: size.height * ratio, height: size.height)
        } else {
            newSize = CGSize(width: size.width, height: size.width / ratio)
        }
     
        ////图片绘制区域
        var rect = CGRect.zero
        rect.size.width  = size.width
        rect.size.height = size.height
        rect.origin.x    = (newSize.width - size.width ) / 2.0
        rect.origin.y    = (newSize.height - size.height ) / 2.0
         
        //绘制并获取最终图片
        UIGraphicsBeginImageContext(newSize)
        draw(in: rect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
         
        return scaledImage
    }
    
    /// 图片加水印
    public func drawTextInImage(attributedText: NSAttributedString, alignment: NSTextAlignment = .left) -> UIImage? {
        // 开启和原图一样大小的上下文（保证图片不模糊的方法）
        UIGraphicsBeginImageContextWithOptions(self.size, false, self.scale)
        
        // 图形重绘
        self.draw(in: CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height))
        
        let scaleRate: CGFloat = self.size.width / 230
        
        // 文字属性
        var size =  attributedText.size()
        
        let textWidth: CGFloat = self.size.width - (30 * scaleRate)
        var height = size.height
        if size.width > textWidth {
           
            let row = Int(size.width / textWidth) + (Int(size.width) % Int(textWidth) == 0 ? 0 : 1)
            height = Double(row) * size.height
        }
        
        size = CGSize(width: textWidth, height: height)
        
        var x = (self.size.width - size.width) / 2
        switch alignment {
        case .left:
            x = 15 * scaleRate
        case .center:
            x = (self.size.width - size.width) / 2
        case .right:
            x = self.size.width - size.width - (15 * scaleRate)
        default:
            break
        }
        
        let y = (self.size.height - size.height) / 2
        
        // 绘制文字
        attributedText.draw(in: CGRect(x: x, y: y, width: size.width, height: size.height))
        // 从当前上下文获取图片
        let image = UIGraphicsGetImageFromCurrentImageContext()
        //关闭上下文
        UIGraphicsEndImageContext()
        
        return image
    }
}

extension UIImage {
    // 图片置灰
    public var grayImage: UIImage {

        UIGraphicsBeginImageContext(self.size)
        let colorSpace = CGColorSpaceCreateDeviceGray()
        let context = CGContext(data: nil, width: Int(self.size.width), height: Int(self.size.height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: CGImageAlphaInfo.none.rawValue)
        context?.draw(self.cgImage!, in: CGRect.init(x: 0, y: 0, width: self.size.width, height: self.size.height))
        let cgImage = context!.makeImage()
        let grayImage = UIImage.init(cgImage: cgImage!)

        return grayImage
    }
    
    public func byTintColor(_ tintColor: UIColor, _ blendMode: CGBlendMode = .destinationIn) -> UIImage? {
                
        UIGraphicsBeginImageContextWithOptions(self.size, false, 0.0)
        tintColor.setFill()

        let bounds = CGRect(x: 0, y: 0, width: self.size.width, height: self.size.height)
        UIRectFill(bounds)

        self.draw(in: bounds, blendMode: blendMode, alpha: 1.0)

        if blendMode != .destinationIn {
            self.draw(in: bounds, blendMode: .destinationIn, alpha: 1.0)

        }
        let tintedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return tintedImage
    }
}
