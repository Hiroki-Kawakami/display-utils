import StaticMemberIterable

public struct VCPValueEntry: Sendable {
    let value: UInt8
    let description: String
}

public enum VCPValueKind: UInt8, Sendable {
    case continuous = 0x00
    case table = 0x01
    case momentary = 0x02
    case unknown = 0xff
}

@StaticMemberIterable
public struct VCPFeature: Sendable {
    public let id: String
    public let aliases: [String]?
    public let code: UInt8
    public let name: String
    public let description: String
    public let kind: VCPValueKind
    public let slValues: [VCPValueEntry]?

    init(id: String, aliases: [String]? = nil, code: UInt8, name: String, description: String, kind: VCPValueKind, slValues: [VCPValueEntry]? = nil) {
        self.id = id
        self.aliases = aliases
        self.code = code
        self.name = name
        self.description = description
        self.kind = kind
        self.slValues = slValues
    }

    public static func find(string: String) -> VCPFeature? {
        for attr in allStaticMembers {
            if attr.id == string { return attr }
            if let aliases = attr.aliases {
                for alias in aliases {
                    if alias == string { return attr }
                }
            }
        }
        return nil
    }

    // MARK: Misc
    public static let degauss = VCPFeature(
        id: "degauss",
        code: 0x01,
        name: "Degauss",
        description: "Causes a CRT to perform a degauss cycle",
        kind: .momentary,
    )
    public static let newControlValue = VCPFeature(
        id: "new-control-value",
        code: 0x02,
        name: "New Control Value",
        description: "Indicates that a display user control has been changed",
        kind: .table,
        slValues: [
            .init(value: 0x01, description: "No new control values"),
            .init(value: 0x02, description: "One or more new control values have been saved"),
            .init(value: 0xff, description: "No user controls are present"),
        ]
    )
    public static let softControls = VCPFeature(
        id: "soft-controls",
        code: 0x03,
        name: "Soft Controls",
        description: "Allows display controls to be used as soft keys",
        kind: .table,
        slValues: [
            .init(value: 0x00, description: "No button active"),
            .init(value: 0x01, description: "Button 1 active"),
            .init(value: 0x02, description: "Button 2 active"),
            .init(value: 0x03, description: "Button 3 active"),
            .init(value: 0x04, description: "Button 4 active"),
            .init(value: 0x05, description: "Button 5 active"),
            .init(value: 0x06, description: "Button 6 active"),
            .init(value: 0x07, description: "Button 7 active"),
            .init(value: 0xff, description: "No user controls"),
        ]
    )
    public static let restoreFactoryDefaults = VCPFeature(
        id: "restore-factory-defaults",
        code: 0x04,
        name: "Restore Factory Defaults",
        description: "Restore all factory presets including brightness/contrast, geometry, color, and TV defaults",
        kind: .momentary,
    )
    public static let restoreFactoryBrightnessContrastDefaults = VCPFeature(
        id: "restore-factory-brightness-contrast-defaults",
        code: 0x05,
        name: "Restore Factory Brightness/Contrast Defaults",
        description: "Restore factory defaults for brightness and contrast",
        kind: .momentary,
    )
    public static let restoreFactoryGeometryDefaults = VCPFeature(
        id: "restore-factory-geometry-defaults",
        code: 0x06,
        name: "Restore Factory Geometry Defaults",
        description: "Restore factory defaults for geometry adjustments",
        kind: .momentary,
    )
    public static let restoreColorDefaults = VCPFeature(
        id: "restore-color-defaults",
        code: 0x08,
        name: "Restore Color Defaults",
        description: "Restore factory defaults for color settings",
        kind: .momentary,
    )
    public static let restoreFactoryTVDefaults = VCPFeature(
        id: "restore-factory-tv-defaults",
        code: 0x0a,
        name: "Restore Factory TV Defaults",
        description: "Restore factory defaults for TV functions",
        kind: .momentary,
    )
    public static let colorTemperatureIncrement = VCPFeature(
        id: "color-temperature-increment",
        code: 0x0b,
        name: "Color Temperature Increment",
        description: "Minimum increment in which the display can adjust color temperature",
        kind: .continuous,
    )
    public static let colorTemperatureRequest = VCPFeature(
        id: "color-temperature-request",
        code: 0x0c,
        name: "Color Temperature Request",
        description: "Specifies a color temperature in degrees Kelvin",
        kind: .continuous,
    )
    public static let activeControl = VCPFeature(
        id: "active-control",
        code: 0x52,
        name: "Active Control",
        description: "Read id of one feature that has changed, 0x00 indicates no more",
        kind: .continuous,
    )
    public static let screenOrientation = VCPFeature(
        id: "screen-orientation",
        code: 0xaa,
        name: "Screen Orientation",
        description: "Indicates current screen orientation",
        kind: .table,
        slValues: [
            .init(value: 0x01, description: "0 degrees"),
            .init(value: 0x02, description: "90 degrees"),
            .init(value: 0x03, description: "180 degrees"),
            .init(value: 0x04, description: "270 degrees"),
            .init(value: 0xff, description: "Cannot supply orientation"),
        ]
    )
    public static let settings = VCPFeature(
        id: "settings",
        code: 0xb0,
        name: "Settings",
        description: "Store/restore the user saved values for the current mode",
        kind: .table,
        slValues: [
            .init(value: 0x01, description: "Store current settings"),
            .init(value: 0x02, description: "Restore factory defaults"),
        ]
    )
    public static let flatPanelSubPixelLayout = VCPFeature(
        id: "flat-panel-sub-pixel-layout",
        code: 0xb2,
        name: "Flat Panel Sub-Pixel Layout",
        description: "LCD sub-pixel structure",
        kind: .table,
        slValues: [
            .init(value: 0x00, description: "Not defined"),
            .init(value: 0x01, description: "Red/Green/Blue vertical stripe"),
            .init(value: 0x02, description: "Red/Green/Blue horizontal stripe"),
            .init(value: 0x03, description: "Blue/Green/Red vertical stripe"),
            .init(value: 0x04, description: "Blue/Green/Red horizontal stripe"),
            .init(value: 0x05, description: "Quad pixel, red at top left"),
            .init(value: 0x06, description: "Quad pixel, red at bottom left"),
            .init(value: 0x07, description: "Delta (triangular) pixel arrangement"),
            .init(value: 0x08, description: "Mosaic with interleaved sub-pixels"),
        ]
    )
    public static let displayTechnologyType = VCPFeature(
        id: "display-technology-type",
        code: 0xb6,
        name: "Display Technology Type",
        description: "Indicates the base technology type",
        kind: .table,
        slValues: [
            .init(value: 0x01, description: "CRT (shadow mask)"),
            .init(value: 0x02, description: "CRT (aperture grill)"),
            .init(value: 0x03, description: "LCD (active matrix)"),
            .init(value: 0x04, description: "LCos"),
            .init(value: 0x05, description: "Plasma"),
            .init(value: 0x06, description: "OLED"),
            .init(value: 0x07, description: "EL"),
            .init(value: 0x08, description: "MEM (dynamic interference)"),
            .init(value: 0x09, description: "MEM (interferometric modulator)"),
        ]
    )
    public static let displayUsageTime = VCPFeature(
        id: "display-usage-time",
        code: 0xc0,
        name: "Display Usage Time",
        description: "Active power on time in hours",
        kind: .continuous,
    )
    public static let displayDescriptorLength = VCPFeature(
        id: "display-descriptor-length",
        code: 0xc2,
        name: "Display Descriptor Length",
        description: "Length in bytes of non-volatile storage available for descriptors",
        kind: .continuous,
    )
    public static let transmitDisplayDescriptor = VCPFeature(
        id: "transmit-display-descriptor",
        code: 0xc3,
        name: "Transmit Display Descriptor",
        description: "Reads/writes a display descriptor from/to non-volatile storage",
        kind: .table,
    )
    public static let applicationEnableKey = VCPFeature(
        id: "application-enable-key",
        code: 0xc6,
        name: "Application Enable Key",
        description: "A 2 byte value used to allow an application to only operate with known products",
        kind: .continuous,
    )
    public static let displayControllerType = VCPFeature(
        id: "display-controller-type",
        code: 0xc8,
        name: "Display Controller Type",
        description: "Manufacturer id of controller and 2 byte manufacturer-specific controller type",
        kind: .table,
        slValues: [
            .init(value: 0x01, description: "Conexant"),
            .init(value: 0x02, description: "Genesis"),
            .init(value: 0x03, description: "Macronix"),
            .init(value: 0x04, description: "IDT"),
            .init(value: 0x05, description: "Mstar"),
            .init(value: 0x06, description: "Myson"),
            .init(value: 0x07, description: "Phillips"),
            .init(value: 0x08, description: "PixelWorks"),
            .init(value: 0x09, description: "RealTek"),
            .init(value: 0x0a, description: "Sage"),
            .init(value: 0x0b, description: "Silicon Image"),
            .init(value: 0x0c, description: "SmartASIC"),
            .init(value: 0x0d, description: "STMicroelectronics"),
            .init(value: 0x0e, description: "Topro"),
            .init(value: 0x0f, description: "Trumpion"),
            .init(value: 0x10, description: "Welltrend"),
            .init(value: 0x11, description: "Samsung"),
            .init(value: 0x12, description: "Novatek"),
            .init(value: 0x13, description: "STK"),
            .init(value: 0x14, description: "Silicon Optics"),
            .init(value: 0x15, description: "Texas Instruments"),
            .init(value: 0x16, description: "Analogix"),
            .init(value: 0x17, description: "Quantum Data"),
            .init(value: 0x18, description: "NXP"),
            .init(value: 0x19, description: "Chrontel"),
            .init(value: 0x1a, description: "Parade"),
            .init(value: 0x1b, description: "THine"),
            .init(value: 0x1c, description: "Trident"),
            .init(value: 0x1d, description: "Micros"),
            .init(value: 0xff, description: "Not defined"),
        ]
    )
    public static let displayFirmwareLevel = VCPFeature(
        id: "display-firmware-level",
        code: 0xc9,
        name: "Display Firmware Level",
        description: "2 byte firmware level",
        kind: .continuous,
    )
    public static let osdButtonControl = VCPFeature(
        id: "osd-button-control",
        code: 0xca,
        name: "OSD/Button Control",
        description: "Indicates whether On Screen Display is enabled",
        kind: .table,
        slValues: [
            .init(value: 0x00, description: "Host control of OSD not supported"),
            .init(value: 0x01, description: "OSD disabled, buttons disabled"),
            .init(value: 0x02, description: "OSD enabled, buttons enabled"),
            .init(value: 0xff, description: "Cannot supply"),
        ]
    )
    public static let osdLanguage = VCPFeature(
        id: "osd-language",
        code: 0xcc,
        name: "OSD Language",
        description: "On Screen Display language",
        kind: .table,
        slValues: [
            .init(value: 0x00, description: "Reserved"),
            .init(value: 0x01, description: "Chinese (traditional)"),
            .init(value: 0x02, description: "English"),
            .init(value: 0x03, description: "French"),
            .init(value: 0x04, description: "German"),
            .init(value: 0x05, description: "Italian"),
            .init(value: 0x06, description: "Japanese"),
            .init(value: 0x07, description: "Korean"),
            .init(value: 0x08, description: "Portuguese (Portugal)"),
            .init(value: 0x09, description: "Russian"),
            .init(value: 0x0a, description: "Spanish"),
            .init(value: 0x0b, description: "Swedish"),
            .init(value: 0x0c, description: "Turkish"),
            .init(value: 0x0d, description: "Chinese (simplified)"),
            .init(value: 0x0e, description: "Portuguese (Brazil)"),
            .init(value: 0x0f, description: "Arabic"),
            .init(value: 0x10, description: "Bulgarian"),
            .init(value: 0x11, description: "Croatian"),
            .init(value: 0x12, description: "Czech"),
            .init(value: 0x13, description: "Danish"),
            .init(value: 0x14, description: "Dutch"),
            .init(value: 0x15, description: "Estonian"),
            .init(value: 0x16, description: "Finnish"),
            .init(value: 0x17, description: "Greek"),
            .init(value: 0x18, description: "Hebrew"),
            .init(value: 0x19, description: "Hindi"),
            .init(value: 0x1a, description: "Hungarian"),
            .init(value: 0x1b, description: "Latvian"),
            .init(value: 0x1c, description: "Lithuanian"),
            .init(value: 0x1d, description: "Norwegian"),
            .init(value: 0x1e, description: "Polish"),
            .init(value: 0x1f, description: "Romanian"),
            .init(value: 0x20, description: "Serbian"),
            .init(value: 0x21, description: "Slovak"),
            .init(value: 0x22, description: "Slovenian"),
            .init(value: 0x23, description: "Thai"),
            .init(value: 0x24, description: "Ukrainian"),
            .init(value: 0x25, description: "Vietnamese"),
        ]
    )
    public static let scratchPad = VCPFeature(
        id: "scratch-pad",
        code: 0xde,
        name: "Scratch Pad",
        description: "Operation mode (v2.0) or scratch pad (v3.0/v2.2)",
        kind: .unknown,
    )
    public static let vcpVersion = VCPFeature(
        id: "vcp-version",
        code: 0xdf,
        name: "VCP Version",
        description: "MCCS version",
        kind: .continuous,
    )

