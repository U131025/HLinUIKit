//
//  HLDragTableView.swift
//  HLinUIKit
//
//  Created by 屋联-神兽 on 2021/12/2.
//

import Foundation
import RxSwift
import RxCocoa
import RxDataSources

public struct HLAnimatablSection {
    var model: String
    var datas: [HLBaseAnimatabItem]

    init(model: String, items: [HLBaseAnimatabItem]) {
        self.model = model
        self.datas = items
    }
}

extension HLAnimatablSection
    : AnimatableSectionModelType {
    public typealias Item = HLBaseAnimatabItem
    public typealias Identity = String

    public var identity: String {
        return model
    }

    public var items: [HLBaseAnimatabItem] {
        return datas
    }

    public init(original: HLAnimatablSection, items: [Item]) {
        self = original
        self.datas = items
    }
}

open class HLBaseAnimatabItem: NSObject, HLCellType, IdentifiableType, Identifiable {
   
    public var hlTag: Int = 0
    public var hlCellType: AnyClass?
    public var hlCellHeight: CGFloat = 44
    public var hlContent: Any?

    public typealias Identity = Int
    public var identity: Int {
        return hlTag
    }

    public static func ==(l: HLBaseAnimatabItem, r: HLBaseAnimatabItem)-> Bool {
        return l.identity == r.identity
    }
    
    open var cellClass: AnyClass {
        return hlCellType ?? HLTableViewCell.self
    }
    
    open var cellHeight: CGFloat {
        return hlCellHeight
    }
    
    open var cellData: Any? {
        return hlContent
    }
    
    public override init() {
        
    }
}

open class HLAnimTableView: HLTableView {
    
    public var animItems = BehaviorRelay<[HLAnimatablSection]>(value: [])
    
    public lazy var hlAnimDataSource: RxTableViewSectionedAnimatedDataSource<HLAnimatablSection> = {
       
        return RxTableViewSectionedAnimatedDataSource<HLAnimatablSection>(
            animationConfiguration: AnimationConfiguration(insertAnimation: .top,
                                                                   reloadAnimation: .fade,
                                                                   deleteAnimation: .left),
            configureCell: { _, tableView, indexPath, item in
                let identifier = "\(item.identity)"
                guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier) as? HLTableViewCell ?? item.identifier.toHLCell() else {
                    print("Error: 没有注册BaseCell(\(item.identifier))")
                    return UITableViewCell.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: item.identifier)
                }
                if cell.isKind(of: HLTableViewCell.self) {
                    cell.data = item.cellData
                    
                    self.cellConfigBlock?(cell, indexPath)
                    cell.cellEvent
                        .subscribe(onNext: {[unowned self] (info) in
                            self.cellEvent.onNext(info)
                        }).disposed(by: cell.disposeBag)
                    
                } else {
                    print("Not BaseCellType")
                }
                return cell
            },
//            titleForHeaderInSection: { ds, section -> String? in
//                return ds[section].header
//            },
            canEditRowAtIndexPath: { _, _ in
                return true
            },
            canMoveRowAtIndexPath: { _, _ in
                return true
            }
        )
    }()
    
    open override func initDefaultConfig() {
        _ = animItems.asObservable()
            .do(onNext: {[unowned self] (_) in
                self.endRefreshing()
            })
            .take(until: rx.deallocated)
            .bind(to: rx.items(dataSource: hlAnimDataSource))
                
        _ = rx
            .itemSelected
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[unowned self] (indexPath) in

                let type = self.hlAnimDataSource[indexPath]
                self.itemSelectedBlock?(type)
                self.itemSelectedIndexPathBlock?(indexPath)
            })
        
        _ = rx
            .itemDeselected
            .take(until: self.rx.deallocated)
            .subscribe(onNext: {[unowned self] (indexPath) in

                let type = self.hlAnimDataSource[indexPath]
                self.itemDeselectedBlock?(type)
                self.itemDeselectedIndexPathBlock?(indexPath)
            })
    }
    
    public func setAnimItmes(_ datas: [HLBaseAnimatabItem]) -> Self {
        animItems.accept([HLAnimatablSection(model: "list", items: datas)])
        return self
    }
    
    public func setAnimSections(sections: [HLAnimatablSection]) -> Self {

        animItems.accept(sections)
        return self
    }
}
