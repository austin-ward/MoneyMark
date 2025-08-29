//
//  Persistence.swift
//  MoneyMark
//
//  Created by Austin on 8/29/25.
//

import Foundation

enum Persistence {
    private static var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static func url(for filename: String) -> URL {
        documentsURL.appendingPathComponent(filename)
    }

    static func saveJSON<T: Encodable>(_ value: T, to filename: String) throws {
        let url = Self.url(for: filename)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601
        let data = try encoder.encode(value)
        try data.write(to: url, options: .atomic)
    }

    static func loadJSON<T: Decodable>(_ type: T.Type, from filename: String, default defaultValue: T) -> T {
        let url = Self.url(for: filename)
        guard let data = try? Data(contentsOf: url) else { return defaultValue }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return (try? decoder.decode(T.self, from: data)) ?? defaultValue
    }
}