    // MARK: Image Adjustments
    public static let clockFrequency = VCPFeature(
        id: "clock-frequency",
        code: 0x0e,
        name: "Clock",
        description: "Increase/decrease the sampling clock frequency",
        kind: .continuous,
    )
    public static let brightness = VCPFeature(
        id: "brightness",
        code: 0x10,
        name: "Brightness",
        description: "Increase/decrease the brightness of the image",
        kind: .continuous,
    )
    public static let fleshToneEnhancement = VCPFeature(
        id: "flesh-tone-enhancement",
        code: 0x11,
        name: "Flesh Tone Enhancement",
        description: "Select contrast enhancement algorithm respecting flesh tone region",
        kind: .continuous,
    )
    public static let contrast = VCPFeature(
        id: "contrast",
        code: 0x12,
        name: "Contrast",
        description: "Increase/decrease the contrast of the image",
        kind: .continuous,
    )
    public static let backlightControl = VCPFeature(
        id: "backlight-control",
        code: 0x13,
        name: "Backlight Control",
        description: "Increase/decrease the specified backlight control value",
        kind: .continuous,
    )
    public static let autoSetup = VCPFeature(
        id: "auto-setup",
        code: 0x1e,
        name: "Auto Setup",
        description: "Perform autosetup function (H/V position, clock, clock phase)",
        kind: .table,
        slValues: [
            .init(value: 0x00, description: "Auto setup not active"),
            .init(value: 0x01, description: "Performing auto setup"),
            .init(value: 0x02, description: "Enable continuous/periodic auto setup"),
        ]
    )
    public static let autoColorSetup = VCPFeature(
        id: "auto-color-setup",
        code: 0x1f,
        name: "Auto Color Setup",
        description: "Perform color autosetup function (R/G/B gain and offset)",
        kind: .table,
        slValues: [
            .init(value: 0x00, description: "Auto color setup not active"),
            .init(value: 0x01, description: "Performing auto color setup"),
            .init(value: 0x02, description: "Enable continuous/periodic auto color setup"),
        ]
    )
    public static let clockPhase = VCPFeature(
        id: "clock-phase",
        code: 0x3e,
        name: "Clock Phase",
        description: "Increase/decrease the sampling clock phase shift",
        kind: .continuous,
    )
    public static let horizontalMoire = VCPFeature(
        id: "horizontal-moire",
        code: 0x56,
        name: "Horizontal Moire",
        description: "Increase/decrease horizontal moire cancellation",
        kind: .continuous,
    )
    public static let verticalMoire = VCPFeature(
        id: "vertical-moire",
        code: 0x58,
        name: "Vertical Moire",
        description: "Increase/decrease vertical moire cancellation",
        kind: .continuous,
    )
    public static let grayscaleExpansion = VCPFeature(
        id: "grayscale-expansion",
        code: 0x2e,
        name: "Gray Scale Expansion",
        description: "Gray scale expansion",
        kind: .continuous,
    )
    public static let horizontalMirror = VCPFeature(
        id: "horizontal-mirror",
        code: 0x82,
        name: "Horizontal Mirror (Flip)",
        description: "Flip picture horizontally",
        kind: .table,
        slValues: [
            .init(value: 0x00, description: "Normal mode"),
            .init(value: 0x01, description: "Mirrored horizontally"),
        ]
    )
    public static let verticalMirror = VCPFeature(
        id: "vertical-mirror",
        code: 0x84,
        name: "Vertical Mirror (Flip)",
        description: "Flip picture vertically",
        kind: .table,
        slValues: [
            .init(value: 0x00, description: "Normal mode"),
            .init(value: 0x01, description: "Mirrored vertically"),
        ]
    )
    public static let displayScaling = VCPFeature(
        id: "display-scaling",
        code: 0x86,
        name: "Display Scaling",
        description: "Control the scaling (input vs output) of the display",
        kind: .table,
        slValues: [
            .init(value: 0x01, description: "No scaling"),
            .init(value: 0x02, description: "Scale to maximum while maintaining aspect ratio"),
            .init(value: 0x03, description: "Scale to maximum"),
            .init(value: 0x04, description: "1/2 full display area"),
            .init(value: 0x05, description: "2/3 full display area"),
            .init(value: 0x06, description: "3/4 full display area"),
            .init(value: 0x07, description: "Display area using linear expansion"),
            .init(value: 0x08, description: "Display area using non-linear expansion"),
            .init(value: 0x09, description: "Display area using bilinear expansion"),
            .init(value: 0x0a, description: "Display area using motion adaptive expansion"),
        ]
    )
    public static let sharpness = VCPFeature(
        id: "sharpness",
        code: 0x87,
        name: "Sharpness",
        description: "Selects one of a range of filter functions to sharpen the image",
        kind: .continuous,
    )
    public static let velocityScanModulation = VCPFeature(
        id: "velocity-scan-modulation",
        code: 0x88,
        name: "Velocity Scan Modulation",
        description: "Increase/decrease the velocity modulation of the horizontal scanning",
        kind: .continuous,
    )
    public static let scanMode = VCPFeature(
        id: "scan-mode",
        code: 0xda,
        name: "Scan Mode",
        description: "Controls scan characteristics",
        kind: .table,
        slValues: [
            .init(value: 0x00, description: "Normal"),
            .init(value: 0x01, description: "Underscan"),
            .init(value: 0x02, description: "Overscan"),
            .init(value: 0x03, description: "Widescreen"),
        ]
    )
    public static let imageMode = VCPFeature(
        id: "image-mode",
        code: 0xdb,
        name: "Image Mode",
        description: "Controls aspects of the displayed image for TV applications",
        kind: .table,
        slValues: [
            .init(value: 0x00, description: "No effect"),
            .init(value: 0x01, description: "Full"),
            .init(value: 0x02, description: "Zoom"),
            .init(value: 0x03, description: "Squeeze"),
            .init(value: 0x04, description: "Variable"),
        ]
    )
    public static let displayApplication = VCPFeature(
        id: "display-application",
        code: 0xdc,
        name: "Display Application",
        description: "Type of application used on display",
        kind: .table,
        slValues: [
            .init(value: 0x00, description: "Default"),
            .init(value: 0x01, description: "Productivity"),
            .init(value: 0x02, description: "Mixed"),
            .init(value: 0x03, description: "Movie"),
            .init(value: 0x04, description: "User defined"),
            .init(value: 0x05, description: "Games"),
            .init(value: 0x06, description: "Sports"),
            .init(value: 0x07, description: "Professional (all signal processing disabled)"),
            .init(value: 0x08, description: "Standard/Default mode"),
            .init(value: 0x09, description: "Demonstration"),
            .init(value: 0x0a, description: "Dynamic contrast"),
        ]
    )

