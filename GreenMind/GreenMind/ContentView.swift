import SwiftUI
import SwiftData

struct PlantDashboardView: View {

    // MARK: - Plant Data

    @Bindable var plant: Plant

    // MARK: - Computed Properties

    private var isPumpRunning: Bool {
        plant.isAutoPumpRunning || plant.isPumpOn
    }

    private var moistureColor: Color {
        plant.moisture < 30 ? .red : .green
    }

    private var plantStatus: String {
        plant.moisture < 30 ? "Needs Water" : "Healthy"
    }

    // MARK: - User Interface

    var body: some View {

        ScrollView {

            VStack(spacing: 20) {

                // MARK: Connection Status

                HStack {

                    Circle()
                        .fill(plant.isConnected ? .green : .orange)
                        .frame(width: 10, height: 10)

                    Text(plant.isConnected ? "ESP32 Connected" : "Demo Mode")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Button {
                        plant.isConnected.toggle()
                    } label: {
                        Text(plant.isConnected ? "Disconnect" : "Connect")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))


                // MARK: Plant Moisture

                VStack(spacing: 12) {

                    Image(systemName: "leaf.fill")
                        .font(.system(size: 45))
                        .foregroundStyle(moistureColor)

                    Text("Plant Moisture")
                        .font(.headline)

                    Text("\(Int(plant.moisture))%")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(moistureColor)

                    ProgressView(value: plant.moisture, total: 100)
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


                // MARK: Automatic Watering

                VStack(alignment: .leading, spacing: 12) {

                    HStack {

                        Image(systemName: "drop.fill")
                            .foregroundStyle(.blue)

                        Text("Automatic Watering")
                            .font(.headline)

                        Spacer()

                        Toggle("", isOn: $plant.isAutoWatering)
                            .labelsHidden()
                            .onChange(of: plant.isAutoWatering) { _, enabled in

                                if enabled {

                                    // Stop manual watering
                                    plant.isPumpOn = false

                                    // Start automatic watering
                                    // if moisture is below 30%
                                    if plant.moisture < 30 {
                                        plant.isAutoPumpRunning = true
                                    }

                                } else {

                                    // Stop automatic watering
                                    plant.isAutoPumpRunning = false
                                }
                            }
                    }

                    Text("Automatically water the plant when moisture falls below 30%.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))


                // MARK: Water Pump

                VStack(alignment: .leading, spacing: 12) {

                    Text("Water Pump")
                        .font(.headline)

                    HStack {

                        VStack(alignment: .leading, spacing: 8) {

                            Text(isPumpRunning ? "Pump Running" : "Pump Stopped")
                                .fontWeight(.semibold)
                                .foregroundStyle(isPumpRunning ? .blue : .primary)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 5)
                                .background(
                                    isPumpRunning
                                    ? Color.blue.opacity(0.12)
                                    : Color.clear
                                )
                                .clipShape(Capsule())

                            Text(plant.isAutoPumpRunning
                                 ? "Automatic Control"
                                 : "Manual Control")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        }

                        Spacer()

                        Button {

                            if plant.isAutoPumpRunning {

                                // Stop automatic watering
                                plant.isAutoPumpRunning = false
                                plant.isAutoWatering = false
                                plant.isPumpOn = false

                            } else {

                                // Toggle manual pump
                                plant.isPumpOn.toggle()
                            }

                        } label: {

                            Text(isPumpRunning ? "Turn Off" : "Turn On")
                                .fontWeight(.semibold)
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20)
                                .padding(.vertical, 12)
                                .background(isPumpRunning ? .red : .blue)
                                .clipShape(Capsule())
                        }
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))


                // MARK: Ambient LED Status

                VStack(alignment: .leading, spacing: 12) {

                    Text("Ambient LED Status")
                        .font(.headline)

                    HStack {

                        Circle()
                            .fill(moistureColor)
                            .frame(width: 25, height: 25)

                        Text(plant.moisture < 30
                             ? "Red LED — Low Moisture"
                             : "Green LED — Healthy Moisture")
                            .font(.subheadline)

                        Spacer()
                    }
                }
                .padding()
                .background(Color(.secondarySystemBackground))
                .clipShape(RoundedRectangle(cornerRadius: 16))


                // MARK: Demo Sensor

                VStack(alignment: .leading, spacing: 12) {

                    Text("Demo Sensor")
                        .font(.headline)

                    Slider(value: $plant.moisture, in: 0...100)

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
        .navigationTitle(plant.name)

        // MARK: Watering Simulation

        .task {

            while !Task.isCancelled {

                try? await Task.sleep(for: .seconds(2))

                if Task.isCancelled {
                    break
                }

                // Automatic watering

                if plant.isAutoWatering {

                    if plant.moisture < 30 {
                        plant.isAutoPumpRunning = true
                    }

                    if plant.isAutoPumpRunning {

                        plant.moisture = min(plant.moisture + 5, 60)

                        if plant.moisture >= 60 {
                            plant.isAutoPumpRunning = false
                        }
                    }

                }

                // Manual watering

                else if plant.isPumpOn {

                    plant.moisture = min(plant.moisture + 5, 100)

                    if plant.moisture >= 100 {
                        plant.isPumpOn = false
                    }
                }
            }
        }
    }
}
