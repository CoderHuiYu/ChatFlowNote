// Copyright © 2017 Tellus, Inc. All rights reserved.

enum Environment {
    case sandbox, development, staging, production
    
    static var current: Environment {
        // The order here matters. First sandbox, then debug, because the sandbox build config also uses the DEBUG preprocessor macro.
        #if SANDBOX
            return .sandbox
        #elseif DEBUG
            return .development
        #elseif ADHOC
            return .staging
        #elseif RELEASE
            return .production
        #else
            preconditionFailure("Unexpected environment.")
        #endif
    }

    var isDebug: Bool { return self == .sandbox || self == .development }
}
