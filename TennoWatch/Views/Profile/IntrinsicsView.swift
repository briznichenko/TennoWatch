//
//  IntrinsicsView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/15/26.
//

import SwiftUI

struct IntrinsicsView: View {
    // MARK: - Object Properties
    let groups: [IntrinsicGroup]

    // MARK: - Body
    var body: some View {
        List {
            ForEach(groups) { group in
                Section {
                    ForEach(group.intrinsics) { intrinsic in
                        IntrinsicRowView(intrinsic: intrinsic)
                    }
                } header: {
                    SectionHeaderLabel(group.name)
                }
            }
        }
        .themedList()
        .navigationTitle(Strings.Profile.intrinsicsTitle)
        .navigationBarTitleDisplayMode(.inline)
    }
}
