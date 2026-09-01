//
//  CategoryView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/29/26.
//

import SwiftUI

struct CategoryView: View {
    let catalog: Catalog
    
    var body: some View {
        HStack {
            Text(catalog.category.displayName.uppercased())
            Text("\(catalog.items.count)")
                .font(.subheadline)
                .foregroundStyle(.cyan)
            Spacer()
            Image(systemName: "chevron.forward")
        }
    }
}

#Preview {
    CategoryView(catalog: .init(category: .amp, items: []))
}
