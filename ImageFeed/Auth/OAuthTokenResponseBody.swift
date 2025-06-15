//
//  OAuthTokenResponseBody.swift
//  ImageFeed
//
//  Created by Сергей Розов on 12.06.2025.
//

import Foundation

struct OAuthTokenResponseBody: Codable {
    let accessToken: String
    
    enum CodingKeys: String, CodingKey {
            case accessToken = "access_token"
    }
}
