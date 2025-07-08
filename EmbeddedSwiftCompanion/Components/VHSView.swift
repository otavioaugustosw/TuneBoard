//
//  VHSView.swift
//  EmbeddedSwiftCompanion
//
//  Created by Otávio Augusto on 03/07/25.
//

import SwiftUI

struct VHSView: View {
    @Binding var isPlaying: Bool
    var icon: String
    private let bodyGradient = LinearGradient(
        gradient: Gradient(colors: [Color(white: 0.2), Color.black]),
        startPoint: .top,
        endPoint: .bottom
    )

    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(bodyGradient)
                .stroke(Color.black.opacity(0.5), lineWidth: 2)
                .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 3)

            HStack(spacing: 15) {
                VHSSpoolView(isPlaying: $isPlaying)
                    .frame(width: 40, height: 40)
                iconDisplay
                VHSSpoolView(isPlaying: $isPlaying)
                    .frame(width: 40, height: 40)
 
            }
            .padding(.vertical, 10)
        }
        .frame(width: 250 , height: 125)

    }

    var iconDisplay: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(red: 0.25, green: 0.15, blue: 0.12))
                
            Image(systemName: icon)
                .font(.system(size: 30, weight: .heavy))
                .foregroundStyle(.pink.opacity(0.8))
                .shadow(color: .pink, radius: 5)
                .padding(10)
        }
        .frame(maxWidth: 80, maxHeight: 70)
    }
}

struct VHSSpoolView: View {
    @Binding var isPlaying: Bool
    @State private var isAnimating: Bool = false

    var body: some View {
        ZStack {
            Circle()
                .foregroundStyle(Color(white: 0.1))
            Circle()
                .fill(Color(white: 0.9))
            
            ForEach(0..<3) { i in
                Capsule()
                    .fill(Color(white: 0.6))
                    .frame(width: 7, height: 33)
                    .rotationEffect(.degrees(Double(i) * 120))
            }
            Circle()
                .fill(Color(white: 0.7))
                .frame(width: 10, height: 10)
        }
        .rotationEffect(isAnimating ? .degrees(360) : .degrees(0))
        .animation(
            isAnimating ?
                .linear(duration: 1.0)
                .repeatForever(autoreverses: false) :
                    .easeOut(duration: 0.5),
            value: isAnimating
        )
        .onAppear {
            isAnimating = isPlaying
        }
        .onChange(of: isPlaying) {
            isAnimating = isPlaying
        }
    }
}
