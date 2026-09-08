//
//  View+Styling.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/2/26.
//

import SwiftUI

struct Surface<Content: View>: View {
    @ViewBuilder var content: Content
    var body: some View {
        content
            .padding(12)
            .background(.surface, in: .rect(cornerRadius: 10))
    }
}

extension View {
    func screenBackground() -> some View {
        self.scrollContentBackground(.hidden).background(.bg)
    }
}
