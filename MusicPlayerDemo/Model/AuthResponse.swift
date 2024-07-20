//
//  AuthResponse.swift
//  MusicPlayerDemo
//
//  Created by Eric Negron on 5/24/24.
//

import Foundation


struct AuthResponse: Decodable {
    let accessToken: String
    var refreshToken: String
    var expiresIn: Int
    var scope: String
    var tokenType: String
    
}
