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

public import Binary_Primitives

extension Binary.ASCII {
    /// Accessor for ASCII equality comparisons.
    ///
    /// Provides comparison operations for ASCII byte sequences.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Compare NUL-terminated memory to a literal
    /// if Binary.ASCII.equals.nulTerminated(pointer, "apfs") {
    ///     // matched
    /// }
    /// ```
    public struct Equals: Sendable {
        @usableFromInline
        internal init() {}
    }

    /// Accessor for ASCII equality comparisons.
    public static let equals = Equals()
}
