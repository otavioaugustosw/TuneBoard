import CoreBluetooth
import AccessorySetupKit
import SwiftUI

struct PeripheralInfo {
    public static let peripheralName = "TuneBoard"
    public static let serviceUUID = CBUUID(string: "8ABD86E9-E32C-4784-92BC-3AA99666C544")
    public static let cardsReadingCharacteristicUUID = "F83317EA-84F8-475E-9D60-920BF2225C2D"
    public static let volumeControlCharacteristicUUID = "2E0BDAC2-C1FF-4C6C-83C6-B5DC11D0D3F2"
    
    // essa informação aparece no picker
    public static let tuneboardDeviceInfo: ASPickerDisplayItem = {
        let descriptor = ASDiscoveryDescriptor()
        descriptor.bluetoothServiceUUID = serviceUUID
        return ASPickerDisplayItem(
            name: PeripheralInfo.peripheralName,
            productImage: UIImage(named: "pickerImage")!,
            descriptor: descriptor
        )
    }()
    
    // este nome pode ser alterado pelo usuário nas configurações
    public var userPeripheralDisplayName = "TuneBoard"
}
