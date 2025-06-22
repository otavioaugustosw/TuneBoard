//
//  CardsTestView.swift
//  EmbeddedSwiftCompanion
//
//  Created by Otávio Augusto on 22/06/25.
//

import SwiftUI

struct CardsTestView: View {
    @State var peripheralSM = PeripheralSessionManager()
    var cardsNumbers: [Int] { getCardNums() }
    var cards: [Card] = Card.presetMockup

    var body: some View {
        if !cardsNumbers.isEmpty {
            makeCardsView()
        }
        else {
            Text("Sem cards conectados no momento")
        }
    
    }
    
    private func makeCardsView() -> some View {
        VStack {
            HStack {
                makeSlotView(0)
                makeSlotView(1)
                makeSlotView(2)
            }
            HStack {
                makeSlotView(3)
                makeSlotView(4)
                makeSlotView(5)
            }
        }
    }
    
    private func makeSlotView(_ numSlot: Int) -> some View {
        withAnimation {
            let cardNumber = cardsNumbers[numSlot]
            return ZStack(alignment: .top) {
                RoundedRectangle(cornerRadius: 20)
                    .frame(width: 180, height: 180)
                    .foregroundStyle(.pink)
                RoundedRectangle(cornerRadius: 20)
                    .foregroundStyle(.white)
                    .frame(width: 150, height: 100)
                    .overlay{
                        Image(
                            systemName: cardNumber == 0 ? "" : cards[cardNumber - 1].iconName
                        )
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60, height: 60)
                        .foregroundStyle(.gray)
                    }
                    .padding(.top)
            }
        }
    }
    
    private func getCardNums() -> [Int]{
        guard let receivedValue = peripheralSM.receivedValue else {
            print("Valor recebido é nulo.")
            return [Int](repeating: 0, count: 6)
        }
        return receivedValue.compactMap { $0.wholeNumberValue }
    }
}

#Preview {
    CardsTestView()
}
