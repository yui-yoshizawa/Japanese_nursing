//
//  GetWordMastersModel.swift
//  Japanese_nursing
//
//  Created by 吉澤優衣 on 2020/11/29.
//  Copyright © 2020 吉澤優衣. All rights reserved.
//

import APIKit
import Foundation
import RxSwift

/**
 * 単語一覧取得
 */
public struct GetWordMastersModel {

    public init() {
    }

    /**
     * 単語一覧取得
     * - Parameters:
     *   - authToken: 認証トークン
     *   - unitMasterId: 単元マスタID
     * - Returns: 単語一覧取得Entity Observable
     */
    public func getWordMasters(authToken: String, unitMasterId: Int) -> Observable<GetWordMastersResponse.Entity> {

        return Observable.create({ observer in

            let req = GetWordMastersRequest(authToken: authToken, unitMasterId: unitMasterId)

            let task = Session.send(req) {
                switch $0 {
                case .success(let response):
                    guard let entity = response.object else {
                        observer.on(.error(APIError.entityNotExist))
                        return
                    }
                    observer.on(.next(entity))
                    observer.on(.completed)
                case .failure(let error):
                    observer.on(.error(error))
                }
            }
            return Disposables.create {
                task?.cancel()
            }
        })
    }

}
