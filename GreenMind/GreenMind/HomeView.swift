import SwiftUI
import SwiftData

struct HomeView: View {

    // MARK: - Database

    @Environment(\.modelContext) private var modelContext

    @Query(sort: \Plant.createdAt)
    private var plants: [Plant]

    // MARK: - Edit Plant State

    @State private var selectedPlant: Plant?
    @State private var editedPlantName = ""
    @State private var showEditPlant = false

    // MARK: - Connection State

    @State private var showRouterSelection = false
    @State private var connectionStep = 0
    @State private var isConnecting = false

    @State private var connectionTask: Task<Void, Never>?

    @State private var showConnectionResult = false
    @State private var connectionResultMessage = ""
    @State private var connectionResultIsOnline = false

    // MARK: - User Interface

    var body: some View {

        NavigationStack {

            Group {

                // MARK: - Empty Homepage

                if plants.isEmpty {

                    VStack(spacing: 20) {

                        Image(systemName: "leaf.circle")
                            .font(.system(size: 75))
                            .foregroundStyle(.green)

                        Text("GreenMind")
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        Text("Your plants, growing smarter.")
                            .foregroundStyle(.secondary)

                        addPlantMenu
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)

                } else {

                    // MARK: - Homepage with Plants

                    List {

                        ForEach(plants) { plant in

                            NavigationLink {

                                PlantDashboardView(plant: plant)

                            } label: {

                                HStack(spacing: 15) {

                                    Image(systemName: "leaf.fill")
                                        .foregroundStyle(.green)
                                        .font(.title2)

                                    VStack(alignment: .leading, spacing: 5) {

                                        Text(plant.name)
                                            .font(.headline)

                                        Text("Moisture: \(Int(plant.moisture))%")
                                            .font(.subheadline)
                                            .foregroundStyle(.secondary)

                                        Text(
                                            "Router: \(plant.routerName.isEmpty ? "Not connected" : plant.routerName)"
                                        )
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                    }

                                    Spacer()

                                    // Online / Offline Badge

                                    HStack(spacing: 5) {

                                        Circle()
                                            .fill(plant.isOnline ? .green : .gray)
                                            .frame(width: 8, height: 8)

                                        Text(plant.isOnline ? "Online" : "Offline")
                                            .font(.caption)
                                            .fontWeight(.medium)
                                            .foregroundStyle(
                                                plant.isOnline ? .green : .secondary
                                            )
                                    }
                                }
                                .padding(.vertical, 8)
                            }

                            // MARK: - CRUD Actions

                            .swipeActions(edge: .trailing) {

                                // DELETE

                                Button(role: .destructive) {

                                    deletePlant(plant)

                                } label: {

                                    Label("Delete", systemImage: "trash")
                                }

                                // UPDATE

                                Button {

                                    selectedPlant = plant
                                    editedPlantName = plant.name
                                    showEditPlant = true

                                } label: {

                                    Label("Edit", systemImage: "pencil")
                                }
                                .tint(.blue)
                            }
                        }
                    }
                    .listStyle(.insetGrouped)
                }
            }

            // MARK: - Navigation Title

            .navigationTitle("GreenMind")

            // MARK: - Add Plant Toolbar

            .toolbar {

                ToolbarItem(placement: .topBarTrailing) {

                    addPlantMenu
                }
            }

            // MARK: - Router Selection Sheet

            .sheet(isPresented: $showRouterSelection) {

                routerSelectionSheet
            }

            // MARK: - Edit Plant Sheet

            .sheet(isPresented: $showEditPlant) {

                NavigationStack {

                    Form {

                        Section("Plant Information") {

                            TextField(
                                "Plant Name",
                                text: $editedPlantName
                            )
                        }
                    }
                    .navigationTitle("Edit Plant")
                    .navigationBarTitleDisplayMode(.inline)

                    .toolbar {

                        ToolbarItem(placement: .cancellationAction) {

                            Button("Cancel") {

                                showEditPlant = false
                            }
                        }

                        ToolbarItem(placement: .confirmationAction) {

                            Button("Save") {

                                savePlantChanges()
                            }
                            .disabled(
                                editedPlantName
                                    .trimmingCharacters(
                                        in: .whitespacesAndNewlines
                                    )
                                    .isEmpty
                            )
                        }
                    }
                }
            }

            // MARK: - Connection Result Alert

            .alert(
                connectionResultIsOnline ? "Plant Connected!" : "Plant Added Offline",
                isPresented: $showConnectionResult
            ) {

                Button("OK", role: .cancel) { }

            } message: {

                Text(connectionResultMessage)
            }
        }
    }

