//
//  BaseViewModel.swift
//  Exchange
//
//  Created by mac on 2018/12/25.
//  Copyright © 2018 mac. All rights reserved.
//

import Foundation
import RxDataSources
import RxCocoa
import RxSwift

/// 刷新类型
public enum HLRefreshType {
    case reload
    case loadMore
}
/// ViewModel基类
open class HLViewModel {
    /// 刷新类型
    public var refreshType = HLRefreshType.reload {
        didSet {
            if refreshType == .reload {
                self.page = 1
            } else {
                self.page += 1
            }
        }
    }
    /// 页面和页面大小
    public var page: Int = 1
    public var pageSize: Int = 20

    public var disposeBag = DisposeBag()
    public var disposable: Disposable?

    /// 数据源
    public var items = BehaviorRelay<[SectionModel<String, HLCellType>]>(value: [])

    public weak var viewController: HLViewController?

    /// 初始化
    public init(_ viewController: HLViewController? = nil) {
        self.viewController = viewController

        initConfig()
        bindConfig()
    }

    open func initConfig() {

    }
    
    open func release() {
        disposeBag = DisposeBag()
        self.viewController = nil
    }

    /// 释放
    deinit {
        self.release()
    }

    /// 自定义事件绑定
    public var event: Binder<(tag: Int, value: Any?)> {
        return Binder(self) { base, event in
            base.handleEvent(event: event)
        }
    }
    /// 自定义事件处理
    open func handleEvent(event: (tag: Int, value: Any?)) {

    }

    /// 选中处理
    open func itemSelected(_ type: HLCellType) {

    }    
   
    /// 序列
    open func itemSelected(indexPath: IndexPath) {

    }
    
    open func itemDeselected(type: HLCellType) {

    }
    
    open func itemDeselected(indexPath: IndexPath) {

    }
    
//    public func setSelectedCell(_ ip: IndexPath) {
//        guard let vc = viewController as? HLTableViewController else {
//            return
//        }
//
//        DispatchQueue.main.async {
//            vc.listView.selectRow(at: ip, animated: false, scrollPosition: .none)
//        }
//    }

    /// 刷新
    open func refresh() {
        
        refresh(type: .reload)
        HLTableViewCell.defaultCellMarginValue = 16
    }

    open func refresh(type: HLRefreshType) {
        self.refreshType = type
    }
    
    public func endEditing(_ force: Bool = true) {
        DispatchQueue.main.async {
            self.viewController?.view.endEditing(force)
        }        
    }
    
    public func beginRefreshing() {
        if let vc = viewController as? HLTableViewController, vc.listView.mj_header?.isRefreshing == false {
            
            vc.listView.mj_header?.beginRefreshing()
        }
    }
    
    public func endRefreshing() {
        if let vc = viewController as? HLTableViewController {
            
            vc.listView.mj_header?.endRefreshing()
            vc.listView.mj_footer?.endRefreshing()
        }
    }
    
    public lazy var isLoadFinish: Bool = false {
        didSet {
            DispatchQueue.main.async {
                if self.isLoadFinish == true {
                    if let vc = self.viewController as? HLTableViewController {
                        vc.listView.mj_footer?.endRefreshingWithNoMoreData()
                    } else if let vc = self.viewController as? HLCollectionViewController {
                        vc.listView.collectionView.mj_footer?.endRefreshingWithNoMoreData()
                    }
                }
            }            
        }
    }
    /// 预加载处理
    open func preload(indexPath: IndexPath) {
        
    }

    /// 绑定处理
    open func bindConfig() {
        disposeBag = DisposeBag()
    }

    //cell内部控件绑定扩展
    open func cellConfig(_ cell: HLTableViewCell, _ indexPath: IndexPath) {
      
    }
    
    /// cell内部控件绑定扩展
    open func cellControlBindConfig(_ cell: HLCollectionViewCell, _ indexPath: IndexPath) {

    }
    
    open func calculateCellHeight(_ indexPath: IndexPath) -> CGFloat? {
        return nil
    }
}

extension HLViewModel {
    
    public func getItemValue(with ip: IndexPath) -> HLCellType? {
        return items.value[safe: ip.section]?.items[safe: ip.row]
    }

    public func setItems(_ datas: [HLCellType]) -> Self {
        items.accept([SectionModel(model: "list", items: datas)])
        return self
    }

    public func setSections(sections: [SectionModel<String, HLCellType>]) -> Self {
        items.accept(sections)
        return self
    }
    
    public func reloadItemsAtIndexPaths(_ ips: [IndexPath]) {
        
        if let vc = viewController as? HLTableViewController {
            vc.listView.reloadItemsAtIndexPaths(ips, animationStyle: .none)
        }
    }
}
// MARK: 列表选中
extension HLViewModel {

    public func getSelectedItems() -> [HLCellType] {
        if let vc = viewController as? HLTableViewController {
            return vc.listView.getSelectedRows()
        }
        return []
    }
    
    public func setSelectedIndexPath(_ indexPath: IndexPath, isSelected: Bool = true) {
        guard let vc = viewController as? HLTableViewController else {
            return
        }
        DispatchQueue.main.async {
            if isSelected {
                vc.listView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
            } else {
                vc.listView.deselectRow(at: indexPath, animated: false)
            }
        }
    }
    
    public func setSelectedIndexPaths(_ indexPaths: [IndexPath]) {
        for ip in indexPaths {
            setSelectedIndexPath(ip)
        }
    }
    
    public func getSelectedIndexPath() -> IndexPath? {
        guard let vc = viewController as? HLTableViewController else {
            return nil
        }
        
        return vc.listView.indexPathForSelectedRow
    }
    
    public func getIndexPathsForSelectedRows() -> [IndexPath] {
        guard let vc = viewController as? HLTableViewController else {
            return []
        }
        
        return vc.listView.indexPathsForSelectedRows ?? []
    }
    
    public func reloadRows(_ indexPaths: [IndexPath]) {
        guard let vc = viewController as? HLTableViewController else {
            return
        }
        
        DispatchQueue.main.async {
            vc.listView.beginUpdates()
            vc.listView.reloadRows(at: indexPaths, with: .none)
            vc.listView.endUpdates()
        }
    }
}
