/*
 * Copyright 2026 Hiroki Kawakami
 */

import DisplayUtils
import ArgumentParser

struct DisplayCommand: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "command",
        abstract: "Controls display settings over DDC/CI",
        subcommands: [
            Capabilities.self,
        ]
    )

    struct Capabilities: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Query monitor capabilities string",
        )
        @OptionGroup var display: DisplaySelectorOption

        mutating func run() async throws {
            let info = try display.ddc()
            let capabilities = try await info.getRawCapabilities()
            print(capabilities)
        }
    }
}
