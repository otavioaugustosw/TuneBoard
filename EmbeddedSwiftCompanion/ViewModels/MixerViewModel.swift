//
//  MixerViewModel.swift
//  EmbeddedSwiftCompanion
//
//  Created by Otávio Augusto on 30/06/25.
//

import AVFoundation
import Observation
import SwiftUI

@Observable
internal final class MixerViewModel {
    
    // MARK: Serviços
    private let audioService: AudioService
    
    
    // MARK: Presets
    private(set) var availableCards: [Card] = Card.registeredCards
    
    private(set) var defaultReverbPresets: [String: AVAudioUnitReverbPreset] =
    [
        "Quarto Pequeno": .smallRoom,
        "Quarto Grande": .largeRoom,
        "Catedral": .cathedral,
        "Corredor Grande": .largeHall
    ]
    
    private var activeSlots: [Int : Bool] =
    [
        1 : false,
        2 : false,
        3 : false,
        4 : false,
        5 : false,
        6 : false,
    ]
    
    private var selectedReverb: AVAudioUnitReverbPreset {
        didSet {
            audioService.reverbPresetCustom = selectedReverb
        }
    }
    
    // MARK: Propriedades p/ view
    public var reverbIntensity: Float {
        didSet {
            audioService.reverbWetDryCustom = reverbIntensity
        }
    }
    
    public var volumeValue: Float {
        didSet {
            audioService.customVolume = volumeValue
            print ("[VOLUME \(volumeValue)")
        }
    }
    
    public var pitchUpValue: Float {
        didSet {
            audioService.pitchUpCustom = pitchUpValue
        }
    }
    
    public var pitchDownValue: Float {
        didSet {
            audioService.pitchDownCustom = pitchDownValue
        }
    }
    
    public var slowIntensity: Float {
        didSet {
            audioService.slowRateCustom = slowIntensity
        }
    }
    
    public var accelerateIntensity: Float {
        didSet {
            audioService.accelerateRateCustom = accelerateIntensity
        }
    }
    
    public var selectedViewReverb: String {
        willSet {
            selectedReverb = defaultReverbPresets[newValue] ?? .cathedral
        }
    }
    
    public var personalAudioURL: URL? {
        didSet {
            audioService.personalAudioURL = personalAudioURL
        }
    }
    
    public var activeCards: [Card] {
        didSet {
            updateSlotStatus()
        }
    }
    
    public var isShowingFileImporter: Bool
    
    // MARK: Inicialização
    init(audioService: AudioService) {
        // serviços
        self.audioService = audioService
        // propriedade p/ controle de áudio
        self.reverbIntensity = EffectsDefaultValue.reverbWetDry.rawValue
        self.volumeValue = EffectsDefaultValue.volume.rawValue
        self.pitchUpValue = EffectsDefaultValue.pitchUp.rawValue
        self.pitchDownValue = EffectsDefaultValue.pitchDown.rawValue
        self.slowIntensity = EffectsDefaultValue.slow.rawValue
        self.accelerateIntensity = EffectsDefaultValue.accelerate.rawValue
        self.selectedReverb = .cathedral
        self.selectedViewReverb = "Catedral"
        self.activeCards = [Card]()
        self.isShowingFileImporter = false
    }
    
    // MARK: Métodos
    public func updateActiveCards(from slots: [Int]) {
        let validIDs = slots.filter { $0 > -1 }
        let newCardSet = validIDs.compactMap { id in
            availableCards.first { $0.id == id }
        }
        self.activeCards = newCardSet
        
        let personalCardWasAdded = newCardSet.contains {
            $0.type.track == .personal
        }
        
        if personalCardWasAdded {
            if let url = self.personalAudioURL {
                audioService.personalAudioURL = url
            } else {
                self.isShowingFileImporter = true
            }
        }
        else {
            self.personalAudioURL = nil
            audioService.personalAudioURL = nil
            self.isShowingFileImporter = false
        }
        
        audioService.updatePlayback(for: Set(newCardSet))
    }
    
    public func getIcon(forSlot slotNum: Int) -> String {
        guard slotNum >= 1 && slotNum <= availableCards.count else { return "minus"}
        return activeCards[slotNum - 1].iconName
    }
    
    private func getSlotBool(_ slotNum: Int) -> Bool{
        guard slotNum >= 1 && slotNum <= availableCards.count,
        let isSlotActive = activeSlots[slotNum] else { return false }
        return isSlotActive
    }
    
    private func updateSlotStatus() {

        activeSlots.forEach { slotNum, status in
            if  activeCards[slotNum - 1].type != .empty  {
                activeSlots[slotNum] = true
            } else {
                activeSlots[slotNum] = false
            }
        }
    }
    
    public func isSlotActive(_ slotNum: Int) -> Binding<Bool> {
        return Binding(
            get: {self.getSlotBool(slotNum) },
            set: {self.activeSlots[slotNum] = $0}
        )
    }
    
    public func isEffectActive(_ effect: CardEffectType) -> Bool {
        activeCards.contains(where: {$0.type.effectType == effect})
    }
    
    func mapValue(value: Float, fromRange: ClosedRange<Float>, toRange: ClosedRange<Float>) -> Float {
        let fromMin = fromRange.lowerBound
        let fromMax = fromRange.upperBound
        let toMin = toRange.lowerBound
        let toMax = toRange.upperBound
        
        let proportion = (value - fromMin) / (fromMax - fromMin)
        let result = toMin + proportion * (toMax - toMin)
        
        return max(toMin, min(toMax, result))
    }

}

