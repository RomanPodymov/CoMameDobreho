// swiftlint:disable all
// Generated using SwiftGen — https://github.com/SwiftGen/SwiftGen

import Foundation

// swiftlint:disable superfluous_disable_command file_length implicit_return

// MARK: - Strings

// swiftlint:disable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:disable nesting type_body_length type_name vertical_whitespace_opening_braces
internal enum L10n {
    internal enum OfferScreen {
        /// Save
        internal static let buttonSave = L10n.tr("Localizable", "offer_screen.button_save")
        /// Enter text here
        internal static let textPlaceholder = L10n.tr("Localizable", "offer_screen.text_placeholder")
        internal enum DeviceInformation {
            /// Name
            internal static let name = L10n.tr("Localizable", "offer_screen.device_information.name")
            /// Device information
            internal static let title = L10n.tr("Localizable", "offer_screen.device_information.title")
        }

        internal enum Dishes {
            /// First dish
            internal static let firstDish = L10n.tr("Localizable", "offer_screen.dishes.first_dish")
            /// Second dish
            internal static let secondDish = L10n.tr("Localizable", "offer_screen.dishes.second_dish")
            /// Soup
            internal static let soup = L10n.tr("Localizable", "offer_screen.dishes.soup")
            /// Third dish
            internal static let thirdDish = L10n.tr("Localizable", "offer_screen.dishes.third_dish")
            /// Offer for today
            internal static let title = L10n.tr("Localizable", "offer_screen.dishes.title")
        }

        internal enum Error {
            /// Please fill all the fields
            internal static let message = L10n.tr("Localizable", "offer_screen.error.message")
            /// Error
            internal static let title = L10n.tr("Localizable", "offer_screen.error.title")
        }
    }
}

// swiftlint:enable explicit_type_interface function_parameter_count identifier_name line_length
// swiftlint:enable nesting type_body_length type_name vertical_whitespace_opening_braces

// MARK: - Implementation Details

extension L10n {
    private static func tr(_ table: String, _ key: String, _ args: CVarArg...) -> String {
        let format = BundleToken.bundle.localizedString(forKey: key, value: nil, table: table)
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
