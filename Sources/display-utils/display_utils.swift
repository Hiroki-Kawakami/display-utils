/*
 * Copyright 2026 Hiroki Kawakami
 */

import DisplayUtils
import ArgumentParser

@main
struct display_utils: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "display-utils",
        abstract: "Manage Display Settings",
        subcommands: [
            List.self,
        ]
    )

    struct List: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Lists displays."
        )

        mutating func run() async throws {
            for (i, display) in DisplayInfo.onlineDisplays.enumerated() {
                print("[\(i)] \(display.name) (\(display.uuid))")
            }
        }
    }
}
