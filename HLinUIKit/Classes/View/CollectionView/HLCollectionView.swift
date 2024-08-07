//
//  RxBaseCollectionView.swift
//  VGCLIP
//
//  Created by mac on 2019/9/9.
//  Copyright © 2019 Mojy. All rights reserved.
//
// swiftlint:disable identifier_name

import UIKit
import RxSwift
import RxCocoa
import RxDataSources
import MJRefresh

public typealias HLItemSelectedBlock = (HLCellType) -> Void
public typealias HLItemSelectedIndexPathBlock = (IndexPath) -> Void

public typealias HLCollectionViewSizeInSectionConfigBlock = (Int) -> CGSize

public typealias HLCollectionCellConfigBlock = (HLCollectionViewCell, IndexPath) -> Void

open class HLCollectionView: HLView, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate {

    public var style: HLTableViewStyle = .normal
    public var items = BehaviorRelay<[SectionModel<String, HLCellType>]>(value: [])

    public var flowlayout: UICollectionViewLayout?
    public lazy var collectionView: UICollectionView = {
        return generateCollectionView()
    }()

    public var cellEvent = PublishSubject<(tag: Int, value: Any?)>()

    fileprivate var cellConfigBlock: HLCollectionCellConfigBlock?
    fileprivate var itemSelectedBlock: HLItemSelectedBlock?
    fileprivate var itemSelectedIndexPathBlock: HLItemSelectedIndexPathBlock?
    
    fileprivate var itemDeselectedIndexPathBlock: HLItemSelectedIndexPathBlock?
    fileprivate var preloadBlock: HLPreloadConfigBlock?

    // section header/footer config
    var headerHeightInSectionBlock: HLCollectionViewSizeInSectionConfigBlock?
    var footerHeightInSectionBlock: HLCollectionViewSizeInSectionConfigBlock?

    open func generateFlowLayout() -> UICollectionViewLayout {

        return UICollectionViewFlowLayout().then { (layout) in
            layout.scrollDirection = .vertical
            layout.minimumLineSpacing = 2
            layout.minimumInteritemSpacing = 2
        }
    }

    open func generateCollectionView() -> UICollectionView {

        let fl = flowlayout ?? generateFlowLayout()

        let collectionView = UICollectionView.init(frame: bounds, collectionViewLayout: fl)

        collectionView.backgroundColor = UIColor.clear
        return collectionView
    }

    // MARK: DataSource
    lazy public var dataSource: RxCollectionViewSectionedReloadDataSource<SectionModel<String, HLCellType>> = {

        return HLCollectioViewDataSource.generateDataSource(style: self.style, eventBlock: { (cell, indexPath) in

            cell.cellEvent
                .subscribe(onNext: {[unowned self] (info) in
                    self.cellEvent.onNext(info)
                }).disposed(by: cell.disposeBag)

            self.cellConfigBlock?(cell, indexPath)
        })
    }()

    override open func initConfig() {
        super.initConfig()
    }

    override open func bindConfig() {
        super.bindConfig()

    }

    /// 缺省事件绑定，晚于bindConfig执行
    open func initDefaultConfig() {

        _ = items.asObservable()
            .do(onNext: {[unowned self] (_) in
                self.endRefreshing()
            })
            .take(until:self.rx.deallocated)
            .bind(to: collectionView.rx.items(dataSource: self.dataSource))

        _ = collectionView.rx
            .itemSelected
            .take(until:self.rx.deallocated)
            .subscribe(onNext: {[unowned self] (indexPath) in

                let type = self.dataSource[indexPath]
                self.itemSelectedBlock?(type)

                self.itemSelectedIndexPathBlock?(indexPath)
            })
        
        _ = collectionView.rx
            .itemDeselected
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[unowned self] (indexPath) in
                self.itemDeselectedIndexPathBlock?(indexPath)
            })

        _ = collectionView.rx.setDelegate(self)
    }

    /// 尺寸设置
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        if let item = self.items.value[safe: indexPath.section]?.items[safe: indexPath.row] {

            if item.cellSize.equalTo(.zero) {
                if let flowlayout = flowlayout as? UICollectionViewFlowLayout {
                    return flowlayout.itemSize
                }
                
                return .zero
            } else {
                return item.cellSize
            }
        }

        return CGSize.zero
    }
    /// 预加载
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        preloadBlock?(indexPath)
    }
    
    // MARK: UICollectionViewDelegate
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return headerHeightInSectionBlock?(section) ?? CGSize(width: kScreenW, height: 0.001)
//    }
//
//    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize {
//        return footerHeightInSectionBlock?(section) ?? CGSize(width: kScreenW, height: 0.001)
//    }
//
//    /// Setion Header
//    public func setHeaderSize(config: CollectionViewSizeInSectionConfigBlock?) -> Self {
//        self.headerHeightInSectionBlock = config
//        return self
//    }
//
//    /// Footer
//    public func setFooterSize(config: CollectionViewSizeInSectionConfigBlock?) -> Self {
//        self.footerHeightInSectionBlock = config
//        return self
//    }
//
//    // 需要注册UICollectionReusableView Header / Footer
//    public func setConfigureSupplementaryView(config: RxCollectionViewSectionedReloadDataSource<SectionModel<String, RxBaseCellType>>.ConfigureSupplementaryView?) -> Self {
//        dataSource.configureSupplementaryView = config
//        return self
//    }
}

