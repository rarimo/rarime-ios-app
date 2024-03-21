//
//  AppView+ViewModel.swift
//  Template
//
//  Created by Ivan Lele on 19.03.2024.
//

import SwiftUI

extension AppView {
    class ViewModel: ObservableObject {
        let config: Config
        
        init() {
            do {
                config = try Config()
            } catch let error {
                fatalError("appview model error: \(error)")
            }
        }
    }
}
