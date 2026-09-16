//
//  SplashView.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/16/26.
//

import SwiftUI

struct SplashView: View {
    // MARK: - Body
    var body: some View {
        Color.bg
            .ignoresSafeArea()
            .overlay {
                LotusLoaderView(size: 96)
            }
    }
}

#Preview {
    SplashView()
}
