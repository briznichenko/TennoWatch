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
            Text(catalog.category.rawValue)
            Text("\(catalog.items.count)")
                .font(.subheadline)
                .foregroundStyle(.cyan)
            Spacer()
        }
    }
}

#Preview {
    CategoryView(catalog: .init(category: .amp, items: []))
}
