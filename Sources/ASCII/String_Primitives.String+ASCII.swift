// ===----------------------------------------------------------------------===//
//
// This source file is part of the swift-ascii open source project
//
// Copyright (c) 2024-2025 Coen ten Thije Boonkkamp and the swift-ascii project authors
// Licensed under Apache License v2.0
//
// See LICENSE for license information
//
// ===----------------------------------------------------------------------===//

public import String_Primitives

// MARK: - ASCII Literal Initialization

extension String_Primitives.String {
    /// Creates an owned string from an ASCII string literal.
    ///
    /// Copies the bytes from the literal into owned storage.
    ///
    /// - Parameter literal: The string literal. Must contain only ASCII characters (bytes < 0x80).
    /// - Precondition: All bytes in the literal must be ASCII (< 0x80).
    ///
    /// ## Platform Behavior
    ///
    /// ASCII-only ensures identical behavior on POSIX (UTF-8) and Windows (UTF-16):
    /// each ASCII byte maps 1:1 to a code unit on both platforms.
    ///
    /// For non-ASCII Unicode literals, use the bridging APIs in swift-strings (Foundations).
    @inlinable
    public init(ascii literal: StaticString) {
        let count = literal.utf8CodeUnitCount
        let buffer = UnsafeMutablePointer<String_Primitives.String.Char>.allocate(capacity: count + 1)

        literal.withUTF8Buffer { utf8 in
            for i in 0..<count {
                let byte = unsafe utf8[i]
                precondition(byte < 0x80, "String.init(ascii:): literal contains non-ASCII byte at index \(i)")
                (unsafe buffer)[i] = String_Primitives.String.Char(byte)
            }
        }
        (unsafe buffer)[count] = String_Primitives.String.terminator

        unsafe self.init(adopting: buffer, count: count)
    }
}