    // MARK: Color
    public static let colorPreset = VCPFeature(
        id: "color-preset",
        code: 0x14,
        name: "Select Color Preset",
        description: "Select a specified color temperature",
        kind: .table,
        slValues: [
            .init(value: 0x01, description: "sRGB"),
            .init(value: 0x02, description: "Display native"),
            .init(value: 0x03, description: "4000 K"),
            .init(value: 0x04, description: "5000 K"),
            .init(value: 0x05, description: "6500 K"),
            .init(value: 0x06, description: "7500 K"),
            .init(value: 0x07, description: "8200 K"),
            .init(value: 0x08, description: "9300 K"),
            .init(value: 0x09, description: "10000 K"),
            .init(value: 0x0a, description: "11500 K"),
            .init(value: 0x0b, description: "User 1"),
            .init(value: 0x0c, description: "User 2"),
            .init(value: 0x0d, description: "User 3"),
        ]
    )
    public static let videoGainRed = VCPFeature(
        id: "video-gain-red",
        code: 0x16,
        name: "Video Gain: Red",
        description: "Increase/decrease the luminescence of red pixels",
        kind: .continuous,
    )
    public static let userColorVisionCompensation = VCPFeature(
        id: "user-color-vision-compensation",
        code: 0x17,
        name: "User Color Vision Compensation",
        description: "Increase/decrease the degree of compensation",
        kind: .continuous,
    )
    public static let videoGainGreen = VCPFeature(
        id: "video-gain-green",
        code: 0x18,
        name: "Video Gain: Green",
        description: "Increase/decrease the luminescence of green pixels",
        kind: .continuous,
    )
    public static let videoGainBlue = VCPFeature(
        id: "video-gain-blue",
        code: 0x1a,
        name: "Video Gain: Blue",
        description: "Increase/decrease the luminescence of blue pixels",
        kind: .continuous,
    )
    public static let sixAxisSaturationRed = VCPFeature(
        id: "six-axis-saturation-red",
        code: 0x59,
        name: "6 Axis Saturation: Red",
        description: "Value < 127 decreases red saturation, 127 is nominal, > 127 increases saturation",
        kind: .continuous,
    )
    public static let sixAxisSaturationYellow = VCPFeature(
        id: "six-axis-saturation-yellow",
        code: 0x5a,
        name: "6 Axis Saturation: Yellow",
        description: "Value < 127 decreases yellow saturation, 127 is nominal, > 127 increases saturation",
        kind: .continuous,
    )
    public static let sixAxisSaturationGreen = VCPFeature(
        id: "six-axis-saturation-green",
        code: 0x5b,
        name: "6 Axis Saturation: Green",
        description: "Value < 127 decreases green saturation, 127 is nominal, > 127 increases saturation",
        kind: .continuous,
    )
    public static let sixAxisSaturationCyan = VCPFeature(
        id: "six-axis-saturation-cyan",
        code: 0x5c,
        name: "6 Axis Saturation: Cyan",
        description: "Value < 127 decreases cyan saturation, 127 is nominal, > 127 increases saturation",
        kind: .continuous,
    )
    public static let sixAxisSaturationBlue = VCPFeature(
        id: "six-axis-saturation-blue",
        code: 0x5d,
        name: "6 Axis Saturation: Blue",
        description: "Value < 127 decreases blue saturation, 127 is nominal, > 127 increases saturation",
        kind: .continuous,
    )
    public static let sixAxisSaturationMagenta = VCPFeature(
        id: "six-axis-saturation-magenta",
        code: 0x5e,
        name: "6 Axis Saturation: Magenta",
        description: "Value < 127 decreases magenta saturation, 127 is nominal, > 127 increases saturation",
        kind: .continuous,
    )
    public static let videoBlackLevelRed = VCPFeature(
        id: "video-black-level-red",
        code: 0x6c,
        name: "Video Black Level: Red",
        description: "Increase/decrease the black level of red pixels",
        kind: .continuous,
    )
    public static let videoBlackLevelGreen = VCPFeature(
        id: "video-black-level-green",
        code: 0x6e,
        name: "Video Black Level: Green",
        description: "Increase/decrease the black level of green pixels",
        kind: .continuous,
    )
    public static let videoBlackLevelBlue = VCPFeature(
        id: "video-black-level-blue",
        code: 0x70,
        name: "Video Black Level: Blue",
        description: "Increase/decrease the black level of blue pixels",
        kind: .continuous,
    )
    public static let gamma = VCPFeature(
        id: "gamma",
        code: 0x72,
        name: "Gamma",
        description: "Select relative or absolute gamma",
        kind: .continuous,
    )
    public static let colorSaturation = VCPFeature(
        id: "color-saturation",
        code: 0x8a,
        name: "Color Saturation",
        description: "Increase/decrease the amplitude of the color difference components",
        kind: .continuous,
    )
    public static let hue = VCPFeature(
        id: "hue",
        code: 0x90,
        name: "Hue",
        description: "Increase/decrease the wavelength of the color component of the video signal",
        kind: .continuous,
    )
    public static let sixAxisHueRed = VCPFeature(
        id: "six-axis-hue-red",
        code: 0x9b,
        name: "6 Axis Hue Control: Red",
        description: "Value < 127 shifts toward magenta, 127 no effect, > 127 shifts toward red",
        kind: .continuous,
    )
    public static let sixAxisHueYellow = VCPFeature(
        id: "six-axis-hue-yellow",
        code: 0x9c,
        name: "6 Axis Hue Control: Yellow",
        description: "Value < 127 shifts toward green, 127 no effect, > 127 shifts toward yellow",
        kind: .continuous,
    )
    public static let sixAxisHueGreen = VCPFeature(
        id: "six-axis-hue-green",
        code: 0x9d,
        name: "6 Axis Hue Control: Green",
        description: "Value < 127 shifts toward yellow, 127 no effect, > 127 shifts toward green",
        kind: .continuous,
    )
    public static let sixAxisHueCyan = VCPFeature(
        id: "six-axis-hue-cyan",
        code: 0x9e,
        name: "6 Axis Hue Control: Cyan",
        description: "Value < 127 shifts toward green, 127 no effect, > 127 shifts toward cyan",
        kind: .continuous,
    )
    public static let sixAxisHueBlue = VCPFeature(
        id: "six-axis-hue-blue",
        code: 0x9f,
        name: "6 Axis Hue Control: Blue",
        description: "Value < 127 shifts toward cyan, 127 no effect, > 127 shifts toward blue",
        kind: .continuous,
    )
    public static let sixAxisHueMagenta = VCPFeature(
        id: "six-axis-hue-magenta",
        code: 0xa0,
        name: "6 Axis Hue Control: Magenta",
        description: "Value < 127 shifts toward blue, 127 no effect, > 127 shifts toward magenta",
        kind: .continuous,
    )

