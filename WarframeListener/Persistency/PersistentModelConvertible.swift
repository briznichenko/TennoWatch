//
//  PersistentModelConvertible.swift
//  WarframeListener
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import SwiftData

protocol PersistentModelConvertible {
    associatedtype Model: PersistentModel
    var model: Model { get }
}
