// Copyright © 2017 Tellus, Inc. All rights reserved.

/// Prints a warning with the given message if the application is in debug mode.
func ZLWarn(_ message: String) {
    guard Environment.current != .production else { return }
    print("WARNING: \(message)")
}

/// Prints the given message if the application is in debug mode.
func ZLLog(_ format: String, _ arguments: CVarArg...) {
    guard Environment.current != .production else { return }
    print(String(format: format, arguments: arguments))
}

/// Prints the given message if the application is in debug mode.
func ZLLog(_ object: Any) {
    ZLLog("%@", String(describing: object))
}

/// Prints `object` if the application is in debug mode.
func ZLDump(_ object: Any?) {
    guard Environment.current.isDebug else { return }
    print(object ?? "nil")
}

/// Returns `f(x)` if `x` is non-`nil`; otherwise returns `nil`.
func given<T, U>(_ x: T?, _ f: (T) throws -> U?) rethrows -> U? {
    guard let x = x else { return nil }
    return try f(x)
}

/// Returns `f(x!, y!)` if `x != nil && y != nil`; otherwise returns `nil`.
func given<T, U, V>(_ x: T?, _ y: U?, _ f: (T, U) throws -> V?) rethrows -> V? {
    guard let x = x, let y = y else { return nil }
    return try f(x, y)
}

func lazy<T>(_ variable: inout T?, construction: () throws -> T) rethrows -> T {
    if let value = variable {
        return value
    } else {
        let value = try construction()
        variable = value
        return value
    }
}

/// A no-op that prevents the passed argument from being optimized away by the compiler.
@inline(never)
func touch(_ x: Any?) { }

precedencegroup ExponentiationPrecedence {
    associativity: right
    higherThan: MultiplicationPrecedence
}

infix operator ** : ExponentiationPrecedence

func **<T : BinaryInteger>(lhs: T, rhs: T) -> T {
    precondition(rhs >= 0)
    var result: T = 1
    var count: T = 0
    while count < rhs {
        result *= lhs
        count = count + 1
    }
    return result
}

func fatalError<T>(_ message: @autoclosure ()->String = "", file: StaticString = #file, line: UInt = #line) -> T {
    fatalError(message, file: file, line: line)
}

func preconditionFailure<T>(_ message: @autoclosure ()->String = "", file: StaticString = #file, line: UInt = #line) -> T {
    preconditionFailure(message, file: file, line: line)
}

func notImplemented(function: String = #function, file: String = #file, line: Int = #line) -> Never {
    preconditionFailure("Function not implemented: \(function) in \"\(file)\" line #\(line).")
}

func abstract(function: String = #function, file: String = #file, line: Int = #line) -> Never {
    preconditionFailure("Abstract method not implemented: \(function) in \"\(file)\" line #\(line).")
}
