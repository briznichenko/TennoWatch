//
//  Palette.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/11/26.
//

import SwiftUI

extension ShapeStyle where Self == Color {
    static var masteredIcon: Color { .labelSecondary }
    static var unmasteredIcon: Color { .accent }
    static var lockedIcon: Color { .labelSecondary }
    static var archonCrimson: Color { Color(red: 0.72, green: 0.11, blue: 0.15) }
    static var archonAmber: Color { Color(red: 0.85, green: 0.62, blue: 0.13) }
    static var archonAzure: Color { Color(red: 0.24, green: 0.56, blue: 0.87) }
}
