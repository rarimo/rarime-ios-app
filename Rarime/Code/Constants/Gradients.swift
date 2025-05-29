import SwiftUI

enum Gradients {
    static let gradientFirst = LinearGradient(
        gradient: Gradient(colors: [.additionalGradientFirstStart, .additionalGradientFirstEnd]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let gradientSecond = LinearGradient(
        gradient: Gradient(colors: [.additionalGradientSecondStart, .additionalGradientSecondEnd]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let gradientThird = LinearGradient(
        gradient: Gradient(colors: [.additionalGradientThirdStart, .additionalGradientThirdEnd]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let gradientFourth = LinearGradient(
        gradient: Gradient(colors: [.additionalGradientFourthStart, .additionalGradientFourthEnd]),
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let gradientFifth = LinearGradient(
        gradient: Gradient(colors: [.additionalGradientFifthStart, .additionalGradientFifthEnd]),
        startPoint: .top,
        endPoint: .bottom
    )
    static let gradientSixth = LinearGradient(
        gradient: Gradient(colors: [.additionalGradientSixthStart, .additionalGradientSixthEnd]),
        startPoint: .top,
        endPoint: .bottom
    )
    static let purpleBg = LinearGradient(
        gradient: Gradient(colors: [.purpleBgGradient1, .purpleBgGradient2, .purpleBgGradient3]),
        startPoint: .top,
        endPoint: .bottom
    )
    static let purpleText = LinearGradient(
        gradient: Gradient(colors: [.purpleTextGradient1, .purpleTextGradient2]),
        startPoint: .leading,
        endPoint: .trailing
    )
}
