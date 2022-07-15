//
//  ListTableViewCell.swift
//  Community
//
//  Created by mac on 2019/9/19.
//  Copyright © 2019 mac. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

open class HLListTableViewCell: HLTableViewCell {
    
    public var cellConfigBlock: HLTableViewCellConfigBlock?

    public lazy var listView = HLTableView()
        .selectedAction(action: {[unowned self] (type) in
            self.cellEvent.onNext((tag: 0, value: type))
            self.selectedAction(type)
        })
        .selectedIndexPathAction(action: { ip in
            self.selectedIndexPathAction(ip)
        })
        .setCellConfig(config: { (cell, indexPath) in
            self.cellConfig(cell: cell, indexPath: indexPath)
            self.cellConfigBlock?(cell, indexPath)
        })
        .build()
    
    open func cellConfig(cell: HLTableViewCell, indexPath: IndexPath) {
        
    }
    
    open func selectedAction(_ type: HLCellType) {
        
    }
    
    open func selectedIndexPathAction(_ ip: IndexPath) {
        
    }

    override open func initConfig() {
        super.initConfig()

        listView.bounces = false
        contentView.addSubview(listView)
        listView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
    }
    
    open override func bindConfig() {
        super.bindConfig()
        
        listView.cellEvent.bind(to: event).disposed(by: disposeBag)
    }

    override open func updateData() {

        if let datas = data as? [HLCellType] {
            _ = listView.setItems(datas)
        }
    }

    public func setItemInsert(insert: UIEdgeInsets) {

        listView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview().inset(insert)
        }
    }
}

extension HLListTableViewCell {

    static public func calculateCellHeight(_ datas: Any?) -> CGFloat {

        if let items = datas as? [HLCellType] {

            let cellHeight = items.map { $0.cellHeight }.reduce(0) { (left, right) -> CGFloat in
                return left + right
            }

            return cellHeight
        }

        return 0
    }
}
