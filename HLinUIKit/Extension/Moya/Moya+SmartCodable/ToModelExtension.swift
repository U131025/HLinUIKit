//
//  ToModelExtension.swift
//  ZhiHu+RxSwift
//
//  Created by like on 2017/1/28.
//  Copyright © 2017年 like. All rights reserved.
//

import Foundation
import RxSwift
import Moya
import SmartCodable

extension ObservableType where Element: TargetType {

    public func request() -> Observable<Response> {

        return flatMap { target -> Observable<Response> in

            let source = target.request().storeCachedResponse(for: target).asObservable()
            if let response = target.cachedResponse {
                return Observable.just(response)
            }
            return source
        }
    }
}

extension ObservableType where Element == Response {

    public func mapModel<T: SmartCodable>(_ type: T.Type, handleError: Bool = true) -> Observable<T> {
        return flatMap { response -> Observable<T> in

            return Observable.just(response.mapModel(T.self, handleError))
        }
    }
}

public extension Response {

    func mapModel<T: SmartCodable>(_ type: T.Type, _ handleError: Bool) -> T {

        let jsonString = String.init(data: data, encoding: .utf8)

        guard T.deserialize(from: jsonString) != nil else {
            return T()
        }

        if let model = T.deserialize(from: jsonString) {
            return model
        }

        return T()
    }
}
