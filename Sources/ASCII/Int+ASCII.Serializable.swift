// Int+ASCII.Serializable.swift
// swift-ascii
//
// Binary.ASCII.Serializable conformances for integer types

public import INCITS_4_1986

// MARK: - Decimal Namespace

extension Binary.ASCII {
    /// Namespace for decimal integer operations.
    public enum Decimal {}
}

extension Binary.ASCII.Decimal {
    /// Error describing why decimal integer parsing failed.
    public enum Error: Swift.Error, Equatable, Sendable {
        /// Input was empty or contained only a sign with no digits.
        case empty
        /// Found a non-digit byte at the specified position.
        ///
        /// - Parameters:
        ///   - position: Zero-based index where the invalid byte was found.
        ///   - found: The actual byte value encountered.
        case invalidByte(position: Int, found: UInt8)
    }
}

// MARK: - Primitive Parsing Functions

extension Binary.ASCII.Decimal {
    /// Parse signed integer from ASCII decimal bytes.
    @inlinable
    internal static func parseSigned<T: SignedInteger & FixedWidthInteger, Bytes: Collection>(
        _ bytes: Bytes
    ) throws(Error) -> T where Bytes.Element == UInt8 {
        var result: T = 0
        var isNegative = false
        var index = bytes.startIndex
        var position = 0

        // Handle sign
        if index < bytes.endIndex {
            let first = bytes[index]
            if first == INCITS_4_1986.GraphicCharacters.hyphen {
                isNegative = true
                index = bytes.index(after: index)
                position += 1
            } else if first == INCITS_4_1986.GraphicCharacters.plusSign {
                index = bytes.index(after: index)
                position += 1
            }
        }

        guard index < bytes.endIndex else { throw .empty }

        while index < bytes.endIndex {
            let byte = bytes[index]
            guard let digit = INCITS_4_1986.NumericParsing.digit(byte) else {
                throw .invalidByte(position: position, found: byte)
            }
            result = result * 10 + T(digit)
            index = bytes.index(after: index)
            position += 1
        }

        return isNegative ? -result : result
    }

    /// Parse unsigned integer from ASCII decimal bytes.
    @inlinable
    internal static func parseUnsigned<T: UnsignedInteger & FixedWidthInteger, Bytes: Collection>(
        _ bytes: Bytes
    ) throws(Error) -> T where Bytes.Element == UInt8 {
        var result: T = 0
        var index = bytes.startIndex
        var position = 0

        // Handle optional plus sign
        if index < bytes.endIndex && bytes[index] == INCITS_4_1986.GraphicCharacters.plusSign {
            index = bytes.index(after: index)
            position += 1
        }

        guard index < bytes.endIndex else { throw .empty }

        while index < bytes.endIndex {
            let byte = bytes[index]
            guard let digit = INCITS_4_1986.NumericParsing.digit(byte) else {
                throw .invalidByte(position: position, found: byte)
            }
            result = result * 10 + T(digit)
            index = bytes.index(after: index)
            position += 1
        }

        return result
    }
}

// MARK: - Signed Integer Conformances

extension Int: @retroactive Binary.Serializable, Binary.ASCII.Serializable {
    public typealias Error = Binary.ASCII.Decimal.Error

    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii value: Int,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        INCITS_4_1986.NumericSerialization.serializeDecimal(value, into: &buffer)
    }

    @inlinable
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Void
    ) throws(Error) where Bytes.Element == UInt8 {
        self = try Binary.ASCII.Decimal.parseSigned(bytes)
    }
}

extension Int64: @retroactive Binary.Serializable, Binary.ASCII.Serializable {
    public typealias Error = Binary.ASCII.Decimal.Error

    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii value: Int64,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        INCITS_4_1986.NumericSerialization.serializeDecimal(value, into: &buffer)
    }

    @inlinable
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Void
    ) throws(Error) where Bytes.Element == UInt8 {
        self = try Binary.ASCII.Decimal.parseSigned(bytes)
    }
}

// MARK: - Unsigned Integer Conformances

extension UInt: @retroactive Binary.Serializable, Binary.ASCII.Serializable {
    public typealias Error = Binary.ASCII.Decimal.Error

    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii value: UInt,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        INCITS_4_1986.NumericSerialization.serializeDecimal(value, into: &buffer)
    }

    @inlinable
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Void
    ) throws(Error) where Bytes.Element == UInt8 {
        self = try Binary.ASCII.Decimal.parseUnsigned(bytes)
    }
}

extension UInt64: @retroactive Binary.Serializable, Binary.ASCII.Serializable {
    public typealias Error = Binary.ASCII.Decimal.Error

    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii value: UInt64,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        INCITS_4_1986.NumericSerialization.serializeDecimal(value, into: &buffer)
    }

    @inlinable
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Void
    ) throws(Error) where Bytes.Element == UInt8 {
        self = try Binary.ASCII.Decimal.parseUnsigned(bytes)
    }
}
