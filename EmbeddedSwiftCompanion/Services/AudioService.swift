// AudioService.swift
// EmbeddedSwiftCompanion
//
// Created by Otávio Augusto on 25/06/25.
//

import AVFoundation
import Observation
import SwiftUI

@Observable
internal final class AudioService {
    // MARK: PROPIEDADADES DO SERIVÇO
    private let mockup: Bool

    // cards que estão ativos no momento
    private var cardsPlayed: Set<Card>
    
    // tracks disponíveis
    private let audioTracks: [AudioTrack:AVAudioPlayerNode]
    
    // nodes de áudio
    private let audioEngine: AVAudioEngine
    private let reverbEffect: AVAudioUnitReverb
    private let timePitchEffect: AVAudioUnitTimePitch
    private let audioMixer: AVAudioMixerNode
    
    // cache dos buffers para evitar carregamento exessivo dos áudios na RAM
    private var audioBufferCache: [String: AVAudioPCMBuffer] = [:]
    
    // MARK: API PÚBLICA
    
    public var personalAudioURL: URL? = nil
    
    // valores customizados dos efeitos
    // reverb
    public var reverbPresetCustom: AVAudioUnitReverbPreset = .cathedral {
        didSet {
            changeReverb()
        }
    }
    
    public var reverbWetDryCustom: Float = EffectsDefaultValue.reverbWetDry.rawValue {
        didSet {
            changeReverbMix()
        }
    }
     
    // velocidade
    public var accelerateRateCustom: Float = EffectsDefaultValue.accelerate.rawValue {
        didSet {
            changeAccelerateRate()
        }
    }
    
    public var slowRateCustom: Float = EffectsDefaultValue.slow.rawValue {
        didSet {
            changeSlowRate()
        }
    }
    
    // pitch
    public var pitchUpCustom: Float = EffectsDefaultValue.pitchUp.rawValue {
        didSet {
            changePitchUp()
        }
    }
    
    public var pitchDownCustom: Float = EffectsDefaultValue.pitchDown.rawValue  {
        didSet {
            changePitchDown()
        }
    }
    
    public var customVolume: Float = EffectsDefaultValue.volume.rawValue  {
        didSet {
            changeVolume()
        }
    }
    
    
    init(mockup: Bool = false) {
        self.mockup = mockup

        self.cardsPlayed = Set<Card>()

        self.audioEngine = AVAudioEngine()
        self.reverbEffect = AVAudioUnitReverb()
        self.timePitchEffect = AVAudioUnitTimePitch()
        self.audioMixer = AVAudioMixerNode()
        
        // configura as tracks
        var setupTracks = [AudioTrack:AVAudioPlayerNode]()
        for track in AudioTrack.allCases {
            let playerNode = AVAudioPlayerNode()
            setupTracks[track] = playerNode
        }
        self.audioTracks = setupTracks
        
        // configura e inicia a engine de áudio
        setupAudioEngine()
    }
            
    public func updatePlayback(for activeCards: Set<Card>) {
        guard !mockup else { return }
        cardsPlayed = activeCards
        updateTracks(for: activeCards)
        updateEffects(for: activeCards)
    }
    
