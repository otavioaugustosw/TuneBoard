//
//  VerticalSlider.swift
//  EmbeddedSwiftCompanion
//
//  Created by Otávio Augusto on 03/07/25.
//
import SwiftUI

struct VerticalSlider: View {
    
    @Binding var value: Float
    @State private var isDragging = false
    let inRange: ClosedRange<Float>

    init(value: Binding<Float>, in range: ClosedRange<Float> = 0...1) {
        self._value = value
        self.inRange = range
    }

    var body: some View {
        GeometryReader { geometry in
            let dragGesture = DragGesture(minimumDistance: 0)
                .onChanged { gestureValue in
                    self.isDragging = true
                    
                    let totalHeight = geometry.size.height
                    let dragPosition = gestureValue.location.y
                    
                    let clampedPosition = max(0, min(dragPosition, totalHeight))
                    let percentage = clampedPosition / totalHeight
                    
                    self.value = Float((1 - percentage)) * (
                        inRange.upperBound - inRange.lowerBound
                    ) + inRange.lowerBound
                }
                .onEnded { _ in
                    self.isDragging = false
                }

            ZStack(alignment: .bottom) {
                Capsule()
                    .fill(Color.black.opacity(0.8))
                    .frame(width: 20)
                    .shadow(color: .white.opacity(0.15), radius: 1, x: 0, y: 1)
                    .shadow(color: .black, radius: 2, x: 0, y: -1)

                Capsule()
                    .fill(
LinearGradient(
    gradient: Gradient(
        colors: [.indigo, .pink]
    ),
    startPoint: .bottom,
    endPoint: .top
)
                    )
                    .frame(width: 20)
                    .frame(
                        height: geometry.size.height * CGFloat(
                            (value - inRange.lowerBound) / (
                                inRange.upperBound - inRange.lowerBound
                            )
                        )
                    )

                KnobView(isDragging: isDragging)
                    .frame(width: 50, height: 40)
                    .offset(
                        y: -geometry.size.height * CGFloat(
                            (value - inRange.lowerBound) / (
                                inRange.upperBound - inRange.lowerBound
                            )
                        ) + 20
                    )

            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.height,
                alignment: .center
            )
            .gesture(dragGesture)
        }
    }
}

struct KnobView: View {
    let isDragging: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(
LinearGradient(
    gradient: Gradient(
        colors: [Color(white: 0.8), Color(white: 0.5)]
    ),
    startPoint: .top,
    endPoint: .bottom
)
                )
                .shadow(color: .black.opacity(0.4), radius: 3, x: 0, y: 3)
            
            VStack {
                Rectangle().frame(height: 1.5)
                Rectangle().frame(height: 1.5)
                Rectangle().frame(height: 1.5)
            }
            .foregroundStyle(.black.opacity(0.3))
            .padding(.horizontal, 10)
        }
        .scaleEffect(isDragging ? 1.05 : 1.0)
        .animation(.spring(), value: isDragging)
    }
}