    // MARK: Backlight
    public static let backlightLevelWhite = VCPFeature(
        id: "backlight-level-white",
        code: 0x6b,
        name: "Backlight Level: White",
        description: "Increase/decrease the white backlight level",
        kind: .continuous,
    )
    public static let backlightLevelRed = VCPFeature(
        id: "backlight-level-red",
        code: 0x6d,
        name: "Backlight Level: Red",
        description: "Increase/decrease the red backlight level",
        kind: .continuous,
    )
    public static let backlightLevelGreen = VCPFeature(
        id: "backlight-level-green",
        code: 0x6f,
        name: "Backlight Level: Green",
        description: "Increase/decrease the green backlight level",
        kind: .continuous,
    )
    public static let backlightLevelBlue = VCPFeature(
        id: "backlight-level-blue",
        code: 0x71,
        name: "Backlight Level: Blue",
        description: "Increase/decrease the blue backlight level",
        kind: .continuous,
    )
    public static let ambientLightSensor = VCPFeature(
        id: "ambient-light-sensor",
        code: 0x66,
        name: "Ambient Light Sensor",
        description: "Enable/disable ambient light sensor",
        kind: .table,
        slValues: [
            .init(value: 0x01, description: "Disabled"),
            .init(value: 0x02, description: "Enabled"),
        ]
    )

