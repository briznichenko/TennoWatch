//
//  URL+Ex.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/26/26.
//

import Foundation

extension URL {
    init(_ staticString: StaticString) {
        guard let url = URL(string: "\(staticString)") else {
            preconditionFailure("Invalid static URL string: \(staticString)")
        }
        self = url
    }
}
