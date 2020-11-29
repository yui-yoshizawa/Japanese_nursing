//
//  UnitListSectionModel.swift
//  Japanese_nursing
//
//  Created by 吉澤優衣 on 2020/11/29.
//  Copyright © 2020 吉澤優衣. All rights reserved.
//

import Foundation
import RxDataSources

/// 単元一覧用 セクションモデルプロトコル
protocol UnitListSectionDomainModelProtocol: SectionModelType {

    var items: [Item] { get set }

    init?(items: [Item])

}

// SectionModelTypeに準拠した初期化
extension UnitListSectionDomainModelProtocol {

    init(original: Self, items: [Self.Item]) {
        self = original
        self.items = items
    }

}

/// 単元一覧用 セクションモデルプロトコル
struct UnitListSectionDomainModel: UnitListSectionDomainModelProtocol {

    typealias Item = UnitListDomainModel

    var items: [UnitListDomainModel]

    init(items: [Item]) {
        self.items = items
    }

}
