//
//  SetupView.swift
//  EmbeddedSwiftCompanion
//
//  Created by Otávio Augusto on 17/06/25.


import SwiftUI

struct SetupView: View {
    @Environment(BluetoothService.self) private var bleService
    @Environment(AudioService.self) private var audioService
    @State private var isConnected: Bool = false
    @Namespace private var namespace
    var body: some View {
        NavigationStack {
            GlassEffectContainer(spacing: 50.0) {
            
                GeometryReader { geo in
                    let height = geo.size.height
                    let width = geo.size.width
                    ZStack {
                        VStack {
                            VStack(alignment: .leading ) {
                                Text("PROTÓTIPO INTERFACE TUNEBOARD")
                                    .font(.title)
                                    .fontDesign(.monospaced)
                                    .bold()
                                    .foregroundStyle(.primary)
                                    .padding(.bottom, height * 0.1)
                                
                                Text(
                                    "Espere a conexão automática ou adicione manualmente a Tuneboard"
                                )
                                .font(.subheadline)
                                .fontDesign(.monospaced)
                                .bold()
                                .foregroundStyle(.primary)
                                .padding(.bottom, height * 0.1)
                                
                                HStack(spacing: 50.0) {
                                    
                                    if isConnected {
                                        Button("Remover") {
                                            bleService.removeDevice()
                                        }
                                        .buttonStyle(
                                            StandartButton(
                                                color: .red,
                                                width: width,
                                                height: height,
                                                glassId: "remove",
                                                namespace: namespace
                                            )
                                        )
                                    }
                                    Button {
                                        isConnected ? bleService
                                            .disconnectDevice() : bleService
                                            .connectExistingDevice()
                                    } label: {
                                        Text(
                                            isConnected ? "Desconectar" : "Conectar"
                                        )
                                    }
                                    .buttonStyle(
                                        StandartButton(
                                            width: width,
                                            height: height,
                                            glassId: "connect",
                                            namespace: namespace
                                        )
                                    )
                                    if !isConnected {
                                        Button("Adicionar TuneBoard") {
                                            bleService.startPairing()
                                        }
                                        .buttonStyle(
                                            StandartButton(
                                                width: width * 1.7,
                                                height: height,
                                                glassId: "add",
                                                namespace: namespace
                                            )
                                        )
                                        .padding(.horizontal, width * 0.05)
                                    }
                                    else {
                                        NavigationLink {
                                            MixerView(audioService: audioService)
                                        } label: {
                                            Image(systemName: "arrow.forward")

                                        }
                                        .frame(
                                            width: width * 0.07,
                                            height: width * 0.07
                                        )
                                        .foregroundStyle(.primary)
                                        .fontDesign(.monospaced)
                                        .glassEffect(
                                            .regular.tint(.pink).interactive()
                                        )
                                        .glassEffectID("next", in: namespace)
                                        .padding(.horizontal, width * 0.05)
                                    }
                                }
                            }
                            .frame(maxWidth: .infinity)
                        }
                        .frame(width: width * 0.95, height: 0.95 * height)
                    }
                    .frame(width: width, height: height)
                }
            }
            .onChange(of: bleService.isPeripheralConnected) {
                withAnimation {
                    isConnected = bleService.isPeripheralConnected
                }
            }
            .onAppear{
                bleService.connectExistingDevice()
            }
        }
    }
}

#Preview {
    SetupView()
}

