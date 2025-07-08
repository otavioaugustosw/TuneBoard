//
//  MixerView.swift
//  EmbeddedSwiftCompanion
//
//  Created by Otávio Augusto on 02/07/25.
//

import SwiftUI
import AVFoundation

struct MixerView: View {
    @Environment(BluetoothService.self) private var bleService: BluetoothService
    @Environment(\.colorScheme) private var colorScheme
    @State var viewModel: MixerViewModel
    @State var isPlaying: Bool = true
    
    init(audioService: AudioService) {
        self.viewModel = MixerViewModel(audioService: audioService)
    }
    
    var body: some View {
            ZStack {
                let bgColor: Color = colorScheme == .dark ? Color.white.opacity(0.1) : .white
                bgColor.ignoresSafeArea()
                ScrollView {
                    // MARK: CARDS
                VStack {
                    if !viewModel.activeCards.isEmpty {
                        Text("Blocos tocando")
                            .font(.title)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        HStack {
                            ForEach(1..<4) { slotNum in
                                VHSView(
                                    isPlaying: viewModel.isSlotActive(slotNum),
                                    icon: viewModel.getIcon(forSlot: slotNum)
                                )
                            }
                        }
                        HStack {
                            ForEach(4..<7) { slotNum in
                                VHSView(
                                    isPlaying: viewModel.isSlotActive(slotNum),
                                    icon: viewModel.getIcon(forSlot: slotNum)
                                )
                            }
                        }
                        //  MARK:  MIXER
                        Text("Mixer")
                            .font(.title)
                            .fontWeight(.semibold)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 10)

                        if viewModel.isEffectActive(.reverb) {
                            Text("Preset de Reverb")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.top, 30)
                            SkeuomorphicHorizontalPicker(
                                options: viewModel.defaultReverbPresets.keys
                                    .sorted(),
                                selection: $viewModel.selectedViewReverb,
                                tint: .pink
                            )
                            .padding(.bottom, 50)
                            .transition(.opacity.combined(with: .scale(scale: 0.9)))
                        }
                        HStack {
                            makeSlider(
                                title: "Volume",
                                value: $viewModel.volumeValue,
                                range: 0...1
                            )
                            // mixer de reverb
                            if viewModel.isEffectActive(.reverb) {
                                makeSlider(
                                    title: "Reverb",
                                    value: $viewModel.reverbIntensity,
                                    range: 0...100
                                )
                                .transition(
                                    .opacity.combined(with: .scale(scale: 0.9))
                                )
                            }
                            // mixer de velocidade
                            if viewModel.isEffectActive(.accelerate) {
                                makeSlider(
                                    title: "Acelerar",
                                    value: $viewModel.accelerateIntensity,
                                    range: 1...2
                                )
                                .transition(
                                    .opacity.combined(with: .scale(scale: 0.9))
                                )
                            }
                            else if viewModel.isEffectActive(.slow) {
                                let invertedSlowBinding = Binding<Float>(
                                    get: {
                                        return 1.0 - (viewModel.slowIntensity - 0.25) / (1.0 - 0.25)
                                    },
                                    set: { newSliderValue in
                                        viewModel.slowIntensity = ((1.0 - newSliderValue) * (1.0 - 0.25)) + 0.25
                                    }
                                )
                                makeSlider(
                                    title: "Desacelerar",
                                    value: invertedSlowBinding,
                                    range: 0...1
                                )
                                .transition(
                                    .opacity.combined(with: .scale(scale: 0.9))
                                )
                            }
                            // mixer de pitch
                            if viewModel.isEffectActive(.pitchUp) {
                                makeSlider(
                                    title: "Subir tom",
                                    value: $viewModel.pitchUpValue,
                                    range: 0...1000
                                )
                                .transition(
                                    .opacity.combined(with: .scale(scale: 0.9))
                                )
                            }
                            else if viewModel.isEffectActive(.pitchDown) {
                                makeSlider(
                                    title: "Baixar tom",
                                    value: $viewModel.pitchDownValue,
                                    range: (-1000)...0
                                )
                                .transition(
                                    .opacity.combined(with: .scale(scale: 0.9))
                                )
                            }
                            Spacer()
                        }
                        .padding(.top, 9)
                        .frame(maxWidth: .infinity)
                        .animation(
                            .spring(response: 0.4, dampingFraction: 0.7),
                            value: viewModel.activeCards
                        )

                    }
                    else {
                        Text("Sem cards conectados no momento")
                    }
                }
                .padding(.top, 50)
            }
                .scrollIndicators(.hidden)

        }
        .onAppear {
            viewModel.updateActiveCards(from: bleService.slotCards)
        }
        .onChange(of: bleService.slotCards) {
            viewModel.updateActiveCards(from: bleService.slotCards)
        }
        .onChange(of: bleService.actualVolume) {
            viewModel.volumeValue = bleService.actualVolume
        }
        .fileImporter(
            isPresented: $viewModel.isShowingFileImporter,
            allowedContentTypes: [UTType.audio],
            allowsMultipleSelection: false
        ) { result in
            do {
                if let fileURL = try result.get().first {
                    viewModel.personalAudioURL = fileURL
                    viewModel.updateActiveCards(from: bleService.slotCards)
                }
            } catch {
                return
            }
        }
    }
    
    private func makeSlider(title: String, value: Binding<Float>, range: ClosedRange<Float>) -> some View {
        VStack {
            VerticalSlider(value: value, in: range)
                .frame(height: 240)
            Text(title)
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.vertical, 30)
        }
        
    }
}

#Preview {
    MixerView(audioService: AudioService(mockup: true))
        .environment(BluetoothService(mockup: true))
}
