//
//  StandartButton.swift
//  EmbeddedSwiftCompanion
//
//  Created by Otávio Augusto on 22/06/25.
//

import SwiftUI

struct StandartButton: ButtonStyle {
    let color: Color?
    let width: CGFloat
    let height: CGFloat
    let glassId: String
    let namespace: Namespace.ID
    
    init(color: Color? = nil, width: CGFloat, height: CGFloat, glassId: String, namespace: Namespace.ID) {
        self.color = color
        self.width = width
        self.height = height
        self.glassId = glassId
        self.namespace = namespace
    }
    
    func makeBody(configuration: Configuration) -> some View {
        if let color {
            return configuration.label
                .frame(
                    width: width * 0.20,
                    height: height * 0.12
                )
                .glassEffect(.regular.tint(color).interactive())
                .glassEffectID(glassId, in: namespace)
                .foregroundStyle(.primary)
                .fontDesign(.monospaced)
        }
        return configuration.label
            .frame(
                width: width * 0.20,
                height: height * 0.12
            )
            .glassEffect(.regular.interactive())
            .glassEffectID(glassId, in: namespace)
            .foregroundStyle(.primary)
            .fontDesign(.monospaced)
    }
}
