

import Foundation

enum Analytics {
    enum Event: String { case open, close, click }

    enum Screen: String {
        case main = "Main"
        case statistics = "Statistics"
    }

    enum Item: String {
        case addTrack = "add_track"
        case track
        case filter
        case edit
        case delete
    }
}
