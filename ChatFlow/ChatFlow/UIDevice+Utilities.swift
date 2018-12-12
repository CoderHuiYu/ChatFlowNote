// Copyright © 2018 Tellus, Inc. All rights reserved.

import UIKit

extension UIDevice {
    struct Model : CustomStringConvertible {
        let family: Family
        let majorVersion: Int
        let minorVersion: Int

        var identifier: String { return "\(family.rawValue)\(majorVersion),\(minorVersion)" }

        init(family: Family, majorVersion: Int, minorVersion: Int) {
            (self.family, self.majorVersion, self.minorVersion) = (family, majorVersion, minorVersion)
        }

        init?(identifier: String) {
            let regex = try! NSRegularExpression(pattern: "^([A-Za-z]+)(\\d+),(\\d+)$")
            guard let match = regex.firstMatch(in: identifier, range: NSRange(location: 0, length: identifier.utf16.count)) else { return nil }
            let familyString = (identifier as NSString).substring(with: match.range(at: 1))
            let majorVersionString = (identifier as NSString).substring(with: match.range(at: 2))
            let minorVersionString = (identifier as NSString).substring(with: match.range(at: 3))
            let family = Family(rawValue: familyString) ?? .unknown
            guard let majorVersion = Int(majorVersionString), let minorVersion = Int(minorVersionString) else { return nil }
            (self.family, self.majorVersion, self.minorVersion) = (family, majorVersion, minorVersion)
        }

        var description: String { return identifier }
    }

    enum Family : String {
        case iPhone = "iPhone"
        case iPod = "iPod"
        case iPad = "iPad"
        case appleTV = "AppleTV"
        case appleWatch = "Watch"
        case unknown
    }

    static let model: Model = {
        // Adapted from https://stackoverflow.com/questions/46192280/detect-if-the-device-is-iphone-x
        let identifier: String = {
            if isSimulator {
                return ProcessInfo.processInfo.environment["SIMULATOR_MODEL_IDENTIFIER"] ?? ""
            } else {
                var size = 0
                sysctlbyname("hw.machine", nil, &size, nil, 0)
                var machine = [CChar](repeating: 0, count: size)
                sysctlbyname("hw.machine", &machine, &size, nil, 0)
                return String(cString: machine)
            }
        }()
        guard let model = Model(identifier: identifier) else {
            ZLWarn("Invalid device model identifier: \(identifier)")
            return Model(family: .unknown, majorVersion: 1, minorVersion: 1) // Don't crash
        }
        return model
    }()

    @objc static var isSimulator: Bool {
        return TARGET_OS_SIMULATOR != 0
    }

    @objc static let isIPhoneX: Bool = {
        guard model.family == .iPhone else { return false }
        switch (model.majorVersion, model.minorVersion) {
        case (10, 3), (10, 6), (11..., _): return true // Default unknown newer models to "iPhone X"-like
        default: return false
        }
    }()
}



// MARK: - Legacy

extension UIDevice {
    @objc static var objc_modelIdentifier: String { return model.identifier }
}
