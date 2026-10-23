import SwiftUI
import SwiftData

struct ContentView: View {

    // MARK: - SwiftData

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Plant.name)
    private var plants: [Plant]

    // MARK: - State

    @State private var selectedPlant: Plant?
    @State private var showingAddPlant = false

    // MARK: - Body

    var body: some View {

        NavigationStack {

            ZStack {

                Color(red: 0.95, green: 0.97, blue: 0.93)
                    .ignoresSafeArea()

                ScrollView {

                    VStack(alignment: .leading, spacing: 24) {

                        // Header
                        VStack(alignment: .leading, spacing: 6) {

                            Text("GreenMind")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.green)

                            Text("Your plants, thriving together.")
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }

                        // Summary
                        HStack(spacing: 12) {

                            SummaryCard(
                                title: "My Plants",
                                value: "\(plants.count)",
                                icon: "leaf.fill"
                            )

                            SummaryCard(
                                title: "Need Water",
                                value: "\(plants.filter { $0.moisture < 30 }.count)",
                                icon: "drop.fill"
                            )
                        }

                        // Garden heading
                        HStack {

                            Text("My Garden")
                                .font(.title2)
                                .fontWeight(.bold)

                            Spacer()

                            Button {
                                showingAddPlant = true
                            } label: {

                                Image(systemName: "plus")
                                    .font(.headline)
                                    .foregroundStyle(.white)
                                    .frame(width: 42, height: 42)
                                    .background(Color.green)
                                    .clipShape(Circle())
                            }
                        }

                        // Plant cards
                        VStack(spacing: 16) {

                            if plants.isEmpty {

                                Text("No plants yet. Add your first plant!")
                                    .foregroundStyle(.secondary)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                            }

                            ForEach(plants) { plant in

                                PlantCard(plant: plant) {

                                    selectedPlant = plant
                                }
                            }
                        }
                    }
                    .padding(20)
                }
            }
            .navigationBarHidden(true)

            // Plant details
            .sheet(item: $selectedPlant) { plant in

                PlantDetailView(plant: plant)
            }

            // Add plant
            .sheet(isPresented: $showingAddPlant) {

                AddPlantView()
            }

            // Seed sample plants on first launch
            .task {

                addSamplePlantsIfNeeded()
            }
        }
    }

    // MARK: - Sample Plants

    private func addSamplePlantsIfNeeded() {

        guard plants.isEmpty else {
            return
        }

        let samplePlants = [

            Plant(
                name: "Monstera",
                species: "Monstera Deliciosa",
                moisture: 42,
                icon: "leaf.fill",
                lastWatered: "2 days ago"
            ),

            Plant(
                name: "Snake Plant",
                species: "Dracaena Trifasciata",
                moisture: 78,
                icon: "leaf",
                lastWatered: "5 days ago"
            ),

            Plant(
                name: "Peace Lily",
                species: "Spathiphyllum",
                moisture: 25,
                icon: "leaf.fill",
                lastWatered: "4 days ago"
            )
        ]

        for plant in samplePlants {

            modelContext.insert(plant)
        }

        do {

            try modelContext.save()

        } catch {

            print("Could not save sample plants: \(error)")
        }
    }
}


// MARK: - Summary Card

struct SummaryCard: View {

    let title: String
    let value: String
    let icon: String

    var body: some View {

        VStack(alignment: .leading, spacing: 12) {

            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.green)

            Text(value)
                .font(.largeTitle)
                .fontWeight(.bold)

            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(18)
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}


// MARK: - Plant Card

struct PlantCard: View {

    let plant: Plant
    let onTap: () -> Void

    private var moistureColor: Color {

        if plant.moisture < 30 {
            return .orange
        } else if plant.moisture > 70 {
            return .blue
        } else {
            return .green
        }
    }

    private var moistureStatus: String {

        if plant.moisture < 30 {
            return "Needs watering"
        } else if plant.moisture > 70 {
            return "Very moist"
        } else {
            return "Looking healthy"
        }
    }

