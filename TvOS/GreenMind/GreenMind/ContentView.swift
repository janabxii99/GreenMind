import SwiftUI
// MARK: - Plant Model
struct Plant: Identifiable {
    let id = UUID()
    var name: String
    var location: String
    var moisture: Int
    var temperature: Int
    var needsWater: Bool
}
// MARK: - Sample Data
let samplePlants: [Plant] = [
    Plant(
        name: "Monstera",
        location: "Living Room",
        moisture: 35,
        temperature: 25,
        needsWater: true
    ),
    Plant(
        name: "Snake Plant",
        location: "Bedroom",
        moisture: 68,
        temperature: 24,
        needsWater: false
    ),
    Plant(
        name: "Peace Lily",
        location: "Kitchen",
        moisture: 22,
        temperature: 26,
        needsWater: true
    )
]
// MARK: - Dashboard
struct ContentView: View {
    @State private var plants = samplePlants
    @State private var showingAddPlant = false
    var body: some View {
        NavigationStack {
            VStack(spacing: 18) {
                // Header
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("GreenMind")
                            .font(.system(size: 30, weight: .bold))
                        Text("Your plant dashboard")
                            .font(.system(size: 17))
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Text("\(plants.count) Plants")
                        .font(.system(size: 16, weight: .semibold))
                        .padding(12)
                        .background(.thinMaterial)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                // Plant List
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(plants) { plant in
                            NavigationLink {
                                PlantDetailView(
                                    plant: plant,
                                    plants: $plants
                                )
                            } label: {
                                PlantCard(plant: plant)
                            }
                            .buttonStyle(.card)
                        }
                    }
                }
                // Add Plant Button
                Button {
                    showingAddPlant = true
                } label: {
                    Label(
                        "Add New Plant",
                        systemImage: "plus.circle.fill"
                    )
                    .font(.system(size: 19, weight: .semibold))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 15)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
            }
            .padding(28)
            .navigationTitle("Dashboard")
        }
        .sheet(isPresented: $showingAddPlant) {
            AddPlantView(plants: $plants)
        }
    }
}
// MARK: - Plant Card
struct PlantCard: View {
    let plant: Plant
    var body: some View {
        HStack(spacing: 18) {
            Image(systemName: "leaf.fill")
                .font(.system(size: 30))
                .foregroundStyle(.green)
                .frame(width: 65, height: 65)
                .background(.green.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 15))
            VStack(alignment: .leading, spacing: 6) {
                Text(plant.name)
                    .font(.system(size: 21, weight: .bold))
                    .lineLimit(1)
                Text(plant.location)
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                Label(
                    "Moisture: \(plant.moisture)%",
                    systemImage: "drop.fill"
                )
                .font(.system(size: 15))
                .foregroundStyle(.secondary)
            }
            Spacer(minLength: 12)
            VStack(alignment: .trailing, spacing: 6) {
                Text(plant.needsWater ? "Needs Water" : "Healthy")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(
                        plant.needsWater ? .orange : .green
                    )
                    .lineLimit(1)
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundStyle(.secondary)
            }
        }
        .padding(20)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
}
// MARK: - Plant Detail
struct PlantDetailView: View {
    @State private var plant: Plant
    @Binding var plants: [Plant]
    @State private var showingEdit = false
    @State private var showingDeleteConfirmation = false
    // Explicit initializer fixes inaccessible initializer error
    init(
        plant: Plant,
        plants: Binding<[Plant]>
    ) {
        self._plant = State(initialValue: plant)
        self._plants = plants
    }
    var body: some View {
        VStack(spacing: 22) {
            // Plant Icon
            Image(systemName: "leaf.fill")
                .font(.system(size: 65))
                .foregroundStyle(.green)
            // Plant Name and Location
            VStack(spacing: 6) {
                Text(plant.name)
                    .font(.system(size: 28, weight: .bold))
                    .lineLimit(1)
                Text(plant.location)
                    .font(.system(size: 18))
                    .foregroundStyle(.secondary)
            }
            // Plant Measurements
            HStack(spacing: 20) {
                detailCard(
                    title: "Moisture",
                    value: "\(plant.moisture)%",
                    icon: "drop.fill"
                )
                detailCard(
                    title: "Temperature",
                    value: "\(plant.temperature)°C",
                    icon: "thermometer"
                )
            }
            // Plant Health
            Text(
                plant.needsWater
                ? "This plant needs water."
                : "This plant is healthy."
            )
            .font(.system(size: 18, weight: .medium))
            .foregroundStyle(
                plant.needsWater ? .orange : .green
            )
            Spacer(minLength: 10)
            // Edit and Delete Actions
            HStack(spacing: 18) {
                Button {
                    showingEdit = true
                } label: {
                    Label("Edit Plant", systemImage: "pencil")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                Button(role: .destructive) {
                    showingDeleteConfirmation = true
                } label: {
                    Label("Delete Plant", systemImage: "trash")
                        .font(.system(size: 17, weight: .semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 15)
                }
                .buttonStyle(.bordered)
            }
        }
        .padding(30)
        .navigationTitle("Plant Details")
        // Edit Plant Sheet
        .sheet(isPresented: $showingEdit) {
            EditPlantView(
                plant: plant,
                plants: $plants
            ) { updatedPlant in
                plant = updatedPlant
            }
        }
        // Delete Confirmation
        .confirmationDialog(
            "Delete \(plant.name)?",
            isPresented: $showingDeleteConfirmation,
            titleVisibility: .visible
        ) {
            Button("Delete Plant", role: .destructive) {
                deletePlant()
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This plant will be removed from your dashboard.")
        }
    }
    // MARK: Detail Card
    private func detailCard(
        title: String,
        value: String,
        icon: String
    ) -> some View {
        VStack(spacing: 10) {
            Image(systemName: icon)
                .font(.system(size: 25))
                .foregroundStyle(.green)
            Text(title)
                .font(.system(size: 16))
                .foregroundStyle(.secondary)
            Text(value)
                .font(.system(size: 22, weight: .bold))
        }
        .frame(width: 190, height: 140)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
    }
    // MARK: Delete Plant
    private func deletePlant() {
        plants.removeAll {
            $0.id == plant.id
        }
    }
}
// MARK: - Edit Plant
struct EditPlantView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var plantName: String
    @State private var plantLocation: String
    @Binding var plants: [Plant]
    let plantID: UUID
    let onSave: (Plant) -> Void
    // Initialize Edit Fields
    init(
        plant: Plant,
        plants: Binding<[Plant]>,
        onSave: @escaping (Plant) -> Void
    ) {
        self.plantID = plant.id
        self._plantName = State(
            initialValue: plant.name
        )
        self._plantLocation = State(
            initialValue: plant.location
        )
        self._plants = plants
        self.onSave = onSave
    }
    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            // Header
            VStack(alignment: .leading, spacing: 5) {
                Text("Edit Plant")
                    .font(.system(size: 28, weight: .bold))
                Text("Update your plant information")
                    .font(.system(size: 16))
                    .foregroundStyle(.secondary)
            }
            // Plant Name
            VStack(alignment: .leading, spacing: 8) {
                Text("Plant Name")
                    .font(.system(size: 16, weight: .semibold))
                TextField("Enter plant name", text: $plantName)
                    .font(.system(size: 18))
                    .padding(14)
                    .background(
                        Color.white.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
            }
            // Plant Location
            VStack(alignment: .leading, spacing: 8) {
                Text("Location")
                    .font(.system(size: 16, weight: .semibold))
                TextField("Enter location", text: $plantLocation)
                    .font(.system(size: 18))
                    .padding(14)
                    .background(
                        Color.white.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
            }
            Spacer(minLength: 10)
            // Save Changes
            Button {
                savePlant()
            } label: {
                Label(
                    "Save Changes",
                    systemImage: "checkmark"
                )
                .font(.system(size: 18, weight: .semibold))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
            .disabled(
                plantName.trimmingCharacters(
                    in: .whitespacesAndNewlines
                ).isEmpty
            )
            // Cancel
            Button("Cancel") {
                dismiss()
            }
            .font(.system(size: 16))
            .frame(maxWidth: .infinity)
        }
        .padding(30)
        .frame(width: 550, height: 430)
    }
    // MARK: Save Plant
    private func savePlant() {
        let trimmedName = plantName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        let trimmedLocation = plantLocation.trimmingCharacters(
            in: .whitespacesAndNewlines
        )
        guard !trimmedName.isEmpty else {
            return
        }
        // Find the correct plant using UUID
        guard let index = plants.firstIndex(where: {
            $0.id == plantID
        }) else {
            return
        }
        // Update plant information
        plants[index].name = trimmedName
        plants[index].location = trimmedLocation
        // Refresh Detail View
        onSave(plants[index])
        // Close Edit Screen
        dismiss()
    }
}
