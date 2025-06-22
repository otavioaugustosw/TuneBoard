//
//  teste.swift
//  EmbeddedSwiftCompanion
//
//  Created by Otávio Augusto on 22/06/25.
//

import SwiftUI

struct teste: View {
    @State private var isExpanded: Bool = false
    @Namespace private var namespace


    var body: some View {
        GlassEffectContainer(spacing: 40.0) {
            HStack(spacing: 40.0) {
                Image(systemName: "scribble.variable")
                    .frame(width: 80.0, height: 80.0)
                    .font(.system(size: 36))
                    .glassEffect()
                    .glassEffectID("pencil", in: namespace)


                if isExpanded {
                    Button("TESTE") {
                        
                    }
                        .frame(width: 80.0, height: 80.0)
                        .glassEffect()
                        .glassEffectID("eraser", in: namespace)
                }
            }
        }


        Button("Toggle") {
            withAnimation {
                isExpanded.toggle()
            }
        }
        .buttonStyle(.glass)
    }
}


#Preview {
    teste()
}
