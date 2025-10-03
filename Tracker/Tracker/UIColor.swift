

import UIKit

extension UIColor {
    /// "#RRGGBB" из UIColor
    var hex6: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1
        guard getRed(&r, green: &g, blue: &b, alpha: &a) else { return "#999999" }
        return String(format: "#%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
    }

    /// Синоним на всякий случай (чтобы .hexString тоже работал)
    var hexString: String { hex6 }

    /// UIColor из строки "#RRGGBB"
    convenience init?(hex6: String) {
        let s = hex6.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        guard s.count == 6, let v = UInt32(s, radix: 16) else { return nil }
        self.init(
            red:   CGFloat((v >> 16) & 0xFF) / 255.0,
            green: CGFloat((v >>  8) & 0xFF) / 255.0,
            blue:  CGFloat( v        & 0xFF) / 255.0,
            alpha: 1.0
        )
    }
}
