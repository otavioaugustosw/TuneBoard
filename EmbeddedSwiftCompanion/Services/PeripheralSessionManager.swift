import AccessorySetupKit
import CoreBluetooth
import SwiftUI

@Observable
internal final class PeripheralSessionManager: NSObject {
    
    public var peripheralInfo: PeripheralInfo?
    public var cardsInSlot: String?
    public var actualVolume: String?
    public var peripheralConnected = false
    public var pickerDismissed = true

    // atributos do bluetooth
    private var currentPeripheral: ASAccessory?
    private var session = ASAccessorySession()
    private var manager: CBCentralManager?
    
    // atributos do tuneboard
    private var tuneboardDevice: CBPeripheral?
    private var cardsReadingCharacteristic: CBCharacteristic?
    private var volumeControlCharacteristic: CBCharacteristic?

    override init() {
        super.init()
        self.session.activate(on: DispatchQueue.main, eventHandler: handleSessionEvent(event:))
    }

    // MARK: PeripheralSessionManager

    func presentPicker() {
        session.showPicker(for: [PeripheralInfo.tuneboardDeviceInfo]) { error in
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
            let tuneboardDevice
        else {
            return
        }

        manager.connect(tuneboardDevice)
    }

    func disconnect() {
        guard let tuneboardDevice, let manager else { return }
        manager.cancelPeripheralConnection(tuneboardDevice)
    }

    // MARK: ASAccessorySession

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

// MARK: CBCentralManagerDelegate

extension PeripheralSessionManager: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("[ESTADO DO CBCENTRALMANAGER] \(central.state)")
        switch central.state {
        case .poweredOn:
            if let peripheralUUID = currentPeripheral?.bluetoothIdentifier {
                tuneboardDevice = central.retrievePeripherals(withIdentifiers: [peripheralUUID]).first
                tuneboardDevice?.delegate = self
            }
        default:
            tuneboardDevice = nil
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

// MARK: CBPeripheralDelegate

extension PeripheralSessionManager: CBPeripheralDelegate {
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: (any Error)?) {
        guard
            error == nil,
            let services = peripheral.services
        else {
            return
        }

        for service in services {
            peripheral.discoverCharacteristics([CBUUID(string: PeripheralInfo.cardsReadingCharacteristicUUID)], for: service)
            peripheral.discoverCharacteristics([CBUUID(string: PeripheralInfo.volumeControlCharacteristicUUID)], for: service)
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

        for characteristic in characteristics {
            if characteristic.uuid.uuidString == PeripheralInfo.cardsReadingCharacteristicUUID {
                cardsReadingCharacteristic = characteristic
                print("[CARACTERÍSTICA DESCOBERTA] \(characteristic.uuid.uuidString)")
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            }
            else if characteristic.uuid.uuidString == PeripheralInfo.volumeControlCharacteristicUUID {
                volumeControlCharacteristic = characteristic
                print("[CARACTERÍSTICA DESCOBERTA] \(characteristic.uuid.uuidString)")
                peripheral.setNotifyValue(true, for: characteristic)
                peripheral.readValue(for: characteristic)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: (any Error)?) {
        guard
            error == nil,
            characteristic.uuid == CBUUID(string: PeripheralInfo.cardsReadingCharacteristicUUID) || characteristic.uuid == CBUUID(
                string: PeripheralInfo.volumeControlCharacteristicUUID
            ),
            let data = characteristic.value,
            let receivedValue = String(data: data, encoding: .utf8)
        else {
            return
        }

        DispatchQueue.main.async {
            if characteristic.uuid.uuidString == PeripheralInfo.cardsReadingCharacteristicUUID {
                self.cardsInSlot = receivedValue
            }
            else if characteristic.uuid.uuidString == PeripheralInfo.volumeControlCharacteristicUUID {
                self.actualVolume = receivedValue
            }
        }
        
    }
}
