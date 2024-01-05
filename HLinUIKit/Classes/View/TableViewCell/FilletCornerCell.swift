//
//  FilletCornerCell.swift
//  Milliohmmeter
//
//  Created by 屋联-神兽 on 2023/11/8.
//

import Foundation

public class HLFilletCornerConfig: NSObject, HLCellType {
    public var height: CGFloat = 16
    public var color: UIColor = .white
    public var backgroundColor: UIColor = .clear
    public var offset: CGFloat = 16
    public var type: UIRectCorner = [.topLeft, .topRight]
    public var cornerRadii: CGSize = CGSize(width: 8, height: 8)
    
    public var cellClass: AnyClass {
        return HLFilletCornerCell.self
    }
    public var cellHeight: CGFloat {
        return height
    }
    public var isReuse: Bool {
        return false
    }
}

open class HLFilletCornerCell: HLTableViewCell {
    
    let cornerView = UIView()
   
    open override func initConfig() {
        super.initConfig()
        backgroundColor = .clear
        bodyView.layer.masksToBounds = true
        bodyView.addSubview(cornerView)
    }
    
    open override func updateData() {
        if let config = data as? HLFilletCornerConfig {
            
            cornerView.snp.remakeConstraints { make in
                make.centerX.equalToSuperview()
                make.height.equalTo(44)
                make.left.right.equalToSuperview().inset(config.offset)
                
                if config.type.contains(.bottomLeft) || config.type.contains(.bottomRight) {
                    make.bottom.equalToSuperview()
                } else {
                    make.top.equalToSuperview()
                }
            }
            
            cornerView.backgroundColor = config.color
            cornerView.frame = CGRect(origin: .zero, size: CGSize(width: kScreenW - (config.offset * 2), height: 44))
            cornerView.createRoundCorner(type: config.type, cornerRadii: config.cornerRadii)
            
            backgroundColor = config.backgroundColor
        }
    }
}
