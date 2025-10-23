//
//  AppIntent.swift
//  FocusTimerPlusComplication FocusTimerPlusComplication FocusTimerPlusComplication
//
//  Created by Irina Saf on 2025-10-22.
//

import WidgetKit
import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Configuration" }
    static var description: IntentDescription { "This is an example widget." }

    // An example configurable parameter.
    @Parameter(title: "Favorite Emoji", default: "😃")
    var favoriteEmoji: String
}
