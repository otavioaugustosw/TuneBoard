//
//  BluetoothServices.swift
//  EmbeddedSwiftCompanion
//
//  Created by Otávio Augusto on 22/06/25.
//
import Foundation
import CoreBluetooth

// abstração do gerenciamento bluetooth para as Views
@Observable
internal final class BluetoothService {
    // MARK: PROPIEDADADES DO SERIVÇO
    
    // gerenciador bluetooth
    private let peripheralSM = PeripheralSessionManager()
    private let mockup: Bool
    
    // propriedades mockup
    @MainActor private var mockupSlots: [Int] = [Int](repeating: 0, count: 6)
    private var mockupTimer: Timer?

    @MainActor
    private var _isPeripheralConnected: Bool = false
    
    @MainActor
    public var isPeripheralConnected: Bool {
        if mockup {
            return _isPeripheralConnected
        }
        return peripheralSM.peripheralConnected
    }
    
    // cards nos slots
    @MainActor
    public var slotCards: [Int] {
        if mockup {
            return mockupSlots
        }
        return getSlotsCard()
    }
    
    public var actualVolume: Float {
        (Float(peripheralSM.actualVolume ?? "100") ?? 100) * 0.395 / 100
    }
    
    init(mockup: Bool = false) {
        self.mockup = mockup
        if mockup {
            simulatePairing()
        }
        if mockup {
            mockupSlots = [Int](repeating: 0, count: 6).map { _ in Int.random(in: 0...8) }
            mockupTimer = Timer.scheduledTimer(withTimeInterval: 5, repeats: true) { [weak self] _ in
                Task { @MainActor in
                    self?.mockupSlots = [Int](repeating: 0, count: 6).map { _ in Int.random(in: 0...5) }
                }
            }
        }
    }
    
    // MARK: API PÚBLICA
    
    public func startPairing() {
        peripheralSM.presentPicker()
    }
    
    public func connectExistingDevice() {
        peripheralSM.connect()
    }
    
    public func disconnectDevice() {
        peripheralSM.disconnect()
    }
    
    public func removeDevice() {
        peripheralSM.removePeripheral()
    }
    
    // MARK: MÉTODOS PRIVADOS
    
    // termina o timer de thread do mockup
    deinit {
        mockupTimer?.invalidate()
    }
    
    // simula pareamento com a TuneBoard
    private func simulatePairing() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self._isPeripheralConnected = true
        }
    }
    
    // fetch dos id's dos cards nos slots
    private func getSlotsCard() -> [Int]{
        guard let receivedValue = peripheralSM.cardsInSlot else {
            return [Int](repeating: 0, count: 6)
        }
        return receivedValue.compactMap { $0.wholeNumberValue }
    }
}