    // MARK: - Add Plant Menu

    private var addPlantMenu: some View {

        Menu {

            Button {

                openRouterSelection()

            } label: {

                Label(
                    "Scan QR Code",
                    systemImage: "qrcode.viewfinder"
                )
            }

            Button {

                openRouterSelection()

            } label: {

                Label(
                    "Connect via Wi-Fi manually",
                    systemImage: "wifi"
                )
            }

        } label: {

            if plants.isEmpty {

                Label("Add a Plant", systemImage: "plus")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.green)
                    .clipShape(
                        RoundedRectangle(cornerRadius: 15)
                    )

            } else {

                Image(systemName: "plus")
                    .font(.headline)
            }
        }
    }

    // MARK: - Router Selection Screen

    private var routerSelectionSheet: some View {

        NavigationStack {

            VStack(alignment: .leading, spacing: 15) {

                Text("Select a Wi-Fi Router")
                    .font(.title2)
                    .fontWeight(.bold)

                Text(
                    "Choose the router your GreenMind plant device will connect to."
                )
                .font(.subheadline)
                .foregroundStyle(.secondary)

                List {

                    ForEach(WiFiRouter.demoRouters) { router in

                        Button {

                            startConnection(to: router)

                        } label: {

                            HStack(spacing: 15) {

                                Image(systemName: "wifi")
                                    .font(.title2)
                                    .foregroundStyle(.green)

                                VStack(alignment: .leading, spacing: 5) {

                                    Text(router.name)
                                        .font(.headline)
                                        .foregroundStyle(.primary)

                                    Text(router.description)
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }

                                Spacer()

                                if router.hasInternet {

                                    Text("Internet")
                                        .font(.caption)
                                        .foregroundStyle(.green)

                                } else {

                                    Text("No Internet")
                                        .font(.caption)
                                        .foregroundStyle(.orange)
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .disabled(isConnecting)
                    }
                }
                .listStyle(.insetGrouped)
            }
            .padding(.top)
            .navigationTitle("Wi-Fi Setup")
            .navigationBarTitleDisplayMode(.inline)

            .toolbar {

                ToolbarItem(placement: .cancellationAction) {

                    Button("Cancel") {

                        cancelConnection()
                    }
                    .disabled(isConnecting)
                }
            }

            // MARK: - Connection Progress

            .overlay {

                if isConnecting {

                    connectionProgressView
                }
            }
        }
    }

    // MARK: - Connection Progress Screen

    private var connectionProgressView: some View {

        VStack(spacing: 20) {

            ProgressView()
                .scaleEffect(1.5)

            Text("Connecting GreenMind")
                .font(.title2)
                .fontWeight(.bold)

            VStack(alignment: .leading, spacing: 15) {

                connectionStepRow(
                    title: "Connecting to router",
                    step: 1
                )

                connectionStepRow(
                    title: "Registering plant",
                    step: 2
                )

                connectionStepRow(
                    title: "Connecting to cloud",
                    step: 3
                )
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 15))
        }
        .padding(30)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.ultraThinMaterial)
    }

    // MARK: - Connection Step Row

    private func connectionStepRow(
        title: String,
        step: Int
    ) -> some View {

        HStack(spacing: 12) {

            if connectionStep >= step {

                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(.green)

            } else if connectionStep == step - 1 {

                ProgressView()

            } else {

                Image(systemName: "circle")
                    .foregroundStyle(.secondary)
            }

            Text(title)
                .font(.subheadline)
        }
    }

    // MARK: - Open Router Selection

    private func openRouterSelection() {

        showRouterSelection = true
    }

    // MARK: - Start Connection

    private func startConnection(to router: WiFiRouter) {

        guard !isConnecting else {
            return
        }

        connectionStep = 0
        isConnecting = true

        connectionTask?.cancel()

        connectionTask = Task { @MainActor in

            // Step 1: Connect to router

            do {
                try await Task.sleep(for: .seconds(2))
            } catch {
                return
            }

            guard !Task.isCancelled else {
                return
            }

            connectionStep = 1

            // Step 2: Register plant

            do {
                try await Task.sleep(for: .seconds(2))
            } catch {
                return
            }

            guard !Task.isCancelled else {
                return
            }

            connectionStep = 2

            // Step 3: Connect to cloud

            do {
                try await Task.sleep(for: .seconds(2))
            } catch {
                return
            }

            guard !Task.isCancelled else {
                return
            }

            connectionStep = 3

            // MARK: - Fetch Existing Plants

            let fetchDescriptor = FetchDescriptor<Plant>()

            let existingPlants: [Plant]

            do {

                existingPlants = try modelContext.fetch(fetchDescriptor)

            } catch {

                isConnecting = false
                connectionTask = nil
                showRouterSelection = false

                connectionResultIsOnline = false
                connectionResultMessage =
                    "Could not retrieve existing plants from the database."

                showConnectionResult = true

                print("Failed to fetch plants: \(error)")

                return
            }

            // MARK: - Generate Unique Plant Name

            let nextPlantNumber = existingPlants.count + 1

            let newPlant = Plant(
                name: "Plant \(nextPlantNumber)",
                routerName: router.name,
                isOnline: router.hasInternet,
                isConnected: true
            )

            // MARK: - Insert and Save

            modelContext.insert(newPlant)

            do {

                try modelContext.save()

                // Confirm plant count in console

                let savedPlants = try modelContext.fetch(
                    FetchDescriptor<Plant>()
                )

                print("Plants saved in SwiftData: \(savedPlants.count)")

                for plant in savedPlants {

                    print("Plant name: \(plant.name)")
                }

                // MARK: - Connection Result

                connectionResultIsOnline = router.hasInternet

                if router.hasInternet {

                    connectionResultMessage =
                        "\(newPlant.name) has been connected successfully to \(router.name)."

                } else {

                    connectionResultMessage =
                        "\(newPlant.name) was added, but \(router.name) has no internet connection. The plant is currently Offline."
                }

            } catch {

                // Roll back failed plant

                modelContext.delete(newPlant)

                connectionResultIsOnline = false

                connectionResultMessage =
                    "GreenMind could not save the new plant. Please try again."

                print("Failed to save plant: \(error)")
            }

            // MARK: - Finish Connection

            isConnecting = false
            connectionTask = nil

            // Close router selection sheet

            showRouterSelection = false

            // Show result

            showConnectionResult = true
        }
    }

    // MARK: - Cancel Connection

    private func cancelConnection() {

        connectionTask?.cancel()
        connectionTask = nil

        isConnecting = false
        connectionStep = 0

        showRouterSelection = false
    }

    // MARK: - CREATE

    private func addDemoPlant() {

        let newPlant = Plant(
            name: "Plant \(plants.count + 1)"
        )

        modelContext.insert(newPlant)
    }

    // MARK: - UPDATE

    private func savePlantChanges() {

        guard let selectedPlant = selectedPlant else {
            return
        }

        let newName = editedPlantName
            .trimmingCharacters(in: .whitespacesAndNewlines)

        guard !newName.isEmpty else {
            return
        }

        selectedPlant.name = newName

        showEditPlant = false
    }

    // MARK: - DELETE

    private func deletePlant(_ plant: Plant) {

        modelContext.delete(plant)
    }
}

// MARK: - Dummy Wi-Fi Router Model

struct WiFiRouter: Identifiable {

    let id = UUID()

    let name: String
    let description: String
    let hasInternet: Bool

    static let demoRouters = [

        WiFiRouter(
            name: "Dialog Home Wi-Fi",
            description: "Strong signal",
            hasInternet: true
        ),

        WiFiRouter(
            name: "SLT Fiber Router",
            description: "Strong signal",
            hasInternet: true
        ),

        WiFiRouter(
            name: "Mobile Hotspot",
            description: "Medium signal",
            hasInternet: true
        ),

        WiFiRouter(
            name: "Garden Router",
            description: "No internet connection",
            hasInternet: false
        )
    ]
}
