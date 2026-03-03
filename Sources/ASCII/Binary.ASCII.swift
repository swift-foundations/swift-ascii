//
//  Binary.ASCII.swift
//  swift-ascii
//
//  ASCII operations namespace for UInt8.

public import Binary_Primitives
import Standard_Library_Extensions

extension Binary {

    /// ASCII operations namespace for UInt8
    ///
    /// Provides all ASCII character classification, manipulation, and constant access methods
    /// for byte-level operations per INCITS 4-1986 (US-ASCII standard).
    ///
    /// ## Overview
    ///
    /// The `ASCII` struct serves as a namespace for ASCII-related operations on bytes, providing:
    /// - **Character classification**: Test if bytes are whitespace, digits, letters, etc.
    /// - **Numeric parsing**: Convert ASCII digits to numeric values
    /// - **Case conversion**: Transform ASCII letters between upper and lower case
    /// - **Direct constant access**: All 128 ASCII character constants (0x00-0x7F)
    ///
    /// ## Performance
    ///
    /// Methods are marked `@_transparent` or `@inlinable` for optimal performance.
    /// Character classification uses direct byte comparisons rather than Set lookups.
    ///
    /// ## Access Patterns
    ///
    /// Access methods in two ways:
    /// - **Static**: `UInt8.ascii.A` - For constants and static methods
    /// - **Instance**: `byte.ascii.isLetter` - For instance classification
    ///
    /// ## See Also
    ///
    /// - ``INCITS_4_1986``
    /// - ``INCITS_4_1986/ControlCharacters``
    /// - ``INCITS_4_1986/GraphicCharacters``
    public struct ASCII {
        /// The wrapped byte value
        public let byte: UInt8
    }
}
