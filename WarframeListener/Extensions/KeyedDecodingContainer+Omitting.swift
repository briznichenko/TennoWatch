//
//  KeyedDecodingContainer+Omitting.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/13/26.
//

import Foundation

@propertyWrapper
struct Omitted<T: Hashable>: Codable, Hashable {
    var wrappedValue: T?

    init(from decoder: Decoder) throws {
        self.wrappedValue = nil
    }

    func encode(to encoder: Encoder) throws {}

    init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }
}

extension KeyedDecodingContainer {
    func decode<T>(_ type: Omitted<T>.Type, forKey key: KeyedDecodingContainer<K>.Key) throws -> Omitted<T> {
        return Omitted(wrappedValue: nil)
    }
}