    // MARK: MÉTODOS PRIVADOS
    
    
    // prepara a engine de áudio e a inicia
    private func setupAudioEngine() {
        guard let audioBufferFormat = getCachedBuffer(for: "01_Groove")?.format else { return }
        // vincula os nodes de efeito a engine principal
        audioEngine.attach(reverbEffect)
        audioEngine.attach(timePitchEffect)
        audioEngine.attach(audioMixer)
        
        // vincula cada track a engine principal e conecta no mixer
        for track in audioTracks.values {
            audioEngine.attach(track)
        }
        for track in audioTracks.values {
            audioEngine.connect(track, to: audioMixer, format: audioBufferFormat)
        }
        // conecta o mixer aos nodes de efeitos
        audioEngine.connect(audioMixer, to: timePitchEffect, format: audioBufferFormat)
        audioEngine.connect(timePitchEffect, to: reverbEffect, format: audioBufferFormat)
        audioEngine.connect(reverbEffect, to: audioEngine.mainMixerNode, format: audioBufferFormat)
        

        // configura a sessão de áudio (essencial para permissão de áudio no ios)
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback, mode: .default)
            try audioSession.setActive(true)
        } catch {
            print("[ERRO] Falha ao configurar a sessão de áudio: \(error.localizedDescription)")
        }
        
        // inicia a engine
        do {
            audioEngine.prepare()
            try audioEngine.start()
            print("[DEBUG] \(audioEngine.isRunning ? "ENGINE RODANDO": "ENGINE NÃO INICIOU")")
        } catch {
            print("[ERRO] Não foi possível iniciar a engine de áudio: \(error.localizedDescription)")
        }
    }
    
    private func playPersonalAudio(from url: URL) {
        // acesso ao arquivo
        guard url.startAccessingSecurityScopedResource() else {
            return
        }

        do {
            let audioFile = try AVAudioFile(forReading: url)
            
            // formato de saída desejado
            let outputFormat = audioEngine.mainMixerNode.outputFormat(forBus: 0)

            // cria o conversor de áudio
            guard let converter = AVAudioConverter(from: audioFile.processingFormat, to: outputFormat) else {
                print("[ERRO] Não foi possível criar o conversor de áudio.")
                url.stopAccessingSecurityScopedResource()
                return
            }

            // calcula a capacidade do novo buffer com base na conversão da taxa de amostragem
            let ratio = outputFormat.sampleRate / audioFile.processingFormat.sampleRate
            let capacity = AVAudioFrameCount(Double(audioFile.length) * ratio)
            
            // cria um novo buffer com o formato de saída correto
            guard let convertedBuffer = AVAudioPCMBuffer(pcmFormat: outputFormat, frameCapacity: capacity) else {
                print("[ERRO] Não foi possível criar o buffer convertido.")
                url.stopAccessingSecurityScopedResource()
                return
            }

            // executa a conversão
            var error: NSError?
            let status = converter.convert(to: convertedBuffer, error: &error) { inNumPackets, outStatus in
                let inputBuffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat, frameCapacity: AVAudioFrameCount(inNumPackets))
                do {
                    try audioFile.read(into: inputBuffer!)
                } catch {
                    outStatus.pointee = .endOfStream
                    return nil
                }
                if inputBuffer!.frameLength == 0 {
                    outStatus.pointee = .endOfStream
                    return nil
                }
                outStatus.pointee = .haveData
                return inputBuffer
            }

            // verifica se a conversão foi feita com sucesso
            guard status != .error else {
                print("[ERRO] Falha na conversão do áudio: \(error?.localizedDescription ?? "erro desconhecido")")
                url.stopAccessingSecurityScopedResource()
                return
            }
            
            // o node da track e agenda o buffer convertido em loop
            if let playerNode = audioTracks[.personal] {
                playerNode.scheduleBuffer(convertedBuffer, at: nil, options: .loops)
                playerNode.play()
                print("[DEBUG] Áudio pessoal convertido e agendado com loop.")
            }
        } catch {
            print("[ERRO] Falha ao processar o ficheiro de áudio pessoal: \(error.localizedDescription)")
        }
        // termina o acesso ao arquivo
        url.stopAccessingSecurityScopedResource()
    }
    
    private func updateTracks(for activeCards: Set<Card>) {
        for trackType in AudioTrack.allCases {
            guard let playerNode = audioTracks[trackType] else { continue }
            
            // verifica se existe um card de instrumento correspondente ativo
            let instrumentCard = activeCards.first { card in
                if card.type.track == trackType {
                    return true
                }
                return false
            }

            if let card = instrumentCard {
                // se o card está ativo e o player não está tocando, comece a tocar.
                if !playerNode.isPlaying {
                    if case .instrument(let audioFile, let track) = card.type {
                        handleInstrumentToggle(audioFile: audioFile, track: track, shouldPlay: true)
                    }
                }
            } else {
                // se não há um card ativo para esta pista e o player está tocando, pare.
                if playerNode.isPlaying {
                    handleInstrumentToggle(track: trackType, shouldPlay: false)
                }
                
            }
        }
    }
    
    private func updateEffects(for activeCards: Set<Card>) {
        let isReverbActive = activeCards.contains { $0.type.effectType == .reverb }
        reverbEffect.wetDryMix = isReverbActive ? reverbWetDryCustom : 0
        
        let isPitchUpActive = activeCards.contains { $0.type.effectType == .pitchUp  }
        let isPitchDownActive = activeCards.contains { $0.type.effectType == .pitchDown  }
        
        var targetPitch: Float = 0.0
        if isPitchUpActive && !isPitchDownActive { targetPitch = pitchUpCustom }
        if isPitchDownActive && !isPitchUpActive { targetPitch = pitchDownCustom }
        
        if timePitchEffect.pitch != targetPitch {
            timePitchEffect.pitch = targetPitch
        }
        
        print("[PITCH] \(targetPitch)")
        
        let isSlowActive = activeCards.contains { $0.type.effectType == .slow  }
        let isFastActive = activeCards.contains { $0.type.effectType == .accelerate }
        
        var targetRate: Float = 1.0
        if isSlowActive && !isFastActive { targetRate = slowRateCustom }
        if isFastActive && !isSlowActive { targetRate = accelerateRateCustom }
        
        if timePitchEffect.rate != targetRate {
            // FIX DO BUG DE ÁUDIO (IMPORTANTISSIMO)
            if targetRate == 1.0 {
                timePitchEffect.reset()
                timePitchEffect.pitch = targetPitch
            }
            timePitchEffect.rate = targetRate
        }
    }
    
    private func handleInstrumentToggle(audioFile: String? = nil, track: AudioTrack, shouldPlay: Bool) {
        guard let playerNode = audioTracks[track] else { return }
        
        if shouldPlay {
            if track == .personal {
                guard let personalAudioURL else { return }
                playPersonalAudio(from: personalAudioURL)
                return
            }
            guard let audioFileName = audioFile,
                  let buffer = getCachedBuffer(for: audioFileName) else { return }
            
            playerNode.scheduleBuffer(buffer, at: nil, options: .loops)
            playerNode.play()
        } else {
            playerNode.stop()
        }
    }
    
    // métodos para customização da intensidade dos efeitos e volume
    private func changeReverb() {
        reverbEffect.loadFactoryPreset(reverbPresetCustom)
    }
    
    private func changeVolume() {
        audioMixer.volume = customVolume
    }

    private func changeReverbMix() {
        reverbEffect.wetDryMix = reverbWetDryCustom
    }
    
    private func changePitchUp() {
        guard pitchUpCustom >= 0, !isPitchUpandDownActive() else { return }
        timePitchEffect.pitch = pitchUpCustom
    }
    
    private func changePitchDown() {
        guard pitchDownCustom <= 0, !isPitchUpandDownActive() else { return }
        timePitchEffect.pitch = pitchDownCustom
    }
    
    private func changeSlowRate() {
        guard slowRateCustom <= 1, !isSlowAndAcceleratedActive() else { return }
        timePitchEffect.rate = slowRateCustom
    }
    private func changeAccelerateRate() {
        guard accelerateRateCustom >= 1, !isSlowAndAcceleratedActive() else { return }
        timePitchEffect.rate = accelerateRateCustom
    }

    private func isSlowAndAcceleratedActive() -> Bool {
        let isSlowActive = cardsPlayed.contains { $0.type == .effect(type: .slow) }
        let isFastActive = cardsPlayed.contains { $0.type == .effect(type: .accelerate) }
        return isSlowActive && isFastActive
    }
    
    private func isPitchUpandDownActive() -> Bool {
        let isPitchDownActive = cardsPlayed.contains { $0.type == .effect(type: .pitchDown) }
        let isPitchUpActive = cardsPlayed.contains { $0.type == .effect(type: .pitchUp) }
        return isPitchDownActive && isPitchUpActive
    }
    
    // para consumir menos memória ram, é feito cache dos áudios
    private func getCachedBuffer(for audioName: String) -> AVAudioPCMBuffer? {
        // áudio ja está no cache
        if let cachedBuffer = audioBufferCache[audioName] {
            return cachedBuffer
        }
        guard let audioFile = getAudioFile(withName: audioName),
              let buffer = AVAudioPCMBuffer(pcmFormat: audioFile.processingFormat,
                                            frameCapacity: AVAudioFrameCount(audioFile.length))
        else {
            print("[ERRO] Não foi possível criar buffer para \(audioName)")
            return nil
        }
        // áudio será inserido no cache
        do {
            try audioFile.read(into: buffer)
            audioBufferCache[audioName] = buffer
            return buffer
        } catch {
            print("[ERRO] Falha ao ler o arquivo no buffer: \(error.localizedDescription)")
            return nil
        }
    }
    
    // fetch do arquivo de áudio
    private func getAudioFile(withName audioName: String) -> AVAudioFile? {
        guard let path = Bundle.main.url(forResource: audioName, withExtension: "aif") else {
            print("[ERRO] Arquivo de áudio não encontrado: \(audioName).aif")
            return nil
        }
        return try? AVAudioFile(forReading: path)
    }
}

