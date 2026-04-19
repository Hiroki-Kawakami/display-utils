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
            GetVcp.self,
            SetVcp.self,
        ]
    )

    struct Capabilities: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            abstract: "Query monitor capabilities string",
        )
        @OptionGroup var display: DisplaySelectorOption

        mutating func run() async throws {
            let ddc = try display.ddc()
            let capabilities = try await ddc.getRawCapabilities()
            print(capabilities)
        }
    }

    struct VcpFeatureArgument: ExpressibleByArgument {
        let code: UInt8
        init?(argument: String) {
            if let f = VCPFeature.find(string: argument) {
                code = f.code
            } else if let hex = argument.hasPrefix("0x") ? argument.dropFirst(2) : argument.hasPrefix("x") ? argument.dropFirst(1) : nil {
                guard let v = UInt8(hex, radix: 16) else { return nil }
                code = v
            } else {
                guard let v = UInt8(argument) else { return nil }
                code = v
            }
        }
    }

    struct HexOrDecUInt16: ExpressibleByArgument {
        let value: UInt16
        init?(argument: String) {
            let hex = argument.hasPrefix("0x") ? argument.dropFirst(2) : argument.hasPrefix("x")  ? argument.dropFirst(1) : nil
            if let hex {
                guard let v = UInt16(hex, radix: 16) else { return nil }
                value = v
            } else {
                guard let v = UInt16(argument) else { return nil }
                value = v
            }
        }
    }

    struct GetVcp: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "getvcp",
            abstract: "Get VCP feature value.",
        )
        @OptionGroup var display: DisplaySelectorOption
        @Argument(help: "Feature code or name") var feature: VcpFeatureArgument

        mutating func run() async throws {
            let ddc = try display.ddc()
            let response = try await ddc.getVcp(code: feature.code)
            print("\(response.current)")
        }
    }

    struct SetVcp: AsyncParsableCommand {
        static let configuration = CommandConfiguration(
            commandName: "setvcp",
            abstract: "Set VCP feature value.",
        )
        @OptionGroup var display: DisplaySelectorOption
        @Argument(help: "Feature code or name") var feature: VcpFeatureArgument
        @Argument(help: "New VCP value") var value: HexOrDecUInt16

        mutating func run() async throws {
            let ddc = try display.ddc()
            try await ddc.setVcp(code: feature.code, value: value.value)
        }
    }
}
