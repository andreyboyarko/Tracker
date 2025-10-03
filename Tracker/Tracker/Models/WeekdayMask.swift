import Foundation

enum WeekdayMask {
    /// Пн=бит0 … Вс=бит6
    static func make(from set: Set<WeekdaysEnum>) -> UInt16 {
        set.reduce(0) { acc, d in
            let bit: Int
            switch d {
            case .monday:    bit = 0
            case .tuesday:   bit = 1
            case .wednesday: bit = 2
            case .thursday:  bit = 3
            case .friday:    bit = 4
            case .saturday:  bit = 5
            case .sunday:    bit = 6
            }
            return acc | (1 << bit)
        }
    }

    static func toSet(_ mask: UInt16) -> Set<WeekdaysEnum> {
        var s = Set<WeekdaysEnum>()
        if (mask & (1<<0)) != 0 { s.insert(.monday) }
        if (mask & (1<<1)) != 0 { s.insert(.tuesday) }
        if (mask & (1<<2)) != 0 { s.insert(.wednesday) }
        if (mask & (1<<3)) != 0 { s.insert(.thursday) }
        if (mask & (1<<4)) != 0 { s.insert(.friday) }
        if (mask & (1<<5)) != 0 { s.insert(.saturday) }
        if (mask & (1<<6)) != 0 { s.insert(.sunday) }
        return s
    }
}
