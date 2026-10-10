//
//  ThemedList.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import SwiftUI

struct ThemedList<Content: View>: View {
    @ViewBuilder var content: Content

    var body: some View {
        List {
            content
                .listRowBackground(Color.surface)
        }
        .themedList()
    }
}

extension View {
    func themedList() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Color.bg)
            .listRowBackground(Color.surface)
            .listRowSeparatorTint(.divider)
            .foregroundStyle(Color.labelPrimary)
            .tint(Color.accent)
    }
}
