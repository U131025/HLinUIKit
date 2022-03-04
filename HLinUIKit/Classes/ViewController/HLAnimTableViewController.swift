//
//  HLAnimTableViewController.swift
//  HLinUIKit
//
//  Created by 屋联-神兽 on 2021/12/3.
//

import Foundation
import RxDataSources
import RxSwift
import RxCocoa

open class HLAnimTableViewController: HLTableViewController {
       
    open override func initConfig() {
        super.initConfig()
        
        listView = HLAnimTableView()
            .setStyle(self.style)
            .setTableViewConfig(config: {(tableView) in
                self.setTableViewConfig(tableView)
            })
            .setCellConfig(config: {(cell, indexPath) in
                self.cellConfig(cell, indexPath)
            })
            .selectedAction(action: {(type) in
                self.itemSelected(type)
            })
            .selectedIndexPathAction(action: {(indexPath) in
                self.itemSelected(indexPath: indexPath)
            })
            .setCalculateCellHeight({ (ip) -> CGFloat? in
                return self.calculateCellHeight(ip)
            })
            .deselectedAction(action: {[unowned self] (type) in
                self.itemDeselected(type)
            })
            .deselectedIndexPathAction(action: {[unowned self] (indexPath) in
                self.itemDeselected(indexPath: indexPath)
            })
            .build()
    }
    
    open override var viewModel: HLViewModel? {
        didSet {
            if let viewModel = self.viewModel as? HLAnimViewModel, let listView = listView as? HLAnimTableView {

                bindConfig()

                _ = cellEvent
                    .take(until: self.rx.deallocated)
                    .bind(to: viewModel.event)

                _ = listView.cellEvent
                    .take(until: self.rx.deallocated)
                    .bind(to: viewModel.event)

                _ = viewModel.animItems
                    .take(until: self.rx.deallocated)
                    .subscribe(onNext: {(sections) in
                        _ = listView.setAnimSections(sections: sections)
                    })

                viewModel.refresh()
            }
        }
    }
    
    open override func initNoDataView() {
        noDataView?.removeFromSuperview()
        guard let emptyView = noDataView else { return }

        guard let viewModel = viewModel as? HLAnimViewModel else {
            return
        }

        _ = viewModel
            .animItems
            .take(until: self.rx.deallocated)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: {[unowned self] (sections) in
                
                emptyView.removeFromSuperview()
                if sections.count == 0 || (sections.count == 1 && sections[0].items.count == 0) {
    
                    self.view.insertSubview(emptyView, aboveSubview: self.listView)
                    emptyView.snp.remakeConstraints { (make) in
                        make.edges.equalTo(self.listView)
                    }
                    
                }
            })
    }
}
