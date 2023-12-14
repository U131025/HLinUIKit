//
//  HLVerticalViewsCell.swift
//  HLinUIKit
//
//  Created by 屋联-神兽 on 2023/10/9.
//

import UIKit

public class HLVerticalViewsConfig: NSObject, HLCellType {
    public var tag: Int = 0
    public var items = [HLCellType]()
    public var cell: AnyClass?
    public var bgColor: UIColor?
    public var bgEdgeInsets: UIEdgeInsets?
    public var cornerRadius: CGFloat?
    public var extData: Any?
    
    public convenience init(items: [HLCellType]) {
        self.init()
        self.items = items
    }
    
    public var cellClass: AnyClass {
        return cell ?? HLVerticalViewsCell.self
    }
    
    public var cellHeight: CGFloat {
        return HLVerticalViewsCell.calculateCellHeight(items)
    }
}

open class HLVerticalViewsCell: HLTableViewCell {
    
    public var tableViewCellConfigBlock: HLTableViewCellConfigBlock?
    public var collectionViewCellConfigBlock: HLCollectionViewCellConfigBlock?
 
    open override func initConfig() {
        super.initConfig()
        
    }
        
    open override func updateData() {
        if let datas = data as? [HLCellType] {
            setupViews(datas)
        } else if let config = data as? HLVerticalViewsConfig {
            setupViews(config.items)
            
            if let color = config.bgColor {
                bodyView.backgroundColor = color
            }
            if let insets = config.bgEdgeInsets {
                setItemInsert(insert: insets)
            }
            if let cornerRadius = config.cornerRadius {
                bodyView.layer.cornerRadius = cornerRadius
                bodyView.layer.masksToBounds = true
            }
        }
    }
    
    open func setupViews(_ datas: [HLCellType]) {
        for view in bodyView.subviews {
            view.removeFromSuperview()
        }
        var preView: UIView?
        for (index, item) in datas.enumerated() {
            let height = item.cellHeight
            if let view = item.createView() {
                
                if let cell = view as? HLTableViewCell {
                    self.tableViewCellConfigBlock?(cell, IndexPath(row: index, section: 0))
                    cell.cellEvent.bind(to: self.event).disposed(by: cell.disposeBag)
                    
                    if let _ = cell as? HLCollectionsTableViewCell {
                        
                    } else if let _ = cell as? HLListTableViewCell {
                        
                    } else if let _ = cell as? HLCustomTableViewCell {
                        
                    } else {
                        view.rx.tapGesture().when(.recognized)
                            .subscribe(onNext: {[weak self] _ in
                                self?.selectedAction(item)
                            })
                            .disposed(by: cell.disposeBag)
                    }
                                            
                } else if let cell = view as? HLCollectionViewCell {
                    self.collectionViewCellConfigBlock?(cell, IndexPath(row: index, section: 0))
                    cell.cellEvent.bind(to: self.event).disposed(by: cell.disposeBag)
                }
                
                var offsetY: CGFloat = 0
                if let preView = preView {
                    offsetY = preView.frame.maxY
                }

                view.frame = CGRect(x: 0, y: offsetY, width: kScreenW, height: height)
                
                bodyView.addSubview(view)
                view.snp.makeConstraints { make in
                    make.left.right.equalToSuperview()
                    make.top.equalTo(offsetY)
                    make.height.equalTo(height)
                }
                
//                bodyView.contentSize = CGSize(width: kScreenW, height: view.frame.maxY)
                preView = view
            }
        }
    }
    
    open func selectedAction(_ type: HLCellType) {
        self.cellEvent.onNext((tag: 0, value: type))
    }
    
    public func setItemInsert(insert: UIEdgeInsets) {
        bodyView.snp.remakeConstraints { (make) in
            make.edges.equalToSuperview().inset(insert)
        }
    }
    
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
