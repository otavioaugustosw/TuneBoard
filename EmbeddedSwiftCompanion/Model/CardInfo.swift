//
//  CardInfo.swift
//  ASKSample
//
//  Created by Otávio Augusto on 07/06/25.
//  Copyright © 2025 Apple. All rights reserved.
//

import Foundation

// tipos de efeito a serem exercidos no áudio
enum CardEffectType {
    case space
    case time
    case texture
}

// tipo de card
enum CardType {
    // qual instrumento irá colocar na pista
    case instrument(audioStemFile: String)
    // qual efeito vai exercer
    case effect(type: CardEffectType)
}

struct Card: Identifiable {
    // 1 a 6 por agora
    let id: Int
    let type: CardType
    let name: String
    let iconName: String
    
    static let presetMockup: [Card] = [
        Card(id: 1, type: .instrument(audioStemFile: "01_Groove.wav"),  name: "Groove",    iconName: "infinity"),
        Card(id: 2, type: .instrument(audioStemFile: "01_Harmony.wav"), name: "Harmonia",  iconName: "tortoise.fill"),
        Card(id: 3, type: .instrument(audioStemFile: "01_Melody.wav"),  name: "Melodia",   iconName: "bolt.fill"),
        Card(id: 4, type: .effect(type: .space),   name: "Espaço",    iconName: "star.fill"),
        Card(id: 5, type: .effect(type: .time),    name: "Tempo",     iconName: "fireworks"),
        Card(id: 6, type: .effect(type: .texture), name: "Textura",   iconName: "forward.fill")
    ]
}

