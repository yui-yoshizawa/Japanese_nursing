//
//  UnitMastersDomainModel.swift
//  Japanese_nursing
//
//  Created by 吉澤優衣 on 2020/11/29.
//  Copyright © 2020 吉澤優衣. All rights reserved.
//

import Foundation

/**
 * 単元のDomainModel
 */
struct UnitListDomainModel {

    var id: Int
    var japanese: String
    var vietnamese: String
    var createdAt: Date
    var updatedAt: Date
    var wordCount: Int
    var memorizedWordCount: Int

    init(entity: UnitMastersBodyEntity) {
        id = entity.id
        japanese = entity.japanese
        vietnamese = entity.vietnamese
        createdAt = entity.created_at
        updatedAt = entity.updated_at
        wordCount = entity.word_count
        memorizedWordCount = entity.memorized_word_count
    }

}
