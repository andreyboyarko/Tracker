

import UIKit

extension UIColor {
    var hex6: String {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 1
        guard getRed(&r, green: &g, blue: &b, alpha: &a) else { return "#999999" }
        return String(format: "#%02X%02X%02X", Int(r*255), Int(g*255), Int(b*255))
    }
}
