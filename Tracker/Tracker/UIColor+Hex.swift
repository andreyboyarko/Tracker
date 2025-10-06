import UIKit

extension UIColor {
    /// Надёжно извлекаем RGBA из любой UIColor (включая named colors из ассетов)
    private func rgbaComponentsSRGB() -> (r: CGFloat, g: CGFloat, b: CGFloat, a: CGFloat)? {
        // Разрешаем динамические цвета для текущих traitов
        let resolved = self.resolvedColor(with: UITraitCollection.current)

        // Пробуем конвертировать CGColor в sRGB
        if let sRGB = CGColorSpace(name: CGColorSpace.sRGB),
           let converted = resolved.cgColor.converted(to: sRGB, intent: .defaultIntent, options: nil),
           let comps = converted.components
        {
            // у sRGB ожидаем 4 компоненты
            if comps.count >= 4 { return (comps[0], comps[1], comps[2], comps[3]) }
            // иногда бывает 2 компоненты (grayscale + alpha)
            if comps.count == 2 { return (comps[0], comps[0], comps[0], comps[1]) }
        }

        // Последний шанс — CIColor
        let ci = CIColor(color: resolved)
        return (ci.red, ci.green, ci.blue, ci.alpha)
    }

    /// HEX «RRGGBBAA» (без #)
    var hexRGBA: String {
        guard let c = rgbaComponentsSRGB() else { return "000000FF" }
        return String(format: "%02X%02X%02X%02X",
                      Int(c.r * 255), Int(c.g * 255), Int(c.b * 255), Int(c.a * 255))
    }

    /// Инициализация из "RRGGBB", "RRGGBBAA" (и с `#` тоже ок)
    convenience init?(hexAny: String) {
        let s = hexAny.trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
            .uppercased()

        guard (s.count == 6 || s.count == 8), let v = UInt32(s, radix: 16) else { return nil }

        let r, g, b, a: CGFloat
        if s.count == 6 {
            r = CGFloat((v >> 16) & 0xFF) / 255
            g = CGFloat((v >>  8) & 0xFF) / 255
            b = CGFloat( v        & 0xFF) / 255
            a = 1
        } else {
            r = CGFloat((v >> 24) & 0xFF) / 255
            g = CGFloat((v >> 16) & 0xFF) / 255
            b = CGFloat((v >>  8) & 0xFF) / 255
            a = CGFloat( v        & 0xFF) / 255
        }
        self.init(red: r, green: g, blue: b, alpha: a)
    }

    // Синонимы для совместимости
    var hex6: String { String(hexRGBA.prefix(6)) }
    var hexString: String { "#"+hex6 }
    convenience init?(hex6: String) { self.init(hexAny: hex6) }
}
