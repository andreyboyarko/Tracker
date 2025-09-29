

import Foundation

struct TrackerRecord {
    let id: UUID
    let date: Date
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