    // MARK: Geometry
    public static let focus = VCPFeature(
        id: "focus",
        code: 0x1c,
        name: "Focus",
        description: "Increase/decrease the focus of the image",
        kind: .continuous,
    )
    public static let horizontalPosition = VCPFeature(
        id: "horizontal-position",
        code: 0x20,
        name: "Horizontal Position (Phase)",
        description: "Increasing (decreasing) this value moves the image toward the right (left)",
        kind: .continuous,
    )
    public static let horizontalSize = VCPFeature(
        id: "horizontal-size",
        code: 0x22,
        name: "Horizontal Size",
        description: "Increase/decrease the width of the image",
        kind: .continuous,
    )
    public static let horizontalPincushion = VCPFeature(
        id: "horizontal-pincushion",
        code: 0x24,
        name: "Horizontal Pincushion",
        description: "Increasing (decreasing) this value causes the right and left sides of the image to move outward (inward)",
        kind: .continuous,
    )
    public static let horizontalPincushionBalance = VCPFeature(
        id: "horizontal-pincushion-balance",
        code: 0x26,
        name: "Horizontal Pincushion Balance",
        description: "Increasing (decreasing) this value moves the center section of the image toward the right (left)",
        kind: .continuous,
    )
    public static let horizontalConvergenceRB = VCPFeature(
        id: "horizontal-convergence-rb",
        code: 0x28,
        name: "Horizontal Convergence R/B",
        description: "Increasing (decreasing) this value shifts the red pixels to the right (left)",
        kind: .continuous,
    )
    public static let horizontalConvergenceMG = VCPFeature(
        id: "horizontal-convergence-mg",
        code: 0x29,
        name: "Horizontal Convergence M/G",
        description: "Increasing (decreasing) this value shifts the magenta pixels to the right (left)",
        kind: .continuous,
    )
    public static let verticalPosition = VCPFeature(
        id: "vertical-position",
        code: 0x30,
        name: "Vertical Position (Phase)",
        description: "Increasing (decreasing) this value moves the image toward the bottom (top)",
        kind: .continuous,
    )
    public static let verticalSize = VCPFeature(
        id: "vertical-size",
        code: 0x32,
        name: "Vertical Size",
        description: "Increase/decrease the height of the image",
        kind: .continuous,
    )
    public static let verticalPincushion = VCPFeature(
        id: "vertical-pincushion",
        code: 0x34,
        name: "Vertical Pincushion",
        description: "Increasing (decreasing) this value causes the top and bottom of the image to move outward (inward)",
        kind: .continuous,
    )
    public static let verticalPincushionBalance = VCPFeature(
        id: "vertical-pincushion-balance",
        code: 0x36,
        name: "Vertical Pincushion Balance",
        description: "Increasing (decreasing) this value moves the center section of the image toward the bottom (top)",
        kind: .continuous,
    )
    public static let verticalConvergenceRB = VCPFeature(
        id: "vertical-convergence-rb",
        code: 0x38,
        name: "Vertical Convergence R/B",
        description: "Increasing (decreasing) this value shifts the red pixels up (down)",
        kind: .continuous,
    )
    public static let verticalConvergenceMG = VCPFeature(
        id: "vertical-convergence-mg",
        code: 0x39,
        name: "Vertical Convergence M/G",
        description: "Increasing (decreasing) this value shifts the magenta pixels up (down)",
        kind: .continuous,
    )
    public static let verticalLinearity = VCPFeature(
        id: "vertical-linearity",
        code: 0x3a,
        name: "Vertical Linearity",
        description: "Increase/decrease the density of scan lines in the image center",
        kind: .continuous,
    )
    public static let verticalLinearityBalance = VCPFeature(
        id: "vertical-linearity-balance",
        code: 0x3c,
        name: "Vertical Linearity Balance",
        description: "Increase/decrease the density of scan lines in the image center",
        kind: .continuous,
    )
    public static let horizontalParallelogram = VCPFeature(
        id: "horizontal-parallelogram",
        code: 0x40,
        name: "Horizontal Parallelogram",
        description: "Increasing (decreasing) this value shifts the top section of the image toward the right (left)",
        kind: .continuous,
    )
    public static let verticalParallelogram = VCPFeature(
        id: "vertical-parallelogram",
        code: 0x41,
        name: "Vertical Parallelogram",
        description: "Increasing (decreasing) this value shifts the top section of the image toward the left (right)",
        kind: .continuous,
    )
    public static let horizontalKeystone = VCPFeature(
        id: "horizontal-keystone",
        code: 0x42,
        name: "Horizontal Keystone",
        description: "Increasing (decreasing) this value increases (decreases) the length of the right side of the image relative to the left",
        kind: .continuous,
    )
    public static let verticalKeystone = VCPFeature(
        id: "vertical-keystone",
        code: 0x43,
        name: "Vertical Keystone",
        description: "Increasing (decreasing) this value increases (decreases) the height of the bottom of the image relative to the top",
        kind: .continuous,
    )
    public static let rotation = VCPFeature(
        id: "rotation",
        code: 0x44,
        name: "Rotation",
        description: "Increasing (decreasing) this value rotates the image (counter) clockwise",
        kind: .continuous,
    )
    public static let topCornerFlare = VCPFeature(
        id: "top-corner-flare",
        code: 0x46,
        name: "Top Corner Flare",
        description: "Increase/decrease the distance between the left and right sides of the image at the top",
        kind: .continuous,
    )
    public static let topCornerHook = VCPFeature(
        id: "top-corner-hook",
        code: 0x48,
        name: "Top Corner Hook",
        description: "Increasing (decreasing) this value moves the top of the image toward the right (left)",
        kind: .continuous,
    )
    public static let bottomCornerFlare = VCPFeature(
        id: "bottom-corner-flare",
        code: 0x4a,
        name: "Bottom Corner Flare",
        description: "Increase/decrease the distance between the left and right sides of the image at the bottom",
        kind: .continuous,
    )
    public static let bottomCornerHook = VCPFeature(
        id: "bottom-corner-hook",
        code: 0x4c,
        name: "Bottom Corner Hook",
        description: "Increasing (decreasing) this value moves the bottom end of the image toward the right (left)",
        kind: .continuous,
    )
    public static let trapezoid = VCPFeature(
        id: "trapezoid",
        code: 0x7e,
        name: "Trapezoid",
        description: "Increase/decrease the trapezoid distortion in the image",
        kind: .continuous,
    )
    public static let keystone = VCPFeature(
        id: "keystone",
        code: 0x80,
        name: "Keystone",
        description: "Increase/decrease the keystone distortion in the image",
        kind: .continuous,
    )
    public static let horizontalFrequency = VCPFeature(
        id: "horizontal-frequency",
        code: 0xac,
        name: "Horizontal Frequency",
        description: "Horizontal sync signal frequency as determined by the display",
        kind: .continuous,
    )
    public static let verticalFrequency = VCPFeature(
        id: "vertical-frequency",
        code: 0xae,
        name: "Vertical Frequency",
        description: "Vertical sync signal frequency as determined by the display",
        kind: .continuous,
    )

