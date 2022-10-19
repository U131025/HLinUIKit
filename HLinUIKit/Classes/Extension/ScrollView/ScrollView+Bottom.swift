//
//  ScrollView+Bottom.swift
//  HLinUIKit
//
//  Created by 屋联-神兽 on 2022/10/14.
//

import Foundation
import RxSwift
import RxCocoa

public extension Reactive where Base: UIScrollView  {
     
    //视图滚到底部检测序列
    var reachedBottom: Signal<Bool> {
        return contentOffset.asDriver()
            .flatMap { [weak base] contentOffset -> Signal<Bool> in
                guard let scrollView = base else {
                    return Signal.empty()
                }
                 
                //可视区域高度
                let visibleHeight = scrollView.frame.height - scrollView.contentInset.top
                    - scrollView.contentInset.bottom
                //滚动条最大位置
                let threshold = max(0.0, scrollView.contentSize.height - visibleHeight)
                //如果当前位置超出最大位置则发出一个事件
                let y = contentOffset.y + scrollView.contentInset.top
                return y >= threshold ? Signal.just(true) : Signal.just(false)
//                return y > threshold ? Signal.just(()) : Signal.empty()
        }
    }
}
