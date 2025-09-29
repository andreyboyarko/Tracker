
import Foundation

import Foundation

struct Tracker: Hashable {
    let id: UUID
    let name: String
    let colorHex: String
    let emoji: String
    let schedule: Set<WeekdaysEnum>

    init(
        id: UUID = UUID(),
        name: String,
        colorHex: String,
        emoji: String,
        schedule: Set<WeekdaysEnum>
    ) {
        self.id = id
        self.name = name
        self.colorHex = colorHex
        self.emoji = emoji
        self.schedule = schedule
    }
}
//import Foundation
//
//public struct Tracker: Codable, Hashable {
//    public let id: UUID
//    public let name: String
//    
//    public let colorHex: String
//    public let emoji: String
//  
//    public let schedule: Set<Weekday>
//
//    public init(
//        id: UUID = UUID(),
//        name: String,
//        colorHex: String,
//        emoji: String,
//        schedule: Set<Weekday>
//    ) {
//        self.id = id
//        self.name = name
//        self.colorHex = colorHex
//        self.emoji = emoji
//        self.schedule = schedule
//    }
//}
