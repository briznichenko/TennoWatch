//
//  Surface.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/2/26.
//

import SwiftUI

struct Surface<Content: View>: View {
    // MARK: - Object Properties
    @ViewBuilder var content: Content

    // MARK: - Body
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
