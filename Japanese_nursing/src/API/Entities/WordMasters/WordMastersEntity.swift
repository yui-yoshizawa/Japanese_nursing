//
//  WordMastersEntity.swift
//  Japanese_nursing
//
//  Created by 吉澤優衣 on 2020/11/29.
//  Copyright © 2020 吉澤優衣. All rights reserved.
//

import Foundation

/**
 * 単語一覧Entity
 */
public struct WordMastersEntity: Codable {

    public let word_masters: [WordMastersBodyEntity]
    public let total_count: Int

}

public struct WordMastersBodyEntity: Codable {

    public let id: Int
    public let unit_master_id: Int
    public let furigana: String
    public let japanese: String
    public let english: String
    public let vietnamese: String
    public let created_at: Date
    public let updated_at: Date
    public let is_learned: Bool

}
