/*
 * Copyright 2026 Hiroki Kawakami
 */

import DisplayUtils
import ArgumentParser

struct CommandLineError: Error, CustomStringConvertible {
    let message: String
    var description: String {
        return message
    }
}

struct DisplaySelectorOption: ParsableArguments {
    @Option(name: [.customShort("d"), .customLong("display")],  help: "Chooses which display to control")
    var display: String?

    func info() throws -> DisplayInfo {
        let displays = DisplayInfo.onlineDisplays
        for display in displays {
            if display.uuid.uuidString == self.display {
                return display
            }
        }
        for display in displays {
            if display.name == self.display {
                return display
            }
        }
        if let index = Int(self.display ?? "0") {
            if index >= displays.count {
                throw CommandLineError(message: "Display index (\(index)) is out of range (0-\(displays.count - 1)).")
            }
            return displays[index]
        }
        throw CommandLineError(message: "Display \"\(self.display ?? "")\" not found.")
    }

    func ddc() throws -> DisplayDataChannel {
        let info = try self.info()
        guard let ioLocation = info.ioLocation else {
            throw CommandLineError(message: "Cannot access IORegistry for \"\(info.name)\"")
        }
        guard let ddc = DisplayDataChannel(for: ioLocation) else {
            throw CommandLineError(message: "Cannot find DDC/CI Service for \"\(info.name)\"")
        }
        return ddc
    }
}

@main
struct display_utils: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "display-utils",
        abstract: "Manage Display Settings",
        subcommands: [
            List.self,
            DisplayCommand.self,
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
