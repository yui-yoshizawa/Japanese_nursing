//
//  LearningUnitDomainModel.swift
//  Japanese_nursing
//
//  Created by 吉澤優衣 on 2020/11/29.
//  Copyright © 2020 吉澤優衣. All rights reserved.
//

import Foundation

/**
 * 学習単語のDomainModel
 */
struct LearningUnitDomainModel {

    var id: Int
    var unitMasterId: Int
    var furigana: String
    var japanese: String
    var english: String
    var vietnamese: String
    var createdAt: Date
    var updatedAt: Date
    var isLearned: Bool

    init(entity: WordMastersBodyEntity) {
        id = entity.id
        unitMasterId = entity.unit_master_id
        furigana = entity.furigana
        japanese = entity.japanese
        english = entity.english
        vietnamese = entity.vietnamese
        createdAt = entity.created_at
        updatedAt = entity.updated_at
        isLearned = entity.is_learned
    }

}
