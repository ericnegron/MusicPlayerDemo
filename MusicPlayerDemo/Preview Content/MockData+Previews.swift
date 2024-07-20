//
//  MockData+Previews.swift
//  MusicPlayerDemo
//
//  Created by Eric Negron on 5/21/24.
//

import Foundation


@Observable class MockData {
    // Load mock data here
}


func load<T: Decodable>(_ filename: String) -> T {
    let data: Data
    
    guard let file = Bundle.main.url(forResource: filename, withExtension: nil) else {
        fatalError("Couldn't find \(filename) in main bundle.")
    }
    
    do {
        data = try Data(contentsOf: file)
    } catch {
        fatalError("Couldn't load \(filename) from main bundle:\n\(error)")
    }
    
    do {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(T.self, from: data)
    } catch {
        
        debugPrint("Error parsing file with error: \(error)")
        fatalError("Couldn't parse \(filename) as \(T.self):\n\(error.localizedDescription)")
    }
}
