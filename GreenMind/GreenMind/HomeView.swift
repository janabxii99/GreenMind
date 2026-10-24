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
                        
                        // MARK: Add Plant Dropdown
                        
                        Menu {
                            
                            Button {
                                // QR scanning will be implemented later
                            } label: {
                                Label(
                                    "Scan QR Code",
                                    systemImage: "qrcode.viewfinder"
                                )
                            }
                            
                            Button {
                                addDemoPlant()
                            } label: {
                                Label(
                                    "Connect via Wi-Fi manually",
                                    systemImage: "wifi"
                                )
                            }
                            
                        } label: {
                            
                            Label("Add a Plant", systemImage: "plus")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(.green)
                                .clipShape(
                                    RoundedRectangle(cornerRadius: 15)
                                )
                        }
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
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.caption)
                                        .foregroundStyle(.secondary)
                                }
                                .padding(.vertical, 8)
                            }
                            
                            // MARK: - CRUD Actions
                            
                            .swipeActions(edge: .trailing) {
                                
                                // DELETE
                                
                                Button(role: .destructive) {
                                    
                                    deletePlant(plant)
                                    
                                } label: {
                                    
                                    Label(
                                        "Delete",
                                        systemImage: "trash"
                                    )
                                }
                                
                                // UPDATE
                                
                                Button {
                                    
                                    selectedPlant = plant
                                    editedPlantName = plant.name
                                    showEditPlant = true
                                    
                                } label: {
                                    
                                    Label(
                                        "Edit",
                                        systemImage: "pencil"
                                    )
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
                    
                    Menu {
                        
                        Button {
                            // QR scanning will be implemented later
                        } label: {
                            Label(
                                "Scan QR Code",
                                systemImage: "qrcode.viewfinder"
                            )
                        }
                        
                        Button {
                            addDemoPlant()
                        } label: {
                            Label(
                                "Connect via Wi-Fi manually",
                                systemImage: "wifi"
                            )
                        }
                        
                    } label: {
                        
                        Image(systemName: "plus")
                            .font(.headline)
                    }
                }
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
                        
                        // CANCEL
                        
                        ToolbarItem(placement: .cancellationAction) {
                            
                            Button("Cancel") {
                                
                                showEditPlant = false
                            }
                        }
                        
                        // SAVE
                        
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
        }
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
