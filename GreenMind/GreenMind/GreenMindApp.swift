import SwiftUI
import SwiftData

@main
struct GreenMindApp: App {

    var body: some Scene {
        WindowGroup {
            HomeView()
        }
        .modelContainer(for: Plant.self)
    }
}
