//
//  HLCustomTableViewCell.swift
//  HLinUIKit
//
//  Created by 屋联-神兽 on 2021/11/26.
//

import Foundation

public class HLCustomTableViewConfig: NSObject, HLCellType {
    public var tag: Int = 0
    public var customView: UIView?
    public var height: CGFloat = 44
    public var alignment: NSTextAlignment = .left
    public var viewSize: CGSize?
    public var backgroundColor: UIColor?
    public var offset: CGFloat = 0
    
    public var cellClass: AnyClass { return HLCustomTableViewCell.self }
    public var cellHeight: CGFloat { return height }
    public var isReuse: Bool { return false }
    
    public func setViewSize(size: CGSize, isSyncHeight: Bool = true) {
        viewSize = size
        if isSyncHeight {
            height = size.height
        }
    }
}

open class HLCustomTableViewCell: HLTableViewCell {
    
    public var customView: UIView?
    
    open override func prepareForReuse() {
        super.prepareForReuse()
        if let customView = customView {
            customView.removeFromSuperview()
        }
    }
    
    open override func initConfig() {
        super.initConfig()
       
    }
    
    open override func updateData() {
        if let config = data as? HLCustomTableViewConfig {
            tag = config.tag
            
            if let color = config.backgroundColor {
                bodyView.backgroundColor = color
            }
            if let view = config.customView {
                customView = view
                bodyView.addSubview(view)
                view.snp.remakeConstraints { make in
                    if let size = config.viewSize {
                        make.width.equalTo(size.width)
                        make.height.equalTo(size.height)
                        make.centerY.equalToSuperview()
                        
                        switch config.alignment {
                        case .left:
                            make.left.equalToSuperview().offset(config.offset)
                        case .right:
                            make.right.equalToSuperview().offset(config.offset)
                        case .center:
                            make.centerX.equalToSuperview().offset(config.offset)
                        default:
                            break
                        }
                        
                    } else {
                        make.edges.equalToSuperview()
                    }
                }
            }
        }
    }
}
