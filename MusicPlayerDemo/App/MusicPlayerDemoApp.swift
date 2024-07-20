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
            ContentView()
                .task {
                    let authStatus = await MusicAuthorization.request()
                    print(authStatus)
                }
        }
    }
}
