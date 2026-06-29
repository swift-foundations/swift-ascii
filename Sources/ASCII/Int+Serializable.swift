// Int+Serializable.swift
// swift-ascii
//
// Binary.Serializable conformances for the standard-library integer types,
// serializing to ASCII decimal via INCITS 4-1986.
//
// Migrated off the deprecated `Binary.ASCII.Serializable` (W4): serialization
// lands on `Binary.Serializable` directly. ASCII-decimal PARSING is owned by L1
// (`ASCII.Decimal.Parser` / `ASCII.Parseable` in swift-ascii-parser-primitives),
// so the former in-consumer `Binary.ASCII.Decimal.parse*` helpers are dropped
// rather than re-homed.

public import INCITS_4_1986
public import ASCII_Primitives_Standard_Library_Integration

extension Int: @retroactive Binary.Serializable {
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Int,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        INCITS_4_1986.Numeric.Decimal.serialize(value, into: &buffer)
    }
}

extension Int64: @retroactive Binary.Serializable {
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: Int64,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        INCITS_4_1986.Numeric.Decimal.serialize(value, into: &buffer)
    }
}

extension UInt: @retroactive Binary.Serializable {
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: UInt,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        INCITS_4_1986.Numeric.Decimal.serialize(value, into: &buffer)
    }
}

extension UInt64: @retroactive Binary.Serializable {
    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ value: UInt64,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        INCITS_4_1986.Numeric.Decimal.serialize(value, into: &buffer)
    }
}
