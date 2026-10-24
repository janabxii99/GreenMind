import SwiftUI

struct AddPlantView: View {

    @Binding var plants: [Plant]

    @Environment(\.dismiss) private var dismiss

    @State private var plantName = ""
    @State private var plantType = "Indoor Plant"

    private let plantTypes = [
        "Indoor Plant",
        "Outdoor Plant",
        "Herb",
        "Flower",
        "Vegetable"
    ]

    private var isPlantNameValid: Bool {
        !plantName.trimmingCharacters(
            in: .whitespacesAndNewlines
        ).isEmpty
    }

    var body: some View {

        VStack(spacing: 32) {

            // Header
            VStack(spacing: 10) {

                Text("Add New Plant")
                    .font(.system(size: 38, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)

                Text("Enter your plant's details below.")
                    .font(.title3)
                    .foregroundStyle(.secondary)
            }

            // Plant name
            VStack(alignment: .leading, spacing: 12) {

                Text("PLANT NAME")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                TextField("Enter plant name", text: $plantName)
                    .font(.title2)
                    .textFieldStyle(.plain)
                    .padding(20)
                    .background(
                        Color.white.opacity(0.08),
                        in: RoundedRectangle(cornerRadius: 16)
                    )
            }

            // Plant type
            VStack(alignment: .leading, spacing: 12) {

                Text("PLANT TYPE")
                    .font(.headline)
                    .foregroundStyle(.secondary)

                Picker("Plant Type", selection: $plantType) {

                    ForEach(plantTypes, id: \.self) { type in
                        Text(type)
                            .tag(type)
                    }
                }
                .pickerStyle(.menu)
                .font(.title2)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.vertical, 12)
                .background(
                    Color.white.opacity(0.08),
                    in: RoundedRectangle(cornerRadius: 16)
                )
            }

            // Buttons
            VStack(spacing: 16) {

                Button {
                    addPlant()
                } label: {

                    Label("Add Plant", systemImage: "plus")
                        .font(.title2.weight(.semibold))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green)
                .disabled(!isPlantNameValid)

                Button("Cancel") {
                    dismiss()
                }
                .font(.title3)
                .buttonStyle(.plain)
            }
        }
        .padding(40)
        .frame(width: 700)
        .background(
            RoundedRectangle(cornerRadius: 28)
                .fill(.regularMaterial)
        )
    }

    private func addPlant() {

        let trimmedName = plantName.trimmingCharacters(
            in: .whitespacesAndNewlines
        )

        guard !trimmedName.isEmpty else {
            return
        }

        let newPlant = Plant(
            name: trimmedName,
            location: plantType,
            moisture: 50,
            temperature: 25,
            needsWater: false
        )

        plants.append(newPlant)

        dismiss()
    }
}
