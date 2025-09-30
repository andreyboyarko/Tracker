

import Foundation

struct TrackerRecord: Hashable {
    let trackerId: UUID
    let date: Date

    init(trackerId: UUID, date: Date) {
        self.trackerId = trackerId
        // нормализуем к началу суток
        self.date = Calendar.current.startOfDay(for: date)
    }
}

//
//import Foundation
//
//public struct TrackerRecord: Codable, Hashable {
//    public let trackerId: UUID
//    public let date: Date
//
//    public init(trackerId: UUID, date: Date) {
//        self.trackerId = trackerId
//        self.date = Calendar.current.startOfDay(for: date)
//    }
//}
