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

    /// Turns a path-like or camelCase identifier (e.g. "/Lotus/Weapons/Kunai" or "ClanNode1")
    /// into a spaced, sentence-cased display string (e.g. "Kunai", "Clan Node 1").
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
