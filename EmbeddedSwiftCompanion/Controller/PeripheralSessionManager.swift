import Foundation
import AccessorySetupKit
import CoreBluetooth
import SwiftUI

@Observable
class PeripheralSessionManager: NSObject {
    var peripheralInfo: PeripheralInfo?
    var receivedValue: String?
    var peripheralConnected = false
    var pickerDismissed = true

    private var currentPeripheral: ASAccessory?
    private var session = ASAccessorySession()
    private var manager: CBCentralManager?
    private var peripheral: CBPeripheral?
    private var peripheralCharacteristic: CBCharacteristic?

    private static let peripheralCharacteristicUUID = "ABCDEF01-1234-5678-1234-56789ABCDEF1"

    private static let esp32: ASPickerDisplayItem = {
        let descriptor = ASDiscoveryDescriptor()
        descriptor.bluetoothServiceUUID = PeripheralInfo.serviceUUID

        return ASPickerDisplayItem(
            name: PeripheralInfo.peripheralName,
            productImage: UIImage(named: "pickerImage")!,
            descriptor: descriptor
        )
    }()

    override init() {
        super.init()
        self.session.activate(on: DispatchQueue.main, eventHandler: handleSessionEvent(event:))
    }

    // MARK: - PeripheralSessionManager actions

    func presentPicker() {
        session.showPicker(for: [Self.esp32]) { error in
            if let error {
                print("[FALHA NO PICKER] \(error.localizedDescription)")
            }
        }
    }

    func removePeripheral() {
        guard let currentPeripheral else { return }

        if peripheralConnected {
            disconnect()
        }

        session.removeAccessory(currentPeripheral) { _ in
            self.peripheralInfo = nil
            self.currentPeripheral = nil
            self.manager = nil
        }
    }

    func connect() {
        guard
            let manager, manager.state == .poweredOn,
            let peripheral
        else {
            return
        }

        manager.connect(peripheral)
    }

    func disconnect() {
        guard let peripheral, let manager else { return }
        manager.cancelPeripheralConnection(peripheral)
    }

    // MARK: - ASAccessorySession functions

    private func savePeripheral(peripheral: ASAccessory) {
        currentPeripheral = peripheral

        if manager == nil {
            manager = CBCentralManager(delegate: self, queue: nil)
        }

        peripheralInfo = PeripheralInfo()
        peripheralInfo?.userPeripheralDisplayName = peripheral.displayName
    }

    private func handleSessionEvent(event: ASAccessoryEvent) {
        switch event.eventType {
            
        case .accessoryAdded, .accessoryChanged:
            guard let peripheral = event.accessory else { return }
            savePeripheral(peripheral: peripheral)
            connect()
            
        case .activated:
            guard let peripheral = session.accessories.first else { return }
            savePeripheral(peripheral: peripheral)
            connect()
            
        case .accessoryRemoved:
            self.peripheralInfo = nil
            self.currentPeripheral = nil
            self.manager = nil
            
        case .pickerDidPresent:
            pickerDismissed = false
            
        case .pickerDidDismiss:
            pickerDismissed = true

        default:
            print("[EVENTO BLE ACESSÓRIO] \(event.eventType)")
        }
    }
}

// MARK: - CBCentralManagerDelegate

extension PeripheralSessionManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("[ESTADO DO CBCENTRALMANAGER] \(central.state)")
        switch central.state {
        case .poweredOn:
            if let peripheralUUID = currentPeripheral?.bluetoothIdentifier {
                peripheral = central.retrievePeripherals(withIdentifiers: [peripheralUUID]).first
                peripheral?.delegate = self
            }
        default:
            peripheral = nil
        }
    }

    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("[CONEXÃO BLE] \(peripheral.name ?? "")")
        peripheral.delegate = self
        peripheral.discoverServices([PeripheralInfo.serviceUUID])
        peripheralConnected = true
    }

    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: (any Error)?) {
        print("[DESCONEXÃO BLE] \(peripheral)")
        peripheralConnected = false
    }

    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: (any Error)?) {
        print("[FALHA CONEXÃO BLE] \(peripheral), ERRO: \(error.debugDescription)")
    }
}

// MARK: - CBPeripheralDelegate

extension PeripheralSessionManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        guard
            error == nil,
            let services = peripheral.services
        else {
            return
        }

        for service in services {
            peripheral.discoverCharacteristics([CBUUID(string: Self.peripheralCharacteristicUUID)], for: service)
            print("[SERVIÇO DESCOBERTA] \(service.uuid.uuidString)")
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: (any Error)?) {
        guard
            error == nil,
            let characteristics = service.characteristics
        else {
            return
        }

        for characteristic in characteristics where characteristic.uuid == CBUUID(string: Self.peripheralCharacteristicUUID) {
            peripheralCharacteristic = characteristic
            print("[CARACTERÍSTICA DESCOBERTA] \(characteristic.uuid.uuidString)")
            peripheral.setNotifyValue(true, for: characteristic)
            peripheral.readValue(for: characteristic)
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        guard
            error == nil,
            characteristic.uuid == CBUUID(string: Self.peripheralCharacteristicUUID),
            let data = characteristic.value,
            let receivedValue = String(data: data, encoding: .utf8)
        else {
            return
        }

        print("[VALOR RECEBIDO DE \(peripheral.name?.uppercased() ?? "DESCONHECIDO")] \(receivedValue)")

        DispatchQueue.main.async {
            withAnimation {
                self.receivedValue = receivedValue
            }
        }
    }
}