extension HLCollectionView {

    public func register(_ datas: [HLCellType], complete: CompleteBlock?) {

        let classTypeNames = datas.map { $0.identifier }
        let names = Set(classTypeNames)
        let cellTypes = Array(names).map { $0.identity.toClass()! }

        register(cellTypes: cellTypes, complete: complete)
    }

    public func register(cellTypes: [AnyClass], complete: CompleteBlock?) {

        DispatchQueue.main.async {
            for type in cellTypes {
                self.collectionView.register(type, forCellWithReuseIdentifier: String(describing: type))
            }
            complete?()
        }
    }

    public func register(_ sections: [SectionModel<String, HLCellType>], complete: CompleteBlock? = nil) {
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
        register(cellTypes: cellTypes, complete: complete)
    }

    public func setItems(_ datas: [HLCellType]) -> Self {

        register(datas, complete: {
            self.items.accept([SectionModel(model: "list", items: datas)])
        })
        return self
    }
    
    public func getItem(with ip: IndexPath) -> HLCellType? {
        return items.value[safe: ip.section]?.items[safe: ip.row]
    }

    public func setSections(sections: [SectionModel<String, HLCellType>]) -> Self {

        register(sections, complete: {
            self.items.accept(sections)
        })

        return self
    }
    
    public func selectItem(_ ip: IndexPath, scrollPosition: UICollectionView.ScrollPosition = .top) {
        
        DispatchQueue.main.async {
            if self.items.value[safe: ip.section]?.items[safe: ip.row] == nil {
                return
            }            
            self.collectionView.selectItem(at: ip, animated: true, scrollPosition: scrollPosition)
        }
    }
    public func deselectItem(at indexPath: IndexPath) {
        DispatchQueue.main.async {
            self.collectionView.deselectItem(at: indexPath, animated: false)
        }
    }
}

extension HLCollectionView {

    public func setFlowLayout(config: (() -> (UICollectionViewLayout?))) -> Self {
        flowlayout = config()
        return self
    }

    public func setCollectionViewConfig(config: ((UICollectionView) -> Void)) -> Self {

        config(collectionView)
        return self
    }

    public func invalidateLayout() -> Self {
        collectionView.collectionViewLayout.invalidateLayout()
        return self
    }

    public func setCellConfig(config: HLCollectionCellConfigBlock?) -> Self {
        self.cellConfigBlock = config
        return self
    }

    public func selectedAction(action: HLItemSelectedBlock?) -> Self {
        self.itemSelectedBlock = action
        return self
    }

    public func selectedIndexPathAction(action: HLItemSelectedIndexPathBlock?) -> Self {
        self.itemSelectedIndexPathBlock = action
        return self
    }
    
    public func deselectedIndexPathAction(action: HLItemSelectedIndexPathBlock?) -> Self {
        self.itemDeselectedIndexPathBlock = action
        return self
    }
    
    public func build() -> Self {

        addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }

        initDefaultConfig()
        return self
    }
}

extension HLCollectionView {

    func endRefreshing() {
        self.collectionView.mj_header?.endRefreshing()
        self.collectionView.mj_footer?.endRefreshing()
    }
    
    /// 预加载设置
    public func setPreloadConfig(block: HLPreloadConfigBlock?) -> Self {
        self.preloadBlock = block
        return self
    }

    /// 设置刷新头部
    public func setRefreshHeader(block: CompleteBlock?, config: HLTextCellConfig? = nil) -> Self {
        self.collectionView.mj_header = refreshHeader(block: block, config: config)
        return self
    }
    // 设置加载更多footer
    public func setLoardMoreFooter(block: CompleteBlock?, config: HLTextCellConfig? = nil) -> Self {

        self.collectionView.mj_footer = loadMoreFooter(block: block, config: config)
        return self
    }

    func refreshHeader(block: CompleteBlock?, config: HLTextCellConfig? = nil) -> MJRefreshStateHeader {

        let header = MJRefreshNormalHeader.init(refreshingBlock: {[weak self] in

            if (self?.collectionView.mj_footer) != nil {
                self?.collectionView.mj_footer?.resetNoMoreData()
            }

            self?.collectionView.mj_footer?.resetNoMoreData()
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
}
