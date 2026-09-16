//
//  String+Ex.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import Foundation

extension String {
    var sentenceCased: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }

    var nodeNameAndPlanet: (name: String, planet: String?) {
        guard let openParen = lastIndex(of: "("), let closeParen = lastIndex(of: ")"), openParen < closeParen else {
            return (self, nil)
        }
        let name = self[..<openParen].trimmingCharacters(in: .whitespaces)
        let planet = String(self[index(after: openParen)..<closeParen])
        return (name, planet)
    }

    var spacedByCamelCase: String {
        let base = components(separatedBy: "/").last ?? self
        var result = ""
        for character in base {
            if let last = result.last {
                let isNewWord = (character.isUppercase && last.isLowercase)
                    || (character.isNumber && last.isLetter)
                    || (character.isLetter && last.isNumber)
                if isNewWord {
                    result.append(" ")
                }
            }
            result.append(character)
        }
        return result.sentenceCased
    }
}