    // MARK: Projection
    public static let adjustFocalPlane = VCPFeature(
        id: "adjust-focal-plane",
        code: 0x7a,
        name: "Adjust Focal Plane",
        description: "Increase/decrease the distance to the focal plane of the image",
        kind: .continuous,
    )
    public static let adjustZoom = VCPFeature(
        id: "adjust-zoom",
        code: 0x7c,
        name: "Adjust Zoom",
        description: "Increase/decrease the distance to the zoom function of the projection lens",
        kind: .continuous,
    )

    // MARK: Input / Output
    public static let input = VCPFeature(
        id: "input-source",
        aliases: ["input"],
        code: 0x60,
        name: "Input Source",
        description: "Selects active video source",
        kind: .table,
        slValues: [
            .init(value: 0x01, description: "VGA-1"),
            .init(value: 0x02, description: "VGA-2"),
            .init(value: 0x03, description: "DVI-1"),
            .init(value: 0x04, description: "DVI-2"),
            .init(value: 0x05, description: "Composite video 1"),
            .init(value: 0x06, description: "Composite video 2"),
            .init(value: 0x07, description: "S-Video-1"),
            .init(value: 0x08, description: "S-Video-2"),
            .init(value: 0x09, description: "Tuner-1"),
            .init(value: 0x0a, description: "Tuner-2"),
            .init(value: 0x0b, description: "Tuner-3"),
            .init(value: 0x0c, description: "Component video (YPbPr/YCbCr) 1"),
            .init(value: 0x0d, description: "Component video (YPbPr/YCbCr) 2"),
            .init(value: 0x0e, description: "Component video (YPbPr/YCbCr) 3"),
            .init(value: 0x0f, description: "DisplayPort-1"),
            .init(value: 0x10, description: "DisplayPort-2"),
            .init(value: 0x11, description: "HDMI-1"),
            .init(value: 0x12, description: "HDMI-2"),
        ]
    )
    public static let outputSelect = VCPFeature(
        id: "output-select",
        aliases: ["output"],
        code: 0xd0,
        name: "Output Select",
        description: "Selects the active output",
        kind: .table,
        slValues: [
            .init(value: 0x01, description: "Analog video (R/G/B) 1"),
            .init(value: 0x02, description: "Analog video (R/G/B) 2"),
            .init(value: 0x03, description: "Digital video (TMDS) 1"),
            .init(value: 0x04, description: "Digital video (TMDS) 2"),
            .init(value: 0x05, description: "Composite video 1"),
            .init(value: 0x06, description: "Composite video 2"),
            .init(value: 0x07, description: "S-Video-1"),
            .init(value: 0x08, description: "S-Video-2"),
            .init(value: 0x09, description: "Tuner-1"),
            .init(value: 0x0a, description: "Tuner-2"),
            .init(value: 0x0b, description: "Tuner-3"),
            .init(value: 0x0c, description: "Component video (YPbPr/YCbCr) 1"),
            .init(value: 0x0d, description: "Component video (YPbPr/YCbCr) 2"),
            .init(value: 0x0e, description: "Component video (YPbPr/YCbCr) 3"),
            .init(value: 0x0f, description: "DisplayPort-1"),
            .init(value: 0x10, description: "DisplayPort-2"),
            .init(value: 0x11, description: "HDMI-1"),
            .init(value: 0x12, description: "HDMI-2"),
        ]
    )

