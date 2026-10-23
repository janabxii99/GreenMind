import Foundation
import SwiftData

@Model
final class Plant {

    var name: String
    var species: String
    var moisture: Int
    var icon: String
    var lastWatered: String

    init(
        name: String,
        species: String,
        moisture: Int,
        icon: String,
        lastWatered: String
    ) {
        self.name = name
        self.species = species
        self.moisture = moisture
        self.icon = icon
        self.lastWatered = lastWatered
    }
}
