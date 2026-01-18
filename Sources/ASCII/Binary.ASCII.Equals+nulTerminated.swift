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

extension Binary.ASCII.Equals {
    /// Compares a NUL-terminated byte sequence to an ASCII literal.
    ///
    /// Performs a byte-by-byte comparison without allocating memory or
    /// constructing Swift strings. The comparison succeeds if and only if:
    /// - All bytes in the literal match the corresponding bytes at `pointer`
    /// - The byte following the matched prefix is NUL (0x00)
    ///
    /// - Parameters:
    ///   - pointer: Pointer to a NUL-terminated byte sequence.
    ///   - ascii: ASCII literal to compare against. Must contain only ASCII bytes.
    ///
    /// - Returns: `true` if the NUL-terminated sequence equals the literal.
    ///
    /// - Precondition: `pointer` must point to a valid NUL-terminated sequence.
    /// - Precondition: `ascii` must contain only ASCII characters (bytes < 0x80).
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Checking filesystem type from statfs
    /// if unsafe Binary.ASCII.equals.nulTerminated(fsTypePointer, "apfs") {
    ///     // Handle APFS filesystem
    /// }
    /// ```
    ///
    /// ## Platform Behavior
    ///
    /// This operation is pure byte comparison with no encoding assumptions.
    /// It works identically on all platforms.
    @inlinable
    public func nulTerminated(
        _ pointer: UnsafePointer<UInt8>,
        _ ascii: StaticString
    ) -> Bool {
        let count = ascii.utf8CodeUnitCount

        return ascii.withUTF8Buffer { literal in
            for i in 0..<count {
                let byte = unsafe pointer[i]
                // Early exit if we hit NUL before matching all literal bytes
                // or if any byte doesn't match
                guard byte != 0, byte == literal[i] else { return false }
            }
            // All literal bytes matched; verify terminator follows
            return unsafe pointer[count] == 0
        }
    }
}
