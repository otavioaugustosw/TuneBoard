//
//  SkeumorphicButton.swift
//  EmbeddedSwiftCompanion
//
//  Created by Otávio Augusto on 03/07/25.
//

import SwiftUI

struct SkeumorphicButton: ButtonStyle {
    var isSelected: Bool
    var tint: Color

    @Environment(\.colorScheme) private var colorScheme

    private struct Style {
        let baseColor: Color
        let raisedGradient: LinearGradient
        let textColor: Color
        let selectedTextColor: Color
        let innerShadowColor: Color
        let innerHighlightColor: Color
        let textShadowColor: Color
        
        init(colorScheme: ColorScheme, isSelected: Bool, tint: Color) {
            if colorScheme == .dark {
                self.baseColor = Color(white: 0.22)
                self.raisedGradient = LinearGradient(gradient: Gradient(colors: [Color(white: 0.28), Color(white: 0.22)]), startPoint: .top, endPoint: .bottom)
                self.textColor = Color.white.opacity(0.8)
                self.selectedTextColor = tint
                self.innerShadowColor = .black.opacity(0.5)
                self.innerHighlightColor = .white.opacity(0.15)
                self.textShadowColor = .black.opacity(isSelected ? 0.6 : 0)
            } else {
                self.baseColor = Color(white: 0.95)
                self.raisedGradient = LinearGradient(gradient: Gradient(colors: [Color.white, Color(white: 0.92)]), startPoint: .top, endPoint: .bottom)
                self.textColor = Color.black.opacity(0.7)
                self.selectedTextColor = tint
                self.innerShadowColor = .black.opacity(0.2)
                self.innerHighlightColor = .white.opacity(0.8)
                self.textShadowColor = .clear
            }
        }
    }

    func makeBody(configuration: Configuration) -> some View {
        let style = Style(colorScheme: colorScheme, isSelected: isSelected, tint: tint)
        
        ZStack {
            if isSelected {
                style.baseColor
                
                Rectangle()
                    .stroke(style.innerShadowColor, lineWidth: 4)
                    .blur(radius: 4)
                    .offset(x: 2, y: 2)
                    .mask(Rectangle())
                
                Rectangle()
                    .stroke(style.innerHighlightColor, lineWidth: 5)
                    .blur(radius: 3)
                    .offset(x: -2, y: -2)
                    .mask(Rectangle())
            } else {
                style.raisedGradient
            }
        }
        .overlay(
            configuration.label
                .font(.system(size: 14, weight: .bold, design: .monospaced))
                .foregroundStyle(isSelected ? style.selectedTextColor : style.textColor)
                .shadow(color: style.textShadowColor, radius: 1, y: 1)
        )
        .clipShape(Rectangle())
        .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
        .animation(.spring(response: 0.2, dampingFraction: 0.7), value: configuration.isPressed)
    }
}
