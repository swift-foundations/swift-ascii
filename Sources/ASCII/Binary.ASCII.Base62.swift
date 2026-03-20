//
//  Binary.ASCII.Base62.swift
//  swift-ascii
//
//  Base62 digit parsing following the ASCII.Parsing.digit() / hexDigit() pattern.
//

public import Base62_Standard

extension Binary.ASCII {
    /// Namespace for Base62 digit operations.
    ///
    /// Provides single-byte Base62 digit parsing and validation,
    /// paralleling ``ASCII/Parsing/digit(_:)`` for decimal
    /// and ``ASCII/Parsing/hexDigit(_:)`` for hexadecimal.
    ///
    /// Unlike decimal and hexadecimal, Base62 digits are alphabet-dependent:
    /// the mapping between bytes and digit values changes with the alphabet.
    ///
    /// ## Usage
    ///
    /// ```swift
    /// // Standard alphabet: 0-9 → 0-9, A-Z → 10-35, a-z → 36-61
    /// Binary.ASCII.Base62.digit(UInt8.ascii.A)                   // 10
    /// Binary.ASCII.Base62.digit(UInt8.ascii.a)                   // 36
    /// Binary.ASCII.Base62.digit(UInt8.ascii.exclamationPoint)    // nil
    ///
    /// // GMP alphabet: A-Z → 0-25, a-z → 26-51, 0-9 → 52-61
    /// Binary.ASCII.Base62.digit(UInt8.ascii.A, using: .gmp)     // 0
    /// Binary.ASCII.Base62.digit(UInt8.ascii.`0`, using: .gmp)   // 52
    ///
    /// // Validation
    /// Binary.ASCII.Base62.isDigit(UInt8.ascii.A)                 // true
    /// Binary.ASCII.Base62.isDigit(UInt8.ascii.exclamationPoint)  // false
    /// ```
    public enum Base62 {}
}

extension Binary.ASCII.Base62 {
    /// Parses a Base62 digit byte to its numeric value (0-61).
    ///
    /// - Parameters:
    ///   - byte: The ASCII byte representing a Base62 digit.
    ///   - alphabet: The alphabet to use (default: `.default` which is `.standard`).
    /// - Returns: The digit value (0-61), or `nil` if byte is not a valid Base62 digit.
    @inlinable
    public static func digit(
        _ byte: UInt8,
        using alphabet: Base62_Standard.Alphabet = .default
    ) -> UInt8? {
        alphabet.decode(byte)
    }

    /// Returns true if byte is a valid Base62 digit character.
    ///
    /// - Parameters:
    ///   - byte: The ASCII byte to test.
    ///   - alphabet: The alphabet to use (default: `.default` which is `.standard`).
    /// - Returns: `true` if the byte is valid in the specified alphabet.
    @inlinable
    public static func isDigit(
        _ byte: UInt8,
        using alphabet: Base62_Standard.Alphabet = .default
    ) -> Bool {
        alphabet.isValid(byte)
    }
}