    // MARK: Audio
    public static let audioSpeakerVolume = VCPFeature(
        id: "audio-speaker-volume",
        aliases: ["volume"],
        code: 0x62,
        name: "Audio Speaker Volume",
        description: "Adjusts speaker volume",
        kind: .continuous,
    )
    public static let speakerSelect = VCPFeature(
        id: "speaker-select",
        code: 0x63,
        name: "Speaker Select",
        description: "Selects a group of speakers",
        kind: .table,
        slValues: [
            .init(value: 0x00, description: "Front L/R"),
            .init(value: 0x01, description: "Side L/R"),
            .init(value: 0x02, description: "Rear L/R"),
            .init(value: 0x03, description: "Center/Subwoofer"),
        ]
    )
    public static let microphoneVolume = VCPFeature(
        id: "microphone-volume",
        code: 0x64,
        name: "Audio: Microphone Volume",
        description: "Increase/decrease microphone gain",
        kind: .continuous,
    )
    public static let audioMute = VCPFeature(
        id: "audio-mute",
        code: 0x8d,
        name: "Audio Mute / Screen Blank",
        description: "Mute/unmute audio, and screen blank",
        kind: .table,
        slValues: [
            .init(value: 0x01, description: "Mute the audio"),
            .init(value: 0x02, description: "Unmute the audio"),
        ]
    )
    public static let audioTreble = VCPFeature(
        id: "audio-treble",
        code: 0x8f,
        name: "Audio Treble",
        description: "Emphasize/de-emphasize high frequency audio",
        kind: .continuous,
    )
    public static let audioBass = VCPFeature(
        id: "audio-bass",
        code: 0x91,
        name: "Audio Bass",
        description: "Emphasize/de-emphasize low frequency audio",
        kind: .continuous,
    )
    public static let audioBalance = VCPFeature(
        id: "audio-balance",
        code: 0x93,
        name: "Audio Balance L/R",
        description: "Controls left/right audio balance",
        kind: .continuous,
    )
    public static let audioProcessorMode = VCPFeature(
        id: "audio-processor-mode",
        code: 0x94,
        name: "Audio Processor Mode",
        description: "Select audio mode",
        kind: .table,
        slValues: [
            .init(value: 0x00, description: "Speaker off/Audio not supported"),
            .init(value: 0x01, description: "Mono"),
            .init(value: 0x02, description: "Stereo"),
            .init(value: 0x03, description: "Stereo expanded"),
            .init(value: 0x11, description: "SRS 2.0"),
            .init(value: 0x12, description: "SRS 2.1"),
            .init(value: 0x13, description: "SRS 3.1"),
            .init(value: 0x14, description: "SRS 4.1"),
            .init(value: 0x15, description: "SRS 5.1"),
            .init(value: 0x16, description: "SRS 6.1"),
            .init(value: 0x17, description: "SRS 7.1"),
            .init(value: 0x21, description: "Dolby 2.0"),
            .init(value: 0x22, description: "Dolby 2.1"),
            .init(value: 0x23, description: "Dolby 3.1"),
            .init(value: 0x24, description: "Dolby 4.1"),
            .init(value: 0x25, description: "Dolby 5.1"),
            .init(value: 0x26, description: "Dolby 6.1"),
            .init(value: 0x27, description: "Dolby 7.1"),
            .init(value: 0x31, description: "THX 2.0"),
            .init(value: 0x32, description: "THX 2.1"),
            .init(value: 0x33, description: "THX 3.1"),
            .init(value: 0x34, description: "THX 4.1"),
            .init(value: 0x35, description: "THX 5.1"),
            .init(value: 0x36, description: "THX 6.1"),
            .init(value: 0x37, description: "THX 7.1"),
        ]
    )

