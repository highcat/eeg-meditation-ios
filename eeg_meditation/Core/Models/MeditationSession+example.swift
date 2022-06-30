//
//  MeditationSession+example.swift
//  eeg_meditation
//
//  Created by Alex Lokk on 28.04.2020.
//  Copyright © 2020 Alex Lokk. All rights reserved.
//


extension MeditationSession {
    static func createExample() -> MeditationSession {
        let session = MeditationSession(context: AppDelegate.viewContext)

        session.taps = [
            TapPoint(at: 16),
            TapPoint(at: 19),
            TapPoint(at: 25),
            TapPoint(at: 54),
            TapPoint(at: 57),
        ]
        session.levelChanges = [
            LevelChangePoint(at: 0, newLevel: 75)
        ]

        session.eSense = [
            ESensePoint(at: 0, poorSignal: 0, attention: 0, meditation: 0),
            ESensePoint(at: 1, poorSignal: 0, attention: 0, meditation: 0),
            ESensePoint(at: 2, poorSignal: 0, attention: 0, meditation: 0),
            ESensePoint(at: 3, poorSignal: 0, attention: 0, meditation: 20),
            ESensePoint(at: 4, poorSignal: 0, attention: 0, meditation: 43),
            ESensePoint(at: 5, poorSignal: 0, attention: 0, meditation: 45),
            ESensePoint(at: 6, poorSignal: 0, attention: 0, meditation: 40),
            ESensePoint(at: 7, poorSignal: 0, attention: 0, meditation: 30),
            ESensePoint(at: 8, poorSignal: 0, attention: 0, meditation: 80),
            ESensePoint(at: 9, poorSignal: 0, attention: 0, meditation: 85),
            ESensePoint(at: 10, poorSignal: 0, attention: 0, meditation: 85),
            ESensePoint(at: 11, poorSignal: 0, attention: 0, meditation: 84),
            ESensePoint(at: 12, poorSignal: 0, attention: 0, meditation: 53),
            ESensePoint(at: 13, poorSignal: 0, attention: 0, meditation: 60),
            ESensePoint(at: 14, poorSignal: 0, attention: 0, meditation: 48),
            ESensePoint(at: 15, poorSignal: 0, attention: 0, meditation: 40),
            ESensePoint(at: 16, poorSignal: 0, attention: 0, meditation: 33),
            ESensePoint(at: 17, poorSignal: 0, attention: 0, meditation: 20),
            ESensePoint(at: 18, poorSignal: 0, attention: 0, meditation: 5),
            ESensePoint(at: 19, poorSignal: 0, attention: 0, meditation: 8),
            ESensePoint(at: 20, poorSignal: 0, attention: 0, meditation: 10),
            ESensePoint(at: 21, poorSignal: 0, attention: 0, meditation: 34),
            ESensePoint(at: 22, poorSignal: 0, attention: 0, meditation: 33),
            ESensePoint(at: 23, poorSignal: 0, attention: 0, meditation: 21),
            ESensePoint(at: 24, poorSignal: 0, attention: 0, meditation: 28),
            ESensePoint(at: 25, poorSignal: 0, attention: 0, meditation: 35),
            ESensePoint(at: 26, poorSignal: 0, attention: 0, meditation: 41),
            ESensePoint(at: 27, poorSignal: 0, attention: 0, meditation: 42),
            ESensePoint(at: 28, poorSignal: 0, attention: 0, meditation: 54),
            ESensePoint(at: 29, poorSignal: 0, attention: 0, meditation: 73),
            ESensePoint(at: 30, poorSignal: 0, attention: 0, meditation: 84),
            ESensePoint(at: 31, poorSignal: 0, attention: 0, meditation: 83),
            ESensePoint(at: 32, poorSignal: 0, attention: 0, meditation: 82),
            ESensePoint(at: 33, poorSignal: 0, attention: 0, meditation: 89),
            ESensePoint(at: 34, poorSignal: 0, attention: 0, meditation: 92),
            ESensePoint(at: 35, poorSignal: 0, attention: 0, meditation: 95),
            ESensePoint(at: 36, poorSignal: 0, attention: 0, meditation: 100),
            ESensePoint(at: 37, poorSignal: 0, attention: 0, meditation: 100),
            ESensePoint(at: 38, poorSignal: 0, attention: 0, meditation: 100),
            ESensePoint(at: 39, poorSignal: 0, attention: 0, meditation: 100),
            ESensePoint(at: 40, poorSignal: 0, attention: 0, meditation: 100),
            ESensePoint(at: 41, poorSignal: 0, attention: 0, meditation: 100),
            ESensePoint(at: 42, poorSignal: 0, attention: 0, meditation: 100),
            ESensePoint(at: 43, poorSignal: 0, attention: 0, meditation: 100),
            ESensePoint(at: 44, poorSignal: 0, attention: 0, meditation: 95),
            ESensePoint(at: 45, poorSignal: 0, attention: 0, meditation: 100),
            ESensePoint(at: 46, poorSignal: 0, attention: 0, meditation: 100),
            ESensePoint(at: 47, poorSignal: 0, attention: 0, meditation: 100),
            ESensePoint(at: 48, poorSignal: 0, attention: 0, meditation: 98),
            ESensePoint(at: 49, poorSignal: 0, attention: 0, meditation: 100),
            ESensePoint(at: 50, poorSignal: 0, attention: 0, meditation: 100),
            ESensePoint(at: 51, poorSignal: 0, attention: 0, meditation: 99),
            ESensePoint(at: 52, poorSignal: 0, attention: 0, meditation: 97),
            ESensePoint(at: 53, poorSignal: 0, attention: 0, meditation: 100),
            ESensePoint(at: 54, poorSignal: 0, attention: 0, meditation: 87),
            ESensePoint(at: 55, poorSignal: 0, attention: 0, meditation: 80),
            ESensePoint(at: 56, poorSignal: 0, attention: 0, meditation: 65),
            ESensePoint(at: 57, poorSignal: 0, attention: 0, meditation: 43),
            ESensePoint(at: 58, poorSignal: 0, attention: 0, meditation: 11),
            ESensePoint(at: 59, poorSignal: 0, attention: 0, meditation: 0),
            ESensePoint(at: 60, poorSignal: 0, attention: 0, meditation: 0),
        ]

        session.startTime = Date() - TimeInterval(session.eSense.count)
        session.endTime = Date()

        return session
    }
}
