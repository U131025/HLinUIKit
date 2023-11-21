//
//  SeparatorCell.swift
//  Exchange
//
//  Created by 李海飞 on 2019/8/13.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit

public struct HLSeparatorConfig {

    public var backgroundColor: UIColor = .clear
    public var color: UIColor = .lightGray
    public var offset: CGFloat = 0
    public var height: CGFloat = 1
    public var width: CGFloat?
    
    public init() {
        
    }
    
    public init(offset: CGFloat) {
        self.init()
        self.offset = offset
    }
    
    public init(offset: CGFloat, color: UIColor, height: CGFloat, bgColor: UIColor = .clear) {
        self.init()
        self.offset = offset
        self.color = color
        self.height = height
        self.backgroundColor = bgColor
    }
}

open class HLSeparatorCell: HLTableViewCell {

    public var separatorView = UIView().then { (view) in
        view.backgroundColor = UIColor.clear
    }
    
    public var bgView = UIView().then { (view) in
        view.backgroundColor = UIColor.clear
    }

    override open func initConfig() {
        super.initConfig()
        backgroundColor = .clear
    }

    override open func layoutConfig() {
        contentView.addSubview(bgView)
        bgView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        bgView.addSubview(separatorView)
        separatorView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        
    }

    override open func updateData() {

        if let color = data as? UIColor {
            separatorView.backgroundColor = color
            
        } else if let config = data as? HLSeparatorConfig {
            separatorView.backgroundColor = config.color
            bgView.backgroundColor = config.backgroundColor

            separatorView.snp.remakeConstraints { (make) in
                make.center.equalToSuperview()
                make.height.equalTo(config.height)

                if let width = config.width {
                    make.width.equalTo(width)
                } else {
                    make.left.equalTo(config.offset)
                    make.right.equalTo(-config.offset)
                }
            }
        }
    }
}
