//
//  DefaultCellType.swift
//  SmartLock
//
//  Created by mac on 2019/12/30.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation

public enum HLTableViewCellType {
    case text(HLTextCellConfig?, HLTextCellConfig?)
    case textFiled(HLTextCellConfig)
    case attrText(Any?)

    case list(Any?)
    case horizontalList(Any?, CGFloat)
    case separator(UIColor, CGFloat)
    case line(HLSeparatorConfig)
    case collections(Any?, CGFloat)
}

extension HLTableViewCellType: HLCellType {
    
    public var cellClass: AnyClass {
        switch self {
        case .list:
            return HLListTableViewCell.self
        case .horizontalList:
            return HLHorListTableViewCell.self
        case .text:
            return HLTextTableViewCell.self
        case .textFiled:
            return HLTextFieldCell.self
        case .separator, .line:
            return HLSeparatorCell.self
        case .attrText:
            return HLAttrStringTextCell.self
        case .collections:
            return HLCollectionsTableViewCell.self
        }
    }

    public var cellHeight: CGFloat {
        switch self {
        case .list(let datas):
            return HLListTableViewCell.calculateCellHeight(datas)
        case .text(let config, _):
            return config?.height ?? 57
        case .textFiled:
            return 56
        case .separator(_, let height):
            return height
        case .attrText(let text):            
            return HLAttrStringTextCell.calculateCellHeight(text, kScreenW - HLTableViewCell.defaultCellMarginValue*2)
        case .line(let config):
            return config.height
        case .horizontalList(_, let height):
            return height
        case .collections(_, let height):
            return height
        }
    }

    public var cellData: Any? {
        switch self {
        case .list(let datas):
            return datas
        case .horizontalList(let datas, _):
            return datas
        case let .text(title, detail):
            return (title, detail)
        case .textFiled(let config):
            return config
        case .separator(let color, _):
            return color
        case .attrText(let text):
            return text
        case .line(let config):
            return config
        case .collections(let datas, _):
            return datas
        }
    }
}
