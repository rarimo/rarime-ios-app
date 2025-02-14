import SwiftUI

enum Gradients {
    static let greenFirst = LinearGradient(
        gradient: Gradient(colors: [.additionalFirstStart, .additionalFirstEnd]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let greenSecond = LinearGradient(
        gradient: Gradient(colors: [.additionalFourthStart, .additionalFourthEnd]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let greenThird = LinearGradient(
        gradient: Gradient(colors: [.additionalFifthStart, .additionalFifthEnd]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let blueFirst = LinearGradient(
        gradient: Gradient(colors: [.additionalSecondStart, .additionalSecondEnd]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let sandFirst = LinearGradient(
        gradient: Gradient(colors: [.additionalThirdStart, .additionalThirdEnd]),
        startPoint: .top,
        endPoint: .bottom
    )
}
