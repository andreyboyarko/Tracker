//
//
//import UIKit
//
//final class NewTrackerEmojiColorPickerViewController: UIViewController {
//
//    // Public API
//    var onPickEmoji: ((String) -> Void)?
//    var onPickColor: ((UIColor) -> Void)?
//
//    // MARK: - Data
//    // Ровно 18 штук → 3 ряда × 6 колонок
//    private let emojis: [String] = [
//        "😊","😺","🌸","🐶","❤️","😱",
//        "😇","😡","🧊","🤔","🙏","🍔",
//        "🥦","🏓","🥇","🎸","🏝","😴"
//    ]
//
//    private let colors: [UIColor] = [
//        UIColor(named: "ybColor1")!,
//        UIColor(named: "ybColor2")!,
//        UIColor(named: "ybColor3")!,
//        UIColor(named: "ybColor4")!,
//        UIColor(named: "ybColor5")!,
//        UIColor(named: "ybColor6")!,
//        UIColor(named: "ybColor7")!,
//        UIColor(named: "ybColor8")!,
//        UIColor(named: "ybColor9")!,
//        UIColor(named: "ybColor10")!,
//        UIColor(named: "ybColor11")!,
//        UIColor(named: "ybColor12")!,
//        UIColor(named: "ybColor13")!,
//        UIColor(named: "ybColor14")!,
//        UIColor(named: "ybColor15")!,
//        UIColor(named: "ybColor16")!,
//        UIColor(named: "ybColor17")!,
//        UIColor(named: "ybColor18")!
//    ]
//
//    // MARK: - UI
//    private let collectionView: UICollectionView
//    private enum Section: Int, CaseIterable { case emoji, colors }
//
//    // selection
//    private var selectedEmoji: IndexPath?
//    private var selectedColor: IndexPath?
//
//    // MARK: - Init
//    init() {
//        let layout = UICollectionViewFlowLayout()
//        layout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
//        layout.minimumInteritemSpacing = 12
//        layout.minimumLineSpacing = 12
//        self.collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
//        super.init(nibName: nil, bundle: nil)
//    }
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//
//    // MARK: - LifeCycle
//    override func viewDidLoad() {
//        super.viewDidLoad()
//
//        view.backgroundColor = UIColor(named: "ybBlack") ?? .systemBackground
//
//        collectionView.backgroundColor = .clear
//        collectionView.alwaysBounceVertical = true
//        collectionView.translatesAutoresizingMaskIntoConstraints = false
//        collectionView.dataSource = self
//        collectionView.delegate   = self
//
//        collectionView.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.reuseId)
//        collectionView.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.reuseId)
//        collectionView.register(TitleHeader.self,
//                                forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
//                                withReuseIdentifier: TitleHeader.reuseId)
//
//        view.addSubview(collectionView)
//        NSLayoutConstraint.activate([
//            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
//            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
//            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
//            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16)
//        ])
//    }
//}
//
//// MARK: - DataSource
//extension NewTrackerEmojiColorPickerViewController: UICollectionViewDataSource {
//    func numberOfSections(in collectionView: UICollectionView) -> Int { Section.allCases.count }
//
//    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        switch Section(rawValue: section)! {
//        case .emoji:  return emojis.count        // 18
//        case .colors: return colors.count        // 18
//        }
//    }
//
//    func collectionView(_ cv: UICollectionView,
//                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        switch Section(rawValue: indexPath.section)! {
//        case .emoji:
//            let cell = cv.dequeueReusableCell(withReuseIdentifier: EmojiCell.reuseId, for: indexPath) as! EmojiCell
//            cell.configure(emojis[indexPath.item], selected: indexPath == selectedEmoji)
//            return cell
//        case .colors:
//            let cell = cv.dequeueReusableCell(withReuseIdentifier: ColorCell.reuseId, for: indexPath) as! ColorCell
//            cell.configure(color: colors[indexPath.item], selected: indexPath == selectedColor)
//            return cell
//        }
//    }
//
//    func collectionView(_ cv: UICollectionView,
//                        viewForSupplementaryElementOfKind kind: String,
//                        at indexPath: IndexPath) -> UICollectionReusableView {
//        let header = cv.dequeueReusableSupplementaryView(ofKind: kind,
//                                                         withReuseIdentifier: TitleHeader.reuseId,
//                                                         for: indexPath) as! TitleHeader
//        header.titleLabel.text = (Section(rawValue: indexPath.section) == .emoji) ? "Emoji" : "Цвет"
//        return header
//    }
//}
//
//// MARK: - Delegate & Layout
//extension NewTrackerEmojiColorPickerViewController: UICollectionViewDelegateFlowLayout {
//
//    // размеры ячеек — точные по макету
//    func collectionView(_ cv: UICollectionView,
//                        layout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize {
//        switch Section(rawValue: indexPath.section)! {
//        case .emoji:  return CGSize(width: 46, height: 46)
//        case .colors: return CGSize(width: 40, height: 40)
//        }
//    }
//
//    func collectionView(_ cv: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        referenceSizeForHeaderInSection section: Int) -> CGSize {
//        return CGSize(width: cv.bounds.width, height: 28) // компактный заголовок
//    }
//
//    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        switch Section(rawValue: indexPath.section)! {
//        case .emoji:
//            let old = selectedEmoji
//            selectedEmoji = indexPath
//            if let old { collectionView.reloadItems(at: [old]) }
//            collectionView.reloadItems(at: [indexPath])
//            onPickEmoji?(emojis[indexPath.item])
//
//        case .colors:
//            let old = selectedColor
//            selectedColor = indexPath
//            if let old { collectionView.reloadItems(at: [old]) }
//            collectionView.reloadItems(at: [indexPath])
//            onPickColor?(colors[indexPath.item])
//        }
//    }
//}
//
//// MARK: - Cells & Header
//
//private final class EmojiCell: UICollectionViewCell {
//    static let reuseId = "EmojiCell"
//    private let bg = UIView()
//    private let label = UILabel()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//
//        bg.layer.cornerRadius = 8
//        bg.translatesAutoresizingMaskIntoConstraints = false
//
//        label.font = .systemFont(ofSize: 28)
//        label.textAlignment = .center
//        label.translatesAutoresizingMaskIntoConstraints = false
//
//        contentView.addSubview(bg)
//        bg.addSubview(label)
//
//        NSLayoutConstraint.activate([
//            bg.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            bg.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            bg.topAnchor.constraint(equalTo: contentView.topAnchor),
//            bg.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
//
//            label.centerXAnchor.constraint(equalTo: bg.centerXAnchor),
//            label.centerYAnchor.constraint(equalTo: bg.centerYAnchor)
//        ])
//    }
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//
//    func configure(_ emoji: String, selected: Bool) {
//        label.text = emoji
//        // выбранное состояние — «серый фон 30%»
//        bg.backgroundColor = selected ? UIColor.black.withAlphaComponent(0.12) : .clear
//    }
//}
//
//private final class ColorCell: UICollectionViewCell {
//    static let reuseId = "ColorCell"
//    private let swatch = UIView()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        swatch.layer.cornerRadius = 8
//        swatch.translatesAutoresizingMaskIntoConstraints = false
//        contentView.addSubview(swatch)
//        NSLayoutConstraint.activate([
//            swatch.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
//            swatch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
//            swatch.topAnchor.constraint(equalTo: contentView.topAnchor),
//            swatch.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
//        ])
//    }
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//
//    func configure(color: UIColor, selected: Bool) {
//        swatch.backgroundColor = color
//        swatch.layer.borderWidth = selected ? 2 : 0
//        swatch.layer.borderColor = selected ? UIColor(named: "ybGray")?.cgColor ?? UIColor.systemGray.cgColor : UIColor.clear.cgColor
//    }
//}
//
//private final class TitleHeader: UICollectionReusableView {
//    static let reuseId = "TitleHeader"
//    let titleLabel = UILabel()
//
//    override init(frame: CGRect) {
//        super.init(frame: frame)
//        titleLabel.font = .systemFont(ofSize: 19, weight: .bold) // YP/Bold/19 по фигме
//        titleLabel.textColor = UIColor(named: "color") ?? .label
//        titleLabel.translatesAutoresizingMaskIntoConstraints = false
//        addSubview(titleLabel)
//        NSLayoutConstraint.activate([
//            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
//            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: trailingAnchor, constant: -16),
//            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
//        ])
//    }
//    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
//}
