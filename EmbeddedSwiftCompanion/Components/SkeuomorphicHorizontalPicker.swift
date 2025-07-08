//
//  SkeuomorphicHorizontalPicker.swift
//  EmbeddedSwiftCompanion
//
//  Created by Otávio Augusto on 03/07/25.
//
import SwiftUI

struct SkeuomorphicHorizontalPicker: View {
    let options: [String]
    @Binding var selection: String
    var tint: Color
    
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        let containerBackgroundColor = colorScheme == .dark ? Color(white: 0.1) : Color(white: 0.88)
        let containerShadowColor = colorScheme == .dark ? Color.black.opacity(0.5) : Color.gray.opacity(0.4)
        
        HStack(spacing: 2) {
            ForEach(options, id: \.self) { option in
                Button(option.uppercased()) {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
                        selection = option
                    }
                }
                .buttonStyle(SkeumorphicButton(isSelected: selection == option, tint: tint))
                .frame(minWidth: 80)
            }
        }
        .frame(height: 55)
        .background(containerBackgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: 10))
        .shadow(color: containerShadowColor, radius: 10, x: 0, y: 8)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.primary.opacity(0.2), lineWidth: 1)
        )
    }
}
