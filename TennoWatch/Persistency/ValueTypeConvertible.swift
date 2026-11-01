//
//  ValueTypeConvertible.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 9/3/26.
//

import SwiftData

protocol ValueTypeConvertible: PersistentModel {
    associatedtype Value: Sendable
    var value: Value { get }
}

protocol PersistentModelConvertible: Sendable {
    associatedtype Model: PersistentModel
    var model: Model { get }
}
