//
//  AuthManager.swift
//  MusicPlayerDemo
//
//  Created by Eric Negron on 5/21/24.
//

import Foundation

@MainActor
class AuthManager {

    // MARK: - Shared
    static let shared = AuthManager()
    
    
    // MARK: - Init
    private init() {}
    
    
    // MARK: - Public
    public var signInURL: URL? {
        let urlString = "\(NetworkManager.Constants().authEndpoint)?response_type=code&client_id=\(clientId)&scope=\(NetworkManager.Constants().scopes)&redirect_uri=\(NetworkManager.Constants().redirectURI)&show_dialog=TRUE"
        return URL(string: urlString)
    }
    
    public var isSignedIn: Bool {
        return accessToken != nil
    }
    
    // MARK: - Private
    private var clientId: String {
        guard let clientId = ProcessInfo.processInfo.environment["CLIENT_ID"] else {
            fatalError("Unable to retrieve client id")
        }
        return clientId
    }
    
    private var clientSecret: String {
        guard let clientSecret = ProcessInfo.processInfo.environment["CLIENT_SECRET"] else {
            fatalError("Unable to retrieve client secret")
        }
        return clientSecret
    }
    
    private var accessToken: String? {
        return KeychainWrapper.shared.getToken(forKey: "access_token")
    }
    
    private var refreshToken: String? {
        return KeychainWrapper.shared.getToken(forKey: "refresh_token")
    }
    
    private var tokenExpirationDate: Date? {
        return UserDefaults.standard.object(forKey: "expirationDate") as? Date
    }
    
    private var shouldRefreshToken: Bool {
        guard let expirationDate = tokenExpirationDate else {
            return false
        }
        let currentDate = Date()
        let fiveMin: TimeInterval = 300
        return currentDate.addingTimeInterval(fiveMin) >= expirationDate
    }
    
    private var refreshTask: Task<String, Error>?
    
    
    // MARK: - Requests
    public func exchangeCodeForToken(code: String) async throws {
        guard let url = URL(string: NetworkManager.Constants().tokenEndpoint) else {
            throw AuthError.invalidURL
        }
        
        let basicToken = clientId + ":" + clientSecret
        let basicTokenData = basicToken.data(using: .utf8)
        guard let basicTokenDataString = basicTokenData?.base64EncodedString() else {
            throw AuthError.dataConversionError
        }
        
        // Request header, body
        var bodyComponents = URLComponents()
        bodyComponents.queryItems = [
            URLQueryItem(name: "grant_type", value: "authorization_code"),
            URLQueryItem(name: "code", value: code),
            URLQueryItem(name: "redirect_uri", value: NetworkManager.Constants().redirectURI),
            URLQueryItem(name: "client_id", value: clientId)
        ]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.setValue("Basic \(basicTokenDataString)", forHTTPHeaderField: "Authorization")
        request.httpBody = bodyComponents.query?.data(using: .utf8)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
            throw AuthError.invalidResponse
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        do {
            let results = try decoder.decode(AuthResponse.self, from: data)
            try storeToken(result: results)
        } catch {
            throw AuthError.unableToDecode
        }
        
    }
    
    
    // MARK: - Helpers
    func validToken() async throws -> String {
        if let handleRefreshTask = refreshTask {
            return try await handleRefreshTask.value
        }
        
        guard let token = accessToken else {
            throw AuthError.missingToken
        }
        
        if !shouldRefreshToken {
            return token
        }
        
        return try await refreshTokenIfNeeded()
    }
    
    func refreshTokenIfNeeded() async throws -> String {
        if let refreshTask = refreshTask {
            return try await refreshTask.value
        }
        
        guard let refreshToken = self.refreshToken else {
            throw AuthError.missingRefreshToken
        }
        
        // Construct Request
        guard let url = URL(string: NetworkManager.Constants().tokenEndpoint) else {
            throw AuthError.invalidURL
        }
        
        var components = URLComponents()
        components.queryItems = [
            URLQueryItem(name: "grant_type", value: "refresh_token"),
            URLQueryItem(name: "refresh_token", value: refreshToken),
            URLQueryItem(name: "client_id", value: clientId)
        ]
        
        
        
        let task = Task { () throws -> String in
            defer { refreshTask = nil }
            
            // Refresh token here
            let request = try? basicAuthRequest(url: url, components: components)
            let (data, response) = try await URLSession.shared.data(for: request!)
            
            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                throw AuthError.invalidResponse
            }
            
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            
            do {
                let result = try decoder.decode(AuthResponse.self, from: data)
                try storeToken(result: result)
            } catch {
                throw AuthError.unableToDecode
            }
            
            return ""
        }
        
        refreshTask = task
        
        return try await task.value
    }
    
    private func basicAuthRequest(url: URL, components: URLComponents) throws  -> URLRequest {
        let basicToken = clientId + ":" + clientSecret
        let data = basicToken.data(using: .utf8)
        guard let dataString = data?.base64EncodedString() else {
            throw AuthError.dataConversionError
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "content-type")
        request.setValue("Basic \(dataString)", forHTTPHeaderField: "Authorization")
        request.httpBody = components.query?.data(using: .utf8)
        
        return request
    }
    
    // MARK: - Keychain
    private func storeToken(result: AuthResponse) throws {
        // access token
        do {
            try KeychainWrapper.shared.storeToken(result.accessToken, forKey: "access_token")
        } catch {
            throw AuthError.missingToken
        }

        // refresh token
        do {
            try KeychainWrapper.shared.storeToken(result.refreshToken, forKey: "refresh_token")
        } catch {
            throw AuthError.missingRefreshToken
        }
        
        // expiration
        UserDefaults.standard.setValue(Date().addingTimeInterval(TimeInterval(result.expiresIn)), forKey: "expirationDate")
    }
}