    // MARK: TV
    public static let tvChannelUpDown = VCPFeature(
        id: "tv-channel-up-down",
        code: 0x8b,
        name: "TV Channel Up/Down",
        description: "Increment or decrement television channel",
        kind: .table,
        slValues: [
            .init(value: 0x01, description: "Increment channel"),
            .init(value: 0x02, description: "Decrement channel"),
        ]
    )
    public static let tvContrast = VCPFeature(
        id: "tv-contrast",
        code: 0x8e,
        name: "TV Contrast",
        description: "Increase/decrease the ratio between blacks and whites in the image",
        kind: .continuous,
    )
    public static let tvBlackLevel = VCPFeature(
        id: "tv-black-level",
        code: 0x92,
        name: "TV Black Level / Luminescence",
        description: "Increase/decrease the black level of the video",
        kind: .continuous,
    )

    // MARK: Window
    public static let windowPositionTLX = VCPFeature(
        id: "window-position-tlx",
        code: 0x95,
        name: "Window Position (TL_X)",
        description: "Top left X pixel of an area of the image",
        kind: .continuous,
    )
    public static let windowPositionTLY = VCPFeature(
        id: "window-position-tly",
        code: 0x96,
        name: "Window Position (TL_Y)",
        description: "Top left Y pixel of an area of the image",
        kind: .continuous,
    )
    public static let windowPositionBRX = VCPFeature(
        id: "window-position-brx",
        code: 0x97,
        name: "Window Position (BR_X)",
        description: "Bottom right X pixel of an area of the image",
        kind: .continuous,
    )
    public static let windowPositionBRY = VCPFeature(
        id: "window-position-bry",
        code: 0x98,
        name: "Window Position (BR_Y)",
        description: "Bottom right Y pixel of an area of the image",
        kind: .continuous,
    )
    public static let windowControl = VCPFeature(
        id: "window-control",
        code: 0x99,
        name: "Window Control On/Off",
        description: "Enables the brightness and color within a window to be different from the rest of the image",
        kind: .table,
        slValues: [
            .init(value: 0x00, description: "No effect"),
            .init(value: 0x01, description: "Off"),
            .init(value: 0x02, description: "On"),
        ]
    )
    public static let windowBackground = VCPFeature(
        id: "window-background",
        code: 0x9a,
        name: "Window Background",
        description: "Changes the contrast ratio between the area of the window and the rest of the image",
        kind: .continuous,
    )
    public static let autoSetupOnOff = VCPFeature(
        id: "auto-setup-on-off",
        code: 0xa2,
        name: "Auto Setup On/Off",
        description: "Turn on/off an auto setup function",
        kind: .table,
        slValues: [
            .init(value: 0x01, description: "Off"),
            .init(value: 0x02, description: "On"),
        ]
    )
    public static let changeSelectedWindow = VCPFeature(
        id: "change-selected-window",
        code: 0xa5,
        name: "Change the Selected Window",
        description: "Change selected window (as defined by 0x95..0x98)",
        kind: .table,
        slValues: [
            .init(value: 0x00, description: "Full display image"),
            .init(value: 0x01, description: "Window 1"),
            .init(value: 0x02, description: "Window 2"),
            .init(value: 0x03, description: "Window 3"),
            .init(value: 0x04, description: "Window 4"),
            .init(value: 0x05, description: "Window 5"),
            .init(value: 0x06, description: "Window 6"),
            .init(value: 0x07, description: "Window 7"),
        ]
    )

    // MARK: LUT
    public static let lutSize = VCPFeature(
        id: "lut-size",
        code: 0x73,
        name: "LUT Size",
        description: "Provides the size (number of entries and number of bits/entry) of a display's lookup table",
        kind: .table,
    )
    public static let singlePointLUTOperation = VCPFeature(
        id: "single-point-lut-operation",
        code: 0x74,
        name: "Single Point LUT Operation",
        description: "Writes a single point within the display's LUT, reads a single point from the LUT",
        kind: .table,
    )
    public static let blockLUTOperation = VCPFeature(
        id: "block-lut-operation",
        code: 0x75,
        name: "Block LUT Operation",
        description: "Load (read) multiple values into (from) the display's LUT",
        kind: .table,
    )

    // MARK: Power
    public static let powerMode = VCPFeature(
        id: "power-mode",
        code: 0xd6,
        name: "Power Mode",
        description: "DPM and DPMS status",
        kind: .table,
        slValues: [
            .init(value: 0x01, description: "DPM: On, DPMS: Off"),
            .init(value: 0x02, description: "DPM: Off, DPMS: Standby"),
            .init(value: 0x03, description: "DPM: Off, DPMS: Suspend"),
            .init(value: 0x04, description: "DPM: Off, DPMS: Off"),
            .init(value: 0x05, description: "Write only: turn off"),
        ]
    )
    public static let auxiliaryPowerOutput = VCPFeature(
        id: "auxiliary-power-output",
        code: 0xd7,
        name: "Auxiliary Power Output",
        description: "Controls an auxiliary power output from a display to a host device",
        kind: .table,
        slValues: [
            .init(value: 0x01, description: "Disable auxiliary power output"),
            .init(value: 0x02, description: "Enable auxiliary power output"),
        ]
    )
}
