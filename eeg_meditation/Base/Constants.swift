//
//  Constants.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 30.06.2022.
//  Copyright © 2022 Alex Lokk. All rights reserved.
//

struct Constants {
    enum ProfileType {
        case debug
        case stage
        case prod
    }
    #if DEBUG
    static let PROFILE: ProfileType = .debug
    static let SENTRY_DSN = "***"
    static let HOCKEY_APP_ID = "***"
    #else
    static let PROFILE: ProfileType = .prod
    static let SENTRY_DSN = "***"
    static let HOCKEY_APP_ID = "***"
    #endif
}
