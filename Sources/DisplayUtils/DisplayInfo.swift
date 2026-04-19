/*
 * Copyright 2026 Hiroki Kawakami
 */

import Foundation
import CoreGraphics
internal import DisplayUtilsBridge

public struct DisplayError: Error, CustomStringConvertible {
    let message: String
    public var description: String {
        return "DisplayError: \(self.message)"
    }
}

public struct DisplayInfo {

    public let id: CGDirectDisplayID
    public let name: String
    public let uuid: UUID
    public let serialNumber: UInt32
    public let ioLocation: String?

    public static var onlineDisplayCount: Int {
        var displayCount: UInt32 = 0;
        CGGetOnlineDisplayList(UInt32.max, nil, &displayCount);
        return Int(displayCount)
    }
    public static var onlineDisplays: [DisplayInfo] {
        var onlineDisplays = [CGDirectDisplayID](repeating: 0, count: self.onlineDisplayCount);
        var displayCount: UInt32 = 0;
        CGGetOnlineDisplayList(UInt32(onlineDisplays.count), &onlineDisplays, &displayCount);
        return onlineDisplays[0..<Int(displayCount)].compactMap({ id in DisplayInfo(id: id) })
    }

    public static var activeDisplayCount: Int {
        var displayCount: UInt32 = 0;
        CGGetActiveDisplayList(UInt32.max, nil, &displayCount);
        return Int(displayCount)
    }
    public static var activeDisplays: [DisplayInfo] {
        var activeDisplays = [CGDirectDisplayID](repeating: 0, count: self.activeDisplayCount);
        var displayCount: UInt32 = 0;
        CGGetActiveDisplayList(UInt32(onlineDisplays.count), &activeDisplays, &displayCount);
        return activeDisplays[0..<Int(displayCount)].compactMap({ id in DisplayInfo(id: id) })
    }

    public static func find(uuid: UUID) -> DisplayInfo? {
        for info in onlineDisplays {
            if info.uuid == uuid { return info }
        }
        return nil
    }
    public static func find(query: String) -> DisplayInfo? {
        for info in onlineDisplays {
            if info.uuid.uuidString == query { return info }
            if info.name == query { return info }
        }
        return nil
    }

    private init?(id: CGDirectDisplayID) {
        guard let info = CoreDisplay_DisplayCreateInfoDictionary(id)?.takeRetainedValue() as NSDictionary? else {
            return nil
        }
        self.id = id

        let size = CGDisplayScreenSize(id)
        let diagonal = round(sqrt((size.width * size.width) + (size.height * size.height)) / 25.4)
        if let nameDict = info["DisplayProductName"] as? NSDictionary, let name = nameDict["en_US"] as? String {
            self.name = name
        } else {
            self.name = CGDisplayIsBuiltin(id) != 0 ? "Built-in Display" : "\(Int(diagonal)) inch External Display"
        }

        guard let uuidString = info["kCGDisplayUUID"] as? String, let uuid = UUID(uuidString: uuidString) else {
            return nil
        }
        self.uuid = uuid

        self.serialNumber = CGDisplaySerialNumber(id)
        self.ioLocation = info["IODisplayLocation"] as? String
    }

    var isActive: Bool { CGDisplayIsActive(self.id) != 0 }
    var isInMirrorSet: Bool { CGDisplayIsInMirrorSet(self.id) != 0 }
}
