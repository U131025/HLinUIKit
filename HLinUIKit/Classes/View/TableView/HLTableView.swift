//
//  RxBaseView.swift
//  VGCLIP
//
//  Created by mojingyu on 2019/5/7.
//  Copyright © 2019 Mojy. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import Then
import SnapKit
import MJRefresh

public enum HLTableViewStyle {
    case normal
    case form
}

public typealias HLTableViewCellConfigBlock = (HLTableViewCell, IndexPath) -> Void
public typealias HLTableViewViewInSectionConfigBlock = (Int) -> UIView?
public typealias HLTableViewHeightInSectionConfigBlock = (Int) -> CGFloat

public typealias HLTableViewEditingStyleConfigBlock = (IndexPath) -> UITableViewCell.EditingStyle?
public typealias HLTableViewEditingActionsConfigBlock = (IndexPath) -> [UITableViewRowAction]?

public typealias HLCellCalculateHeightBlock = (IndexPath) -> CGFloat?
public typealias HLPreloadConfigBlock = (IndexPath) -> Void

open class HLTableView: UITableView, UITableViewDelegate {

    var hlStyle: HLTableViewStyle = .normal
    var cellEvent = PublishSubject<(tag: Int, value: Any?)>()
    var items = BehaviorRelay<[SectionModel<String, HLCellType>]>(value: [])

    var itemSelectedBlock: HLItemSelectedBlock?
    var itemSelectedIndexPathBlock: HLItemSelectedIndexPathBlock?
    
    var itemDeselectedBlock: HLItemSelectedBlock?
    var itemDeselectedIndexPathBlock: HLItemSelectedIndexPathBlock?

    var cellConfigBlock: HLTableViewCellConfigBlock?

    var headerInSectionBlock: HLTableViewViewInSectionConfigBlock?
    var headerHeightInSectionBlock: HLTableViewHeightInSectionConfigBlock?
    var footerInSectionBlock: HLTableViewViewInSectionConfigBlock?
    var footerHeightInSectionBlock: HLTableViewHeightInSectionConfigBlock?

    var editingStyeBlock: HLTableViewEditingStyleConfigBlock?
    var editingActionsBlock: HLTableViewEditingActionsConfigBlock?
    /// 自定义计算Cell高度
    var calculateCellHeightBlock: HLCellCalculateHeightBlock?
    /// 预加载
    var preloadBlock: HLPreloadConfigBlock?
    
    public var disposeBag = DisposeBag()
    