    var body: some View {

        Button(action: onTap) {

            VStack(alignment: .leading, spacing: 16) {

                HStack {

                    Image(systemName: plant.icon)
                        .font(.system(size: 32))
                        .foregroundStyle(Color.green)
                        .frame(width: 70, height: 70)
                        .background(Color.green.opacity(0.10))
                        .clipShape(RoundedRectangle(cornerRadius: 16))

                    VStack(alignment: .leading, spacing: 5) {

                        Text(plant.name)
                            .font(.title3)
                            .fontWeight(.bold)
                            .foregroundStyle(.primary)

                        Text(plant.species)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Text(moistureStatus)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundStyle(moistureColor)
                    }

                    Spacer()

                    Image(systemName: "chevron.right")
                        .foregroundStyle(.secondary)
                }

                HStack {

                    Label("Soil Moisture", systemImage: "drop.fill")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text("\(plant.moisture)%")
                        .font(.headline)
                        .foregroundStyle(moistureColor)
                }

                ProgressView(
                    value: Double(plant.moisture),
                    total: 100
                )
                .tint(moistureColor)

                HStack {

                    Text("Last watered")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    Spacer()

                    Text(plant.lastWatered)
                        .font(.caption)
                        .fontWeight(.medium)
                        .foregroundStyle(.secondary)
                }
            }
            .padding(18)
            .background(.white)
            .clipShape(RoundedRectangle(cornerRadius: 22))
        }
        .buttonStyle(.plain)
    }
}


// MARK: - Add Plant View

struct AddPlantView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var species = ""
    @State private var moisture = 50

    var body: some View {

        NavigationStack {

            Form {

                Section("Plant Information") {

                    TextField("Plant Name", text: $name)

                    TextField("Species", text: $species)
                }

                Section("Soil Moisture") {

                    HStack {

                        Text("Current Moisture")

                        Spacer()

                        Text("\(moisture)%")
                            .fontWeight(.bold)
                    }

                    Slider(
                        value: Binding(
                            get: { Double(moisture) },
                            set: { moisture = Int($0) }
                        ),
                        in: 0...100,
                        step: 1
                    )
                    .tint(.green)
                }
            }
            .navigationTitle("Add Plant")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(placement: .cancellationAction) {

                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {

                    Button("Save") {
                        savePlant()
                    }
                    .disabled(name.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private func savePlant() {

        let newPlant = Plant(
            name: name,
            species: species.isEmpty ? "Unknown Species" : species,
            moisture: moisture,
            icon: "leaf.fill",
            lastWatered: "Not watered yet"
        )

        modelContext.insert(newPlant)

        do {

            try modelContext.save()
            dismiss()

        } catch {

            print("Could not save plant: \(error)")
        }
    }
}


// MARK: - Plant Details

struct PlantDetailView: View {

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @Bindable var plant: Plant

    var body: some View {

        NavigationStack {

            VStack(spacing: 24) {

                Image(systemName: plant.icon)
                    .font(.system(size: 90))
                    .foregroundStyle(Color.green)
                    .padding(30)
                    .background(Color.green.opacity(0.10))
                    .clipShape(Circle())

                Text(plant.name)
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text(plant.species)
                    .foregroundStyle(.secondary)

                VStack(spacing: 12) {

                    Text("Current Soil Moisture")
                        .font(.headline)

                    Text("\(plant.moisture)%")
                        .font(.system(size: 50, weight: .bold))
                        .foregroundStyle(Color.green)

                    ProgressView(
                        value: Double(plant.moisture),
                        total: 100
                    )
                    .tint(.green)
                }
                .padding()
                .background(Color.green.opacity(0.08))
                .clipShape(RoundedRectangle(cornerRadius: 20))

                Text("Last watered: \(plant.lastWatered)")
                    .foregroundStyle(.secondary)

                Button {

                    waterPlant()

                } label: {

                    Label(
                        "Mark as Watered",
                        systemImage: "drop.fill"
                    )
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                Spacer()
            }
            .padding(24)
            .navigationTitle("Plant Details")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(placement: .confirmationAction) {

                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }

    private func waterPlant() {

        plant.moisture = 100
        plant.lastWatered = "Just now"

        do {

            try modelContext.save()

        } catch {

            print("Could not update watering information: \(error)")
        }
    }
}
