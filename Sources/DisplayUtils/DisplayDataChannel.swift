/*
 * Copyright 2026 Hiroki Kawakami
 */

import Foundation
import IOKit
internal import DisplayUtilsBridge

private func IOString(_ proc: (UnsafeMutablePointer<CChar>) -> Void) -> String {
    var buf = [CChar](repeating: 0, count: MemoryLayout<io_string_t>.size)
    proc(&buf)
    return String(cString: &buf)
}

public class DisplayDataChannel {

    private let avService: IOAVService
    var readDelayMs: Int = 40
    var writeDelayMs: Int = 50
    var i2cChipAddress: UInt32 = 0x37

    public init?(for ioLocation: String) {
        let ioRootEntry = IORegistryGetRootEntry(kIOMasterPortDefault)
        var ioIterator = io_iterator_t()
        defer {
            IOObjectRelease(ioRootEntry)
            IOObjectRelease(ioIterator)
        }
        guard IORegistryEntryCreateIterator(ioRootEntry, kIOServicePlane, IOOptionBits(kIORegistryIterateRecursively), &ioIterator) == KERN_SUCCESS else {
            print("IORegistryEntryCreateIterator failed!")
            return nil
        }

        // Seek to service entry
        while true {
            let service = IOIteratorNext(ioIterator)
            if service == MACH_PORT_NULL { return nil }

            let path = IOString({ buf in IORegistryEntryGetPath(service, kIOServicePlane, buf) })
            if path == ioLocation {
                self.i2cChipAddress = DisplayDataChannel.detectI2CChipAddress(service: service)
                break
            }
        }

        // Find AVService Proxy
        while true {
            let service = IOIteratorNext(ioIterator)
            if service == MACH_PORT_NULL { break }

            let name = IOString({ buf in IORegistryEntryGetName(service, buf)})
            if name == "DCPAVServiceProxy" {
                let avService = IOAVServiceCreateWithService(kCFAllocatorDefault, service)?.takeRetainedValue()
                let location = IORegistryEntrySearchCFProperty(service, kIOServicePlane, "Location" as CFString, kCFAllocatorDefault, IOOptionBits(kIORegistryIterateRecursively)) as! String?
                if let avService = avService, location == "External" {
                    self.avService = avService
                    return
                }
            }
        }
        return nil
    }

    static func detectI2CChipAddress(service: io_object_t) -> UInt32 {
        return 0x37 // Default I2C chip address
    }

    struct Packet {
        var addr: UInt8
        var data: [UInt8]

        func length(offset: Int) -> Int {
            return Int(data[offset]) & ~0x80
        }

        init(addr: UInt8, data: [UInt8], addChecksum: Bool = false) {
            self.addr = addr
            self.data = [UInt8(data.count) | 0x80] + data
            if addChecksum { self.addChecksum() }
        }

        mutating func addChecksum() {
            var checksum = 0x6e ^ self.addr
            for i: Int in 0..<data.count { checksum ^= data[i] }
            data.append(checksum)
        }
    }

    public struct IOError: Error, CustomStringConvertible {
        let message: String
        let rawValue: IOReturn
        public var description: String {
            let errStr = String(cString: mach_error_string(self.rawValue))
            return "IOError: \(self.message), \(errStr) (\(self.rawValue))"
        }
    }

    func i2cRead(addr: UInt8, size: Int, waitMs: Int = 10) async throws -> Packet {
        var packet = Packet(addr: addr, data: [UInt8](repeating: 0, count: size))
        try await Task.sleep(nanoseconds: UInt64(waitMs) * 1000 * 1000)
        let err = IOAVServiceReadI2C(avService, i2cChipAddress, UInt32(addr), &packet.data, UInt32(packet.data.count))
        if err != 0 { throw IOError(message: "I2C Read Failed", rawValue: err) }
        return packet
    }
    func i2cWrite(packet: Packet, waitMs: Int = 10, retry: Int = 2) async throws {
        var err: IOReturn = 0
        for _ in 0..<retry {
            try await Task.sleep(nanoseconds: UInt64(waitMs) * 1000 * 1000)
            err = packet.data.withUnsafeBytes { ptr in
                IOAVServiceWriteI2C(avService, i2cChipAddress, UInt32(packet.addr), ptr.baseAddress, UInt32(ptr.count))
            }
            if err == 0 { return }
        }
        if err != 0 { throw IOError(message: "I2C Write Failed", rawValue: err) }
    }

    public func getRawCapabilities() async throws -> String {
        var buffer: [UInt8] = [];
        while buffer.count < 512 {
            try await i2cWrite(packet: Packet(addr: 0x51, data: [0xf3, UInt8(buffer.count >> 8), UInt8(buffer.count & 0xff)], addChecksum: true))
            let packet = try await i2cRead(addr: 0x51, size: 38);
            let length = packet.length(offset: 1) - 3
            if length == 0 { break }
            buffer += packet.data[5..<(5 + length)]
        }
        return String(decoding: buffer, as: UTF8.self)
    }

    public func getVcp(code: UInt8) async throws -> VCPResponse {
        try await i2cWrite(packet: Packet(addr: 0x51, data: [0x01, code], addChecksum: true))
        let readPacket = try await i2cRead(addr: 0x51, size: 12)
        return try VCPResponse(data: readPacket.data)
    }
    public func getVcp(feature: VCPFeature) async throws -> VCPResponse {
        return try await getVcp(code: feature.code)
    }
    public func setVcp(code: UInt8, value: UInt16) async throws {
        try await i2cWrite(packet: Packet(addr: 0x51, data: [0x03, code, UInt8(value >> 8), UInt8(value & 0xff)], addChecksum: true))
    }
    public func setVcp(feature: VCPFeature, value: UInt16) async throws {
        try await setVcp(code: feature.code, value: value)
    }
}