    public override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        initConfig()
        bindConfig()
    }
    
    public init() {
        super.init(frame: .zero, style: .plain)
        initConfig()
        bindConfig()
    }
    
    required public init?(coder: NSCoder) {
        super.init(coder: coder)
        initConfig()
        bindConfig()
    }

    // MARK: DataSource
    lazy public var hlDataSource: RxTableViewSectionedReloadDataSource<SectionModel<String, HLCellType>> = {

        return HLTableViewDataSource.generateDataSource(style: .normal, eventBlock: {[unowned self] (cell, indexPath) in

            self.cellConfigBlock?(cell, indexPath)

            // cell内部事件
            cell.cellEvent
                .subscribe(onNext: {[unowned self] (info) in
                    self.cellEvent.onNext(info)
                }).disposed(by: cell.disposeBag)
        })
    }()

    func refreshHeader(block: CompleteBlock?, config: HLTextCellConfig? = nil) -> MJRefreshStateHeader {

        let header = MJRefreshNormalHeader.init(refreshingBlock: {[weak self] in

            if (self?.mj_footer) != nil {
                self?.mj_footer?.resetNoMoreData()
            }

            self?.mj_footer?.resetNoMoreData()
            block?()

        }).then {

            $0.lastUpdatedTimeLabel?.isHidden = true
            $0.stateLabel?.isHidden = false

            $0.stateLabel?.textColor = config?.textColor ?? UIColor.lightGray
            $0.stateLabel?.font = config?.font ?? .pingfang(ofSize: 13)

//            let images = UIImage.getLoadingImages()
//            $0.setImages(images, duration: 1, for: .refreshing)
//            $0.setImages(images, duration: 1, for: .pulling)
        }

        return header
    }

    func loadMoreFooter(block: CompleteBlock?, config: HLTextCellConfig? = nil) -> MJRefreshAutoFooter {

        return MJRefreshAutoNormalFooter.init(refreshingBlock: {
            block?()
        }).then {

            $0.stateLabel?.textColor = config?.textColor ?? .lightGray
            $0.stateLabel?.font = config?.font ?? .pingfang(ofSize: 13)
            $0.isRefreshingTitleHidden = false
            $0.isAutomaticallyRefresh = false

//            $0.setTitle(LocalizedString(""), for: .idle)
//            $0.setTitle(LocalizedString("释放即可刷新"), for: .pulling)
//            $0.setTitle(LocalizedString("正在加载更多数据"), for: .refreshing)
//            $0.setTitle(LocalizedString("暂无更多数据"), for: .noMoreData)

        }
    }

    //cell内部控件绑定扩展        
    open func initConfig() {
        
        backgroundColor = UIColor.clear
        separatorStyle = .none
        showsVerticalScrollIndicator = false
        
        estimatedRowHeight = 0
        estimatedSectionHeaderHeight = 0
        estimatedSectionFooterHeight = 0
           
        if #available(iOS 15, *) {
            sectionHeaderTopPadding = 0
        }
    }

    open func bindConfig() {
        self.disposeBag = DisposeBag()
        self.rx.setDelegate(self).disposed(by: disposeBag)
    }

    /// 缺省事件绑定，晚于initConfig, bindConfig执行
    func initDefaultConfig() {

        _ = items.asObservable()
            .do(onNext: {[unowned self] (_) in
                self.endRefreshing()
            })
            .take(until: rx.deallocated)
            .bind(to: rx.items(dataSource: hlDataSource))

//        _ = tableView.rx
//            .modelSelected(RxBaseCellType.self)
//            .take(until:self.rx.deallocated)
//            .subscribe(onNext: {[unowned self] (type) in
//                self.itemSelectedBlock?(type)
//            })
//
        _ = rx
            .itemSelected
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[unowned self] (indexPath) in

                let type = self.hlDataSource[indexPath]
                self.itemSelectedBlock?(type)

                self.itemSelectedIndexPathBlock?(indexPath)
            })
        
        _ = rx
            .itemDeselected
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[unowned self] (indexPath) in

                let type = self.hlDataSource[indexPath]
                self.itemDeselectedBlock?(type)
                self.itemDeselectedIndexPathBlock?(indexPath)
            })
    }

    func endRefreshing() {
        self.mj_header?.endRefreshing()
        self.mj_footer?.endRefreshing()
    }

//    public func updateCell(_ indexPath: IndexPath, value: HLCellType) {
//
//        var item = self.items.value[safe: indexPath.section]?.items[safe: indexPath.row]
//        item = value
//        tableView.reloadItemsAtIndexPaths([indexPath], animationStyle: .none)
//    }
    
    public func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        if let view = view as? UITableViewHeaderFooterView {
            if #available(iOS 14.0, *) {
                view.backgroundConfiguration = UIBackgroundConfiguration.clear()
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    public func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
        if let view = view as? UITableViewHeaderFooterView {
            if #available(iOS 14.0, *) {
                view.backgroundConfiguration = UIBackgroundConfiguration.clear()
            } else {
                // Fallback on earlier versions
            }
        }
    }
        
    /// Cell 高度
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if let block = calculateCellHeightBlock, let height = block(indexPath) {
            return height
        }
        
        return getCellHeight(indexPath)
    }
    // 获取cell的高度
    public func getCellHeight(_ indexPath: IndexPath) -> CGFloat {
        
        let item = self.items.value[safe: indexPath.section]?.items[safe: indexPath.row]
        
        return item?.cellHeight ?? 0
    }

    /// 设置Section Header
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return self.headerInSectionBlock?(section)
    }

    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.headerHeightInSectionBlock?(section) ?? 0.01
    }

    /// Footer
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        return self.footerInSectionBlock?(section)
    }

    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return self.footerHeightInSectionBlock?(section) ?? 0.01
    }
    
    /// MARK: 预加载
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        preloadBlock?(indexPath)
    }

    // 编辑状态单选多选设置
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return self.editingStyeBlock?(indexPath) ?? UITableViewCell.EditingStyle.none
    }

    open func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        return self.editingActionsBlock?(indexPath)
    }
}

extension HLTableView {
    ///Cell高度
    public func setCalculateCellHeight(_ block: HLCellCalculateHeightBlock?) -> Self {
        self.calculateCellHeightBlock = block
        return self
    }
    
    /// 样式
    public func setStyle(_ style: HLTableViewStyle) -> Self {
        self.hlStyle = style
        return self
    }
    /// Setion Header 设置
    public func setHeaderInSection(config: HLTableViewViewInSectionConfigBlock?) -> Self {
        self.headerInSectionBlock = config

        return self
    }

