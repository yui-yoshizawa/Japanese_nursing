//
//  CreateUserDomainModel.swift
//  Japanese_nursing
//
//  Created by 吉澤優衣 on 2020/11/22.
//  Copyright © 2020 吉澤優衣. All rights reserved.
//

import Foundation

/**
 * ユーザ作成のDomainModel
 */
struct CreateUserDomainModel {

    /// ユーザID
    var id: Int
    var email: String?
    var createdAt: Date
    var updatedAt: Date
    var authToken: String
    var userName: String
    var role: String
    var roleEnum: CreateUserEntity.Role

    init(entity: CreateUserEntity) {
        id = entity.id
        email = entity.email
        createdAt = entity.created_at
        updatedAt = entity.updated_at
        authToken = entity.auth_token
        userName = entity.user_name
        role = entity.role
        roleEnum = entity.role_enum
    }

}