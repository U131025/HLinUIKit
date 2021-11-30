//
//  HLCustomTableViewCell.swift
//  HLinUIKit
//
//  Created by 屋联-神兽 on 2021/11/26.
//

import Foundation

public class HLCustomTableViewConfig: NSObject, HLCellType {
    
    public var customView: UIView?
    public var height: CGFloat = 44
    
    public var cellClass: AnyClass { return HLCustomTableViewCell.self }
    public var cellHeight: CGFloat { return height }
}

open class HLCustomTableViewCell: HLTableViewCell {
    
    public var customView: UIView?
    
    open override func updateData() {
        if let config = data as? HLCustomTableViewConfig {
            customView?.removeFromSuperview()
            if let view = config.customView {
                customView = view
                contentView.addSubview(view)
                view.snp.makeConstraints { make in
                    make.edges.equalToSuperview()
                }
            }
        }
    }
}
