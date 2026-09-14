//
//  String+Ex.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

extension String {
    var sentenceCased: String {
        guard let first else { return self }
        return first.uppercased() + dropFirst()
    }
}
