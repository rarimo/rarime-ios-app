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
    
    // MARK: - Background Gradients

    static let purpleBg = LinearGradient(
        gradient: Gradient(colors: [.purpleBgGradient1, .purpleBgGradient2, .purpleBgGradient3]),
        startPoint: .top,
        endPoint: .bottom
    )
    static let lightGreenBg = LinearGradient(
        gradient: Gradient(colors: [.lightGreenBgGradient1, .lightGreenBgGradient2]),
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // MARK: - Text Gradients

    static let purpleText = LinearGradient(
        gradient: Gradient(colors: [.purpleTextGradient1, .purpleTextGradient2]),
        startPoint: .leading,
        endPoint: .trailing
    )
    static let greenText = LinearGradient(
        gradient: Gradient(colors: [.greenTextGradient1, .greenTextGradient2]),
        startPoint: .leading,
        endPoint: .trailing
    )
    static let darkGreenText = LinearGradient(
        gradient: Gradient(colors: [.darkGreenTextGradient1, .darkGreenTextGradient2]),
        startPoint: .leading,
        endPoint: .trailing
    )
    static let darkerGreenText = LinearGradient(
        gradient: Gradient(colors: [.darkerGreenTextGradient1, .darkerGreenTextGradient2]),
        startPoint: .leading,
        endPoint: .trailing
    )
    static let limeText = LinearGradient(
        gradient: Gradient(colors: [.limeTextGradient1, .limeTextGradient2]),
        startPoint: .leading,
        endPoint: .trailing
    )
}