    public func setHeaderHeightInSection(config: HLTableViewHeightInSectionConfigBlock?) -> Self {
        self.headerHeightInSectionBlock = config
        return self
    }

    /// Footer
    public func setFooterInSection(config: HLTableViewViewInSectionConfigBlock?) -> Self {
        self.footerInSectionBlock = config
        return self
    }

    public func setFooterHeightInSection(config: HLTableViewHeightInSectionConfigBlock?) -> Self {
        self.footerHeightInSectionBlock = config
        return self
    }

    /// TableView 设置
    public func setTableViewConfig(config: ((UITableView) -> Void)) -> Self {
        config(self)
        return self
    }

    /// Cell 设置
    public func setCellConfig(config: HLTableViewCellConfigBlock?) -> Self {
        self.cellConfigBlock = config
        return self
    }

    /// 选中事件
    public func selectedAction(action: HLItemSelectedBlock?) -> Self {
        self.itemSelectedBlock = action
        return self
    }

    public func selectedIndexPathAction(action: HLItemSelectedIndexPathBlock?) -> Self {
        self.itemSelectedIndexPathBlock = action
        return self
    }
    
    public func deselectedAction(action: HLItemSelectedBlock?) -> Self {
        self.itemDeselectedBlock = action
        return self
    }

    public func deselectedIndexPathAction(action: HLItemSelectedIndexPathBlock?) -> Self {
        self.itemDeselectedIndexPathBlock = action
        return self
    }

    /// 设置刷新头部
    public func setRefreshHeader(block: CompleteBlock?, config: HLTextCellConfig? = nil) -> Self {
        self.mj_header = refreshHeader(block: block, config: config)
        return self
    }
    // 设置加载更多footer
    public func setLoardMoreFooter(block: CompleteBlock?, config: HLTextCellConfig? = nil) -> Self {

        self.mj_footer = loadMoreFooter(block: block, config: config)
        return self
    }
    
    /// 预加载设置
    public func setPreloadConfig(block: HLPreloadConfigBlock?) -> Self {
        self.preloadBlock = block
        return self
    }

    /// 注：需要创建后才能绑定，否则不会生效
    public func build() -> Self {

        initDefaultConfig()
        return self
    }
}

extension HLTableView {

    public func register(datas: [HLCellType], complete: CompleteBlock?) {

        let classTypeNames = datas.map { $0.identifier }
        let names = Set(classTypeNames)
        let cellTypes = Array(names).map { $0.identity.toClass()! }

        DispatchQueue.main.async {
            self.registerCell(cellTypes: cellTypes)
            complete?()
        }
    }
    
    public func register(sections: [SectionModel<String, HLCellType>], complete: CompleteBlock? = nil) {
        /// 注册Cell
        var classTypeNames = [String]()
        sections.forEach { (_) in
            sections.forEach({ (item) in
                classTypeNames += item.items.map { $0.identifier }
            })
        }

        /// 去重
        let names = Set(classTypeNames)
        let cellTypes = Array(names).map { $0.identity.toClass()! }
        DispatchQueue.main.async {
            self.registerCell(cellTypes: cellTypes)
            complete?()
        }
    }

    public func setItems(_ datas: [HLCellType]) -> Self {
        
        register(datas: datas) {
            self.items.accept([SectionModel(model: "list", items: datas)])
        }
        
        return self
    }
    
    public func getItem(with ip: IndexPath) -> HLCellType? {
        return items.value[safe: ip.section]?.items[safe: ip.row]
    }

    public func setSections(sections: [SectionModel<String, HLCellType>]) -> Self {

        register(sections: sections, complete: {
            self.items.accept(sections)
        })
        
        return self
    }

    public func setEditingStye(_ block: HLTableViewEditingStyleConfigBlock?) -> Self {
        editingStyeBlock = block
        return self
    }
    
    public func setEditingActions(_ block: HLTableViewEditingActionsConfigBlock?) -> Self {
        editingActionsBlock = block
        return self
    }
    
    /// 获取选中的Items
    public func getSelectedRows() -> [HLCellType] {
        
        guard let array = indexPathsForSelectedRows else {
            return []
            
        }
        var selItems = [HLCellType]()
        for ip in array {
            if let item = items.value[safe: ip.section]?.items[safe: ip.row] {
                selItems.append(item)
            }
        }
        
        return selItems
    }
}
