//
//  CustomSection.swift
//  BluetoothTest
//
//  Created by mojingyu on 2019/3/20.
//  Copyright © 2019 mac. All rights reserved.
//

import Foundation
import RxDataSources

public protocol HLCellType {
    // Cell的类名
    var cellClass: AnyClass { get }
    
    // tableViewCell使用
    var cellHeight: CGFloat { get }
        
    // collectionCell使用
    var cellSize: CGSize { get }
    // cell里使用的数据
    var cellData: Any? { get }
    // 原数据
    var content: Any? { get }

    var tag: Int { get }
    
    // cell 是否支持重用
    var isReuse: Bool { get }    
}

extension HLCellType {
    
//    public var classType: AnyClass {
//        return RxBaseTableViewCell.self
//    }
    
    public var identifier: String {
        return "\(cellClass)"
    }

    public var cellHeight: CGFloat {
        return 44
    }
    
    public var cellSize: CGSize {
        return CGSize.zero
    }

    public var cellData: Any? { return self }

    public var content: Any? { return self }

    public var tag: Int { return 0 }
   
    public var isReuse: Bool { return true }
    
    public func createView() -> UIView? {
        if let view = identifier.toHLCell() {
            view.tag = tag
            view.cellType = self
            view.data = self.cellData
            view.updateData()
            return view
        }
        return nil
    }
}

extension String: HLCellType {
    
    public var cellClass: AnyClass {
        return HLTableViewCell.self
    }
}

extension Array where Element: HLCellType {

    func toSection(_ title: String = "") -> SectionModel<String, HLCellType> {

        return SectionModel(model: title, items: self)
    }
}
