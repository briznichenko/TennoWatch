//
//  ThemedList.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import SwiftUI

extension View {
    func themedList() -> some View {
        self
            .scrollContentBackground(.hidden)
            .background(Color.bg)
            .listRowBackground(Color.surface)
            .listRowSeparatorTint(.divider)
    }
}
