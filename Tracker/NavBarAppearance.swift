

import UIKit

extension UIViewController {
    
    func applyNavBarStyle(prefersLargeTitle: Bool) {
        let bar = navigationController?.navigationBar
        bar?.prefersLargeTitles = prefersLargeTitle
        navigationItem.largeTitleDisplayMode = prefersLargeTitle ? .always : .never

        let ap = UINavigationBarAppearance()
        ap.configureWithOpaqueBackground()
        ap.backgroundColor = UIColor(named: "background") ?? .systemBackground
        ap.shadowColor = .clear

        ap.titleTextAttributes = [
            .foregroundColor: UIColor(named: "color") ?? .label,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]

        if prefersLargeTitle {
            ap.largeTitleTextAttributes = [
                .foregroundColor: UIColor(named: "color") ?? .label,
                .font: UIFont.systemFont(ofSize: 34, weight: .bold)
            ]
        }

        bar?.standardAppearance = ap
        bar?.scrollEdgeAppearance = ap
        bar?.compactAppearance = ap
        bar?.tintColor = UIColor(named: "color") ?? .label
        bar?.isTranslucent = false
    }
}

