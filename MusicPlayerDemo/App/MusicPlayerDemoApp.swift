//
//  MusicPlayerDemoApp.swift
//  MusicPlayerDemo
//
//  Created by Eric Negron on 5/21/24.
//

import SwiftUI
import MusicKit

@main
struct MusicPlayerDemoApp: App {
    var body: some Scene {
        WindowGroup {
            
            // TODO:  need to handle sign in for spotify vs apple
            
            if AuthManager.shared.isSignedInSpotify {
                // TODO: go to main tab
            } else {
                SignInView()
            }
            
            
//            ContentView()
//                .task {
//                    let authStatus = await MusicAuthorization.request()
//                    print(authStatus)
//                }
        }
    }
}
