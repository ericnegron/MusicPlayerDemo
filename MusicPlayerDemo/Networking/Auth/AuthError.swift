//
//  AuthError.swift
//  MusicPlayerDemo
//
//  Created by Eric Negron on 5/21/24.
//

import Foundation

enum AuthError: Error {
    case missingToken
    case invalidURL
    case dataConversionError
    case invalidResponse
    case unableToDecode
    case missingRefreshToken
}
