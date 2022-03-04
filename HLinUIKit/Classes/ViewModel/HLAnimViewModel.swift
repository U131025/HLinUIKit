//
//  HLAnimViewModel.swift
//  HLinUIKit
//
//  Created by 屋联-神兽 on 2021/12/3.
//

import Foundation
import RxSwift
import RxCocoa

open class HLAnimViewModel: HLViewModel {
    
    public var animItems = BehaviorRelay<[HLAnimatablSection]>(value: [])
    
    public func getAnimItemValue(with ip: IndexPath) -> HLBaseAnimatabItem? {
        return animItems.value[safe: ip.section]?.datas[safe: ip.row]
    }

    public func setAnimItems(_ datas: [HLBaseAnimatabItem]) -> Self {
        animItems.accept([HLAnimatablSection(model: "list", items: datas)])
        return self
    }

    public func setSections(sections: [HLAnimatablSection]) -> Self {
        animItems.accept(sections)
        return self
    }
}
