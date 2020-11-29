//
//  GetWordMasters.swift
//  Japanese_nursing
//
//  Created by 吉澤優衣 on 2020/11/29.
//  Copyright © 2020 吉澤優衣. All rights reserved.
//

import APIKit
import Foundation

/**
 * 単語一覧取得API Request.
 */
public struct GetWordMastersRequest: JapaneseNursingRequest {

    /// 認証トークン
    private var authToken: String
    /// 単元マスタID
    private var unitMasterId: Int

    /// init and set query parameters.
    public init(authToken: String, unitMasterId: Int) {
        self.authToken = authToken
        self.unitMasterId = unitMasterId
    }

    // MARK: APIKit.Request
    public typealias Response = GetWordMastersResponse

    public var method: HTTPMethod {
        return .get
    }

    public var path: String {
        return makePath(path: "/word_masters/")
    }

    /// The actual parameters.
    public var parameters: Any? {
        var params = parametersWithToken
        params["auth_token"] = authToken
        params["unit_master_id"] = authToken
        return params
    }

}

/**
 * 学習単語取得API Response
 */
public struct GetWordMastersResponse: JapaneseNursingResponse {

    public typealias Entity = WordMastersEntity

    public let result: Bool

    public let message: String

    public let object: Entity?

    public let error_code: Int?

}
