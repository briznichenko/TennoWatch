//
//  InvasionView.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 8/24/26.
//

import SwiftUI

struct InvasionView: View {
    @State private var isExpanded = false
    let reward: Reward
    private var rewardText: String {
        reward.items.joined(separator: ", ") + 
        reward.countedItems.map { "\($0.type), \($0.key), \($0.count)"}.joined(separator: ", ")
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("Tap to Reveal Details")
                    .font(.headline)
                Spacer()
                Image(systemName: "chevron.right")
                    .rotationEffect(.degrees(isExpanded ? 90 : 0))
            }
            .padding()
            .background(Color(.systemBackground))
            .onTapGesture {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }
            
            if isExpanded {
                HStack {
                    Text(rewardText)
                        .font(.body)
                        .foregroundColor(.secondary)
                        .padding([.horizontal, .bottom])
                        .transition(.move(edge: .top).combined(with: .opacity))
                }
            }
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        .padding()
    }
}

#Preview {
    InvasionView(reward: .init(items: [], countedItems: [], credits: 0, thumbnail: .none, color: 0))
}
