//
//  FilletCornerCell.swift
//  Milliohmmeter
//
//  Created by 屋联-神兽 on 2023/11/8.
//

import Foundation

public class HLFilletCornerConfig: NSObject, HLCellType {
    public var height: CGFloat = 16
    public var backgroundColor: UIColor = .white
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
    
    let view = UIView()
    
    open override func initConfig() {
        super.initConfig()
        
        contentView.addSubview(view)
        view.snp.makeConstraints { make in
            make.left.right.equalToSuperview().inset(16)
            make.top.bottom.equalToSuperview()
        }
    }
    
    open override func updateData() {
        if let config = data as? HLFilletCornerConfig {
            view.backgroundColor = config.backgroundColor
            
            view.frame = CGRect(origin: .zero, size: CGSize(width: kScreenW - (config.offset * 2), height: config.height))
            view.snp.remakeConstraints { make in
                make.height.equalTo(config.height)
                make.center.equalToSuperview()
                make.left.right.equalToSuperview().inset(config.offset)
            }
            
            view.createRoundCorner(type: config.type, cornerRadii: config.cornerRadii)
        }
    }
}
