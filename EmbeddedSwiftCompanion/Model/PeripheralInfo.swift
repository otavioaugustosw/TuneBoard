import CoreBluetooth
import SwiftUI

struct PeripheralInfo {
    static var color: Color = .orange
        
    static var peripheralName = "PERIPHERAL NAME"
    
    static var serviceUUID = CBUUID(string: "12345678-1234-5678-1234-56789ABCDEF0")
    
    var userPeripheralDisplayName = "DISPLAY NAME"
}
