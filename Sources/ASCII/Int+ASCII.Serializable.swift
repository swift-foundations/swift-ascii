// Int+ASCII.Serializable.swift
// swift-ascii
//
// Binary.ASCII.Serializable conformances for integer types

public import INCITS_4_1986

// MARK: - FixedWidthInteger Conformance

extension Int: @retroactive Binary.Serializable, Binary.ASCII.Serializable {
    public enum Error: Swift.Error {
        case invalidFormat
    }

    /// Serialize Int to ASCII decimal bytes
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii value: Int,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        INCITS_4_1986.NumericSerialization.serializeDecimal(value, into: &buffer)
    }

    /// Parse Int from ASCII decimal bytes
    @inlinable
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Void
    ) throws(Error) where Bytes.Element == UInt8 {
        var result: Int = 0
        var isNegative = false
        var index = bytes.startIndex

        // Handle sign
        if index < bytes.endIndex {
            let first = bytes[index]
            if first == INCITS_4_1986.GraphicCharacters.hyphen {
                isNegative = true
                index = bytes.index(after: index)
            } else if first == INCITS_4_1986.GraphicCharacters.plusSign {
                index = bytes.index(after: index)
            }
        }

        guard index < bytes.endIndex else { throw .invalidFormat }

        while index < bytes.endIndex {
            guard let digit = INCITS_4_1986.NumericParsing.digit(bytes[index]) else {
                throw .invalidFormat
            }
            result = result * 10 + Int(digit)
            index = bytes.index(after: index)
        }

        self = isNegative ? -result : result
    }
}

extension Int64: @retroactive Binary.Serializable, Binary.ASCII.Serializable {
    public enum Error: Swift.Error {
        case invalidFormat
    }

    /// Serialize Int64 to ASCII decimal bytes
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii value: Int64,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        INCITS_4_1986.NumericSerialization.serializeDecimal(value, into: &buffer)
    }

    /// Parse Int64 from ASCII decimal bytes
    @inlinable
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Void
    ) throws(Error) where Bytes.Element == UInt8 {
        var result: Int64 = 0
        var isNegative = false
        var index = bytes.startIndex

        // Handle sign
        if index < bytes.endIndex {
            let first = bytes[index]
            if first == INCITS_4_1986.GraphicCharacters.hyphen {
                isNegative = true
                index = bytes.index(after: index)
            } else if first == INCITS_4_1986.GraphicCharacters.plusSign {
                index = bytes.index(after: index)
            }
        }

        guard index < bytes.endIndex else { throw .invalidFormat }

        while index < bytes.endIndex {
            guard let digit = INCITS_4_1986.NumericParsing.digit(bytes[index]) else {
                throw .invalidFormat
            }
            result = result * 10 + Int64(digit)
            index = bytes.index(after: index)
        }

        self = isNegative ? -result : result
    }
}

extension UInt: @retroactive Binary.Serializable, Binary.ASCII.Serializable {
    public enum Error: Swift.Error {
        case invalidFormat
    }

    /// Serialize UInt to ASCII decimal bytes
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii value: UInt,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        INCITS_4_1986.NumericSerialization.serializeDecimal(value, into: &buffer)
    }

    /// Parse UInt from ASCII decimal bytes
    @inlinable
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Void
    ) throws(Error) where Bytes.Element == UInt8 {
        var result: UInt = 0
        var index = bytes.startIndex

        // Handle optional plus sign
        if index < bytes.endIndex && bytes[index] == INCITS_4_1986.GraphicCharacters.plusSign {
            index = bytes.index(after: index)
        }

        guard index < bytes.endIndex else { throw .invalidFormat }

        while index < bytes.endIndex {
            guard let digit = INCITS_4_1986.NumericParsing.digit(bytes[index]) else {
                throw .invalidFormat
            }
            result = result * 10 + UInt(digit)
            index = bytes.index(after: index)
        }

        self = result
    }
}

extension UInt64: @retroactive Binary.Serializable, Binary.ASCII.Serializable {
    public enum Error: Swift.Error {
        case invalidFormat
    }

    /// Serialize UInt64 to ASCII decimal bytes
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii value: UInt64,
        into buffer: inout Buffer
    ) where Buffer.Element == UInt8 {
        INCITS_4_1986.NumericSerialization.serializeDecimal(value, into: &buffer)
    }

    /// Parse UInt64 from ASCII decimal bytes
    @inlinable
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Void
    ) throws(Error) where Bytes.Element == UInt8 {
        var result: UInt64 = 0
        var index = bytes.startIndex

        // Handle optional plus sign
        if index < bytes.endIndex && bytes[index] == INCITS_4_1986.GraphicCharacters.plusSign {
            index = bytes.index(after: index)
        }

        guard index < bytes.endIndex else { throw .invalidFormat }

        while index < bytes.endIndex {
            guard let digit = INCITS_4_1986.NumericParsing.digit(bytes[index]) else {
                throw .invalidFormat
            }
            result = result * 10 + UInt64(digit)
            index = bytes.index(after: index)
        }

        self = result
    }
}
