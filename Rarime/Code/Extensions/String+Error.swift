//
//  String.swift
//  Rarime
//
//  Created by Ivan Lele on 21.03.2024.
//

import Foundation

extension String: Error {}

extension String: LocalizedError {
    public var errorDescription: String? {
        return self
    }
}
