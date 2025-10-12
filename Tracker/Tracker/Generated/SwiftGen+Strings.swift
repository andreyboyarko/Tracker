// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return prefer_self_in_static_references

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
  /// Добавить категорию
  internal static let addCategory = L10n.tr("Localizable", "addCategory", fallback: "Добавить категорию")
  /// Нужно выбрать категорию
  internal static let alertChooseCategory = L10n.tr("Localizable", "alertChooseCategory", fallback: "Нужно выбрать категорию")
  /// Выберите цвет
  internal static let alertChooseColor = L10n.tr("Localizable", "alertChooseColor", fallback: "Выберите цвет")
  /// Выберите emoji
  internal static let alertChooseEmoji = L10n.tr("Localizable", "alertChooseEmoji", fallback: "Выберите emoji")
  /// Нужно выбрать хотя бы один день недели
  internal static let alertChooseWeekday = L10n.tr("Localizable", "alertChooseWeekday", fallback: "Нужно выбрать хотя бы один день недели")
  /// Заполните название
  internal static let alertEnterTrackerName = L10n.tr("Localizable", "alertEnterTrackerName", fallback: "Заполните название")
  /// Среднее количество трекеров в день
  internal static let average = L10n.tr("Localizable", "average", fallback: "Среднее количество трекеров в день")
  /// Лучший день
  internal static let bestDay = L10n.tr("Localizable", "bestDay", fallback: "Лучший день")
  /// Отменить
  internal static let cancel = L10n.tr("Localizable", "cancel", fallback: "Отменить")
  /// Категория
  internal static let category = L10n.tr("Localizable", "category", fallback: "Категория")
  /// Цвет
  internal static let color = L10n.tr("Localizable", "color", fallback: "Цвет")
  /// Создание трекера
  internal static let createTracker = L10n.tr("Localizable", "createTracker", fallback: "Создание трекера")
  /// %d дней
  internal static func daysCount(_ p1: Int) -> String {
    return L10n.tr("Localizable", "daysCount", p1, fallback: "%d дней")
  }
  /// Удалить
  internal static let delete = L10n.tr("Localizable", "delete", fallback: "Удалить")
  /// Уверены что хотите удалить трекер?
  internal static let deleteActionSheetMessage = L10n.tr("Localizable", "deleteActionSheetMessage", fallback: "Уверены что хотите удалить трекер?")
  /// Редактировать
  internal static let edit = L10n.tr("Localizable", "edit", fallback: "Редактировать")
  /// Привычки и события можно объединить по смыслу
  internal static let emptyCategoriesLabel = L10n.tr("Localizable", "emptyCategoriesLabel", fallback: "Привычки и события можно объединить по смыслу")
  /// Анализировать пока нечего
  internal static let emptyStatistics = L10n.tr("Localizable", "emptyStatistics", fallback: "Анализировать пока нечего")
  /// Что будем отслеживать?
  internal static let emptyTrackerLabel = L10n.tr("Localizable", "emptyTrackerLabel", fallback: "Что будем отслеживать?")
  /// Введите название категории
  internal static let enterCategoryName = L10n.tr("Localizable", "enterCategoryName", fallback: "Введите название категории")
  /// Введите название трекера
  internal static let enterTrackerName = L10n.tr("Localizable", "enterTrackerName", fallback: "Введите название трекера")
  /// Ошибка при инициализации NSFetchedResultsController: %@
  internal static func errorNSFetchedResultsController(_ p1: Any) -> String {
    return L10n.tr("Localizable", "errorNSFetchedResultsController", String(describing: p1), fallback: "Ошибка при инициализации NSFetchedResultsController: %@")
  }
  /// Ошибка при загрузке хранилища: %@
  internal static func errorPersistentStore(_ p1: Any) -> String {
    return L10n.tr("Localizable", "errorPersistentStore", String(describing: p1), fallback: "Ошибка при загрузке хранилища: %@")
  }
  /// Ограничение 38 символов
  internal static let errorTrackerName = L10n.tr("Localizable", "errorTrackerName", fallback: "Ограничение 38 символов")
  /// Каждый день
  internal static let everyday = L10n.tr("Localizable", "everyday", fallback: "Каждый день")
  /// Все трекеры
  internal static let filterAll = L10n.tr("Localizable", "filterAll", fallback: "Все трекеры")
  /// Завершенные
  internal static let filterCompleted = L10n.tr("Localizable", "filterCompleted", fallback: "Завершенные")
  /// Трекеры на сегодня
  internal static let filterForToday = L10n.tr("Localizable", "filterForToday", fallback: "Трекеры на сегодня")
  /// Фильтры
  internal static let filters = L10n.tr("Localizable", "filters", fallback: "Фильтры")
  /// Не завершенные
  internal static let filterUncompleted = L10n.tr("Localizable", "filterUncompleted", fallback: "Не завершенные")
  /// Привычка
  internal static let habit = L10n.tr("Localizable", "habit", fallback: "Привычка")
  /// Нерегулярное событие
  internal static let irregularHabit = L10n.tr("Localizable", "irregularHabit", fallback: "Нерегулярное событие")
  /// Новая категория
  internal static let newCategory = L10n.tr("Localizable", "newCategory", fallback: "Новая категория")
  /// Новая привычка
  internal static let newTracker = L10n.tr("Localizable", "newTracker", fallback: "Новая привычка")
  /// Окей
  internal static let okay = L10n.tr("Localizable", "okay", fallback: "Окей")
  /// Вот это технологии!
  internal static let onboardingButton = L10n.tr("Localizable", "onboardingButton", fallback: "Вот это технологии!")
  /// Отслеживайте только то, что хотите
  internal static let onboardingTitle1 = L10n.tr("Localizable", "onboardingTitle1", fallback: "Отслеживайте только то, что хотите")
  /// Даже если это не литры воды и йога
  internal static let onboardingTitle2 = L10n.tr("Localizable", "onboardingTitle2", fallback: "Даже если это не литры воды и йога")
  /// Готово
  internal static let ready = L10n.tr("Localizable", "ready", fallback: "Готово")
  /// Сохранить
  internal static let save = L10n.tr("Localizable", "save", fallback: "Сохранить")
  /// Расписание
  internal static let schedule = L10n.tr("Localizable", "schedule", fallback: "Расписание")
  /// Поиск
  internal static let search = L10n.tr("Localizable", "search", fallback: "Поиск")
  /// Статистика
  internal static let statistics = L10n.tr("Localizable", "statistics", fallback: "Статистика")
  /// Общее количество дней активности
  internal static let totalActiveDays = L10n.tr("Localizable", "totalActiveDays", fallback: "Общее количество дней активности")
  /// Трекеров завершено
  internal static let totalCompleted = L10n.tr("Localizable", "totalCompleted", fallback: "Трекеров завершено")
  /// Трекеры
  internal static let trackers = L10n.tr("Localizable", "trackers", fallback: "Трекеры")
  /// Пятница
  internal static let weekdayFriday = L10n.tr("Localizable", "weekdayFriday", fallback: "Пятница")
  /// Понедельник
  internal static let weekdayMonday = L10n.tr("Localizable", "weekdayMonday", fallback: "Понедельник")
  /// Суббота
  internal static let weekdaySaturday = L10n.tr("Localizable", "weekdaySaturday", fallback: "Суббота")
  /// Воскресенье
  internal static let weekdaySunday = L10n.tr("Localizable", "weekdaySunday", fallback: "Воскресенье")
  /// Четверг
  internal static let weekdayThursday = L10n.tr("Localizable", "weekdayThursday", fallback: "Четверг")
  /// Вторник
  internal static let weekdayTuesday = L10n.tr("Localizable", "weekdayTuesday", fallback: "Вторник")
  /// Среда
  internal static let weekdayWednesday = L10n.tr("Localizable", "weekdayWednesday", fallback: "Среда")
}
// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
  private static func tr(_ table: String, _ key: String, _ args: CVarArg..., fallback value: String) -> String {
    let format = BundleToken.bundle.localizedString(forKey: key, value: value, table: table)
    return String(format: format, locale: Locale.current, arguments: args)
  }
}

// swiftlint:disable convenience_type
private final class BundleToken {
  static let bundle: Bundle = {
    #if SWIFT_PACKAGE
    return Bundle.module
    #else
    return Bundle(for: BundleToken.self)
    #endif
  }()
}
// swiftlint:enable convenience_type
