import SwiftUI

struct ContentView: View {
    @State private var moisture: Double = 38
    @State private var isAutoWatering = true
    @State private var isPumpOn = false
    @State private var isConnected = false

    private var moistureColor: Color {
        moisture < 30 ? .red : .green
    }

    private var plantStatus: String {
        moisture < 30 ? "Needs Water" : "Healthy"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 20) {

                    // Connection status
                    HStack {
                        Circle()
                            .fill(isConnected ? .green : .orange)
                            .frame(width: 10, height: 10)

                        Text(isConnected ? "ESP32 Connected" : "Demo Mode")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        Spacer()

                        Button {
                            isConnected.toggle()
                        } label: {
                            Text(isConnected ? "Disconnect" : "Connect")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Plant moisture
                    VStack(spacing: 12) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 45))
                            .foregroundStyle(moistureColor)

                        Text("Plant Moisture")
                            .font(.headline)

                        Text("\(Int(moisture))%")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(moistureColor)

                        ProgressView(value: moisture, total: 100)
                            .tint(moistureColor)

                        Text(plantStatus)
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundStyle(moistureColor)
                    }
                    .padding(24)
                    .frame(maxWidth: .infinity)
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 20))

                    // Automatic watering
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "drop.fill")
                                .foregroundStyle(.blue)

                            Text("Automatic Watering")
                                .font(.headline)

                            Spacer()

                            Toggle("", isOn: $isAutoWatering)
                                .labelsHidden()
                        }

                        Text("Automatically water the plant when moisture falls below 30%.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Manual pump control
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Water Pump")
                            .font(.headline)

                        HStack {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(isPumpOn ? "Pump Running" : "Pump Stopped")
                                    .fontWeight(.semibold)

                                Text("Manual Control")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Button {
                                isPumpOn.toggle()

                                // Demo: watering raises moisture
                                if isPumpOn {
                                    moisture = min(moisture + 15, 100)
                                }
                            } label: {
                                Text(isPumpOn ? "Turn Off" : "Turn On")
                                    .fontWeight(.semibold)
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 12)
                                    .background(isPumpOn ? .red : .blue)
                                    .clipShape(Capsule())
                            }
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Ambient LED status
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ambient LED Status")
                            .font(.headline)

                        HStack {
                            Circle()
                                .fill(moistureColor)
                                .frame(width: 25, height: 25)

                            Text(moisture < 30
                                 ? "Red LED — Low Moisture"
                                 : "Green LED — Healthy Moisture")
                                .font(.subheadline)

                            Spacer()
                        }
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                    // Simulated sensor testing
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Demo Sensor")
                            .font(.headline)

                        Slider(value: $moisture, in: 0...100)

                        Text("Move the slider to simulate soil moisture readings.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.secondarySystemBackground))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding()
            }
            .navigationTitle("GreenMind")
        }
    }
}

#Preview {
    ContentView()
}
