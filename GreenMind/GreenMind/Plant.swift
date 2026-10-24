import Foundation
import SwiftData
@Model
final class Plant {
    var id: UUID
    var name: String
    var deviceID: String
    var createdAt: Date
    // Wi-Fi and cloud connection
    var routerName: String
    var isOnline: Bool
    // Plant dashboard data
    var moisture: Double
    var isAutoWatering: Bool
    var isPumpOn: Bool
    var isConnected: Bool
    var isAutoPumpRunning: Bool
    init(
        name: String,
        deviceID: String = "",
        routerName: String = "",
        isOnline: Bool = false,
        moisture: Double = 38,
        isAutoWatering: Bool = true,
        isPumpOn: Bool = false,
        isConnected: Bool = false,
        isAutoPumpRunning: Bool = false
    ) {
        self.id = UUID()
        self.name = name
        self.deviceID = deviceID
        self.createdAt = Date()
        self.routerName = routerName
        self.isOnline = isOnline
        self.moisture = moisture
        self.isAutoWatering = isAutoWatering
        self.isPumpOn = isPumpOn
        self.isConnected = isConnected
        self.isAutoPumpRunning = isAutoPumpRunning
    }
}
