//
//  AppearanceProxies.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import SwiftUI

enum AppearanceProxies {
    static func configure() {
        let navigationBarAppearance = UINavigationBar.appearance()
        navigationBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(resource: .label)]

        let tabBarItemAppearance = UITabBarItem.appearance()
        tabBarItemAppearance.setTitleTextAttributes(
            [.foregroundColor: UIColor(resource: .labelSecondary)],
            for: .normal
        )
        UITabBar.appearance().unselectedItemTintColor = UIColor(resource: .labelSecondary)
    }
}
