//
//  ToModelExtension.swift
//  ZhiHu+RxSwift
//
//  Created by like on 2017/1/28.
//  Copyright © 2017年 like. All rights reserved.
//

import Foundation
import RxSwift
import SmartCodable

extension ObservableType where Element == Any {

    public func mapModel<T: SmartCodable>(_ type: T.Type, handleError: Bool = true) -> Observable<T> {

        return flatMap({ (base) -> Observable<T> in

            if let jsonString = base as? String {
                return jsonString.mapModel(T.self)
            } else if let jsonData = base as? Data {
                if let jsonString = String.init(data: jsonData, encoding: .utf8) {
                    return jsonString.mapModel(T.self)
                }
            }

            return Observable.error(RxError.noElements)
        })
    }

}

public extension String {

    func mapModel<T: SmartCodable>(_ type: T.Type) -> Observable<T> {

        if let model = T.deserialize(from: self) {
            return Observable.just(model)
        }
        return Observable.error(RxError.noElements)
    }
    
    func mapToModel<T: SmartCodable>(_ type: T.Type) -> T? {
        return T.deserialize(from: self)
    }
}
