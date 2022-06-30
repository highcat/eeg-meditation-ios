//
//  SettingsCareTaker.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 23.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//

import Foundation


/*
 "caretaker" from Memento pattern
 */
class SettingsCareTaker {
    static let shared = SettingsCareTaker()
    private init() {}

    let encoder = JSONEncoder()
    let decoder = JSONDecoder()
    let userDefaults = UserDefaults.standard

    func save() {
        let settings = SettingsModel.shared
        do {
            let data = try encoder.encode(settings)
            userDefaults.set(data, forKey: "appConfig")
            print("settings saved")
            SettingsModel.relay.accept(settings)
        } catch {
            // FIXME send error to Sentry
            assert(false, "can't save settings")
        }
    }

    enum Error: Swift.Error {
        case notFound
        case loadError
    }

    /*
     This should be used with try/catch,
     in case
     */
    func load() throws -> SettingsModel {
        let settings = SettingsModel.shared  // defaults loaded
        guard let data = userDefaults.data(forKey: "appConfig") else {
            // return settings created by default
            throw Error.notFound
        }

        let vModel = try decoder.decode(VersionOnlySettingsModel.self, from: data) // should always work
        switch vModel.version {
        case .v0_0:
            // Try to retrieve part of settings
            let model = try decoder.decode(old_v0_0_SettingsModel.self, from: data) // should always, as version fixed
            // merge settings to a new model
            settings.meditationLevel = model.thresholdMeditationLevel
            return settings
        // *** Current version ***
        case .v1_0:
            assert(SettingsModel.shared.version == .v1_0)
            SettingsModel.shared = try decoder.decode(SettingsModel.self, from: data)
            return SettingsModel.shared
        }
    }
}
