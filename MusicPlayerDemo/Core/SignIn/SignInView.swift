//
//  SignInView.swift
//  MusicPlayerDemo
//
//  Created by Eric Negron on 7/20/24.
//

import SwiftUI

struct SignInView: View {
    
    @State private var isShowingAuthWeb = false
    
    var body: some View {
        
        NavigationStack {
            
            VStack {
                
                Image(systemName: "music.quarternote.3")
                    .resizable()
                    .frame(width: 100, height: 100)
                    .foregroundStyle(.pink)
                    .scaledToFit()
                
                Text("Sign In")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding()
                
                // Singin With Spotify
                Button(action: {
                    // TODO: Implement spotify signin
                }, label: {
                    HStack {
                        Image("Spotify_Icon_RGB_White")
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Sign In With Spotify")
                    }
                    
                })
                .font(.title3)
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.white)
                .background(.green)
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .padding([.top, .leading, .trailing])
                .sheet(isPresented: $isShowingAuthWeb, onDismiss: {
                    // TODO: handle signin
                }, content: {
                    // TODO: add web signin view
                })
                
                // Signin With Apple
                Button(action: {
                    // TODO: Implement Apple Sigin
                }, label: {
                    Label("Sign In With Apple", systemImage: "apple.logo")
                })
                .font(.title3)
                .fontWeight(.heavy)
                .frame(maxWidth: .infinity)
                .padding()
                .foregroundStyle(.white)
                .background(LinearGradient(colors: [.pink, .purple], startPoint: .leading, endPoint: .trailing))
                .clipShape(RoundedRectangle(cornerRadius: 40))
                .padding()
            }
            
        }
    }
}

#Preview {
    SignInView()
}
