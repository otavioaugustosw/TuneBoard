import SwiftUI
import Playgrounds

struct SetupViewOLD: View {
    @State var peripheralSM = PeripheralSessionManager()

    var body: some View {
        NavigationStack {
            Group {
                if peripheralSM.pickerDismissed, let peripheralInfo = peripheralSM.peripheralInfo {
                    makePeripheralView(peripheralInfo: peripheralInfo)
                        .navigationTitle(peripheralInfo.userPeripheralDisplayName)
                } else {
                    makeSetupView
                }
            }
        }
    }

    @ViewBuilder
    private var makeSetupView: some View {
        VStack {
            Spacer()

            Image(systemName: "memorychip.fill")
                .font(.system(size: 150, weight: .light, design: .default))
                .foregroundStyle(.gray)

            Text("Sem ESP32")
                .font(Font.title.weight(.bold))
                .padding(.vertical, 12)

            Text("Mantenha seu iPhone próximo a um ESP32 com Swift")
                .font(.subheadline)
                .multilineTextAlignment(.center)

            Spacer()

            Button {
                peripheralSM.presentPicker()
            } label: {
                Text("Conectar ao ESP32")
                    .frame(maxWidth: .infinity)
                    .font(Font.headline.weight(.semibold))
            }
            .buttonStyle(.bordered)
            .buttonBorderShape(.roundedRectangle)
            .foregroundStyle(.primary)
            .controlSize(.large)
            .padding(.top, 110)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(64)
    }

    private func getCardNums() -> [Int]{
        guard let receivedValue = peripheralSM.receivedValue else {
            print("Valor recebido é nulo. A retornar array vazio.")
            return [Int](repeating: 0, count: 6)
        }
        let cardNumbers = receivedValue.compactMap { $0.wholeNumberValue }
        return cardNumbers
    }
    
    @ViewBuilder
    private func makePeripheralView(peripheralInfo: PeripheralInfo) -> some View {
        let cardNumbers = getCardNums()
        VStack {

            if !cardNumbers.isEmpty {
                Text("SLOT 1: ")
                    .font(.system(.title).monospaced().bold())
                    .foregroundStyle(PeripheralInfo.color)
                    .contentTransition(.numericText())
                    .frame(maxHeight: .infinity)
            }

            Button {
                peripheralSM.peripheralConnected ? peripheralSM
                    .disconnect() : peripheralSM
                    .connect()
            } label: {
                Text(
                    peripheralSM.peripheralConnected ? "Desconectar" : "Conectar"
                )
                .frame(maxWidth: .infinity)
                .font(Font.headline.weight(.semibold))
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
            .tint(.orange)
            .foregroundStyle(.white)
            .padding(.horizontal, 64)
            .padding(.bottom, 6)

            Button {
                peripheralSM.removePeripheral()
            } label: {
                Text("Remover")
                    .foregroundStyle(.red)
                    .font(Font.headline.weight(.semibold))
            }
            .padding(.bottom, 35)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}


#Preview {
    SetupView()
}
