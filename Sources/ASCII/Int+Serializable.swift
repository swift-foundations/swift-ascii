import ASCII_Primitives_Standard_Library_Integration
public import INCITS_4_1986

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
