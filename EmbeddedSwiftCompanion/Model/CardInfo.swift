//
//  CardInfo.swift
//  ASKSample
//
//  Created by Otávio Augusto on 07/06/25.
//

import Foundation

// tipos de efeito a serem exercidos no áudio
enum CardEffectType: Equatable {
    case reverb
    case slow
    case accelerate
    case pitchDown
    case pitchUp
}

// tipo de card
enum CardType: Equatable, Hashable {
    // qual instrumento irá colocar na pista
    case instrument(audioFile: String, track: AudioTrack)
    
    // qual efeito vai exercer
    case effect(type: CardEffectType)
    
    case empty
    
    var audioFile: String? {
          if case .instrument(let file, _) = self {
              return file
          }
          return nil
      }

      var track: AudioTrack? {
          if case .instrument(_, let track) = self {
              return track
          }
          return nil
      }
      
      var effectType: CardEffectType? {
          if case .effect(let type) = self {
              return type
          }
          return nil
      }
}

struct Card: Identifiable, Equatable, Hashable {
    let id: Int
    let type: CardType
    let name: String
    let iconName: String
    
    // cards registrados e disponíveis para uso.
    static let registeredCards: [Card] = [
        Card(
            id: 0,
            type: .empty,
            name: "Vazio",
            iconName: "questionmark"
        ),
        Card(
            id: 1,
            type: .effect(type: .reverb),
            name: "Reverb",
            iconName: "infinity"
        ),
        Card(
            id: 2,
            type: .effect(type: .slow),
            name: "Desacerelar",
            iconName: "tortoise.fill"
        ),
        Card(
            id: 3,
            type: .instrument(audioFile: "01_Groove", track: .groove),
            name: "Bateria e Baixo",
            iconName: "bolt.fill"
        ),
        Card(
            id: 4,
            type: .instrument(audioFile: "01_Melody", track: .melody),
            name: "Melodia",
            iconName: "star.fill"
        ),
        Card(
            id: 5,
            type: .instrument(audioFile: "01_Harmony", track: .harmony),
            name: "Harmonia",
            iconName: "fireworks"
        ),
        Card(
            id: 6,
            type: .effect(type: .accelerate),
            name: "Acelerar",
            iconName: "forward.fill"
        ),
        
        Card(
            id: 7,
            type: .instrument(audioFile: "", track: .personal),
            name: "Gravação",
            iconName: "microphone.fill"
        ),
        
        Card(
            id: 8,
            type: .effect(type: .pitchUp),
            name: "Pitch up",
            iconName: "balloon.fill"
        ),
        
        Card(
            id: 9,
            type: .effect(type: .pitchDown),
            name: "Pitch down",
            iconName: "water.waves.and.arrow.trianglehead.down"
        ),
    ]
    
}
