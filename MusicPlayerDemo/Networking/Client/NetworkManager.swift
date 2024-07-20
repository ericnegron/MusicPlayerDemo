//
//  NetworkManager.swift
//  MusicPlayerDemo
//
//  Created by Eric Negron on 5/21/24.
//

import Foundation


class NetworkManager {
    
    
    // MARK: - Shared
    static let shared = NetworkManager()
    
    
    // MARK: - Constants
    struct Constants {
        let authEndpoint = "https://accounts.spotify.com/authorize"
        let baseEndpoint =  "https://api.spotify.com/v1/"
        let tokenEndpoint = "https://accounts.spotify.com/api/token"
        let redirectURI = "https://www.google.com"
        
        let scopes = "user-read-private%20playlist-read-private%20playlist-modify-private%20playlist-modify-public%20user-read-recently-played%20user-top-read%20user-library-modify%20user-library-read"
    }
    
    // MARK: - Init
    private init() {}
    
    
    
}
