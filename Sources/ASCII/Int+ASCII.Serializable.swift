// Int+ASCII.Serializable.swift
// swift-ascii
//
// Binary.ASCII.Serializable conformances for integer types
//
// Substrate per the ASCII-domain retyping arc (2026-05-19): conformance
// signatures use `Buffer.Element == Byte` / `Bytes.Element == Byte`. The
// internal parseSigned/parseUnsigned helpers type-up at the entry boundary
// to `ASCII.Code` so the body works against ASCII.Code constants directly
// (decimal grammar is strict ASCII).

public import INCITS_4_1986
public import ASCII_Primitives_Standard_Library_Integration

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
        ///   - found: The actual byte value encountered (ASCII-domain code).
        case invalidByte(position: Int, found: ASCII.Code)
    }
}

// MARK: - Primitive Parsing Functions

extension Binary.ASCII.Decimal {
    /// Parse signed integer from ASCII decimal bytes.
    @inlinable
    internal static func parseSigned<T: SignedInteger & FixedWidthInteger, Bytes: Collection>(
        _ bytes: Bytes
    ) throws(Error) -> T where Bytes.Element == Byte {
        // Type-up: lift to ASCII.Code at the entry boundary so the body works
        // against ASCII.Code constants directly (decimal grammar is strict ASCII;
        // non-ASCII bytes are fail-state).
        let arr = Array<ASCII.Code>(bytes)
        var result: T = 0
        var isNegative = false
        var index = 0

        // Handle sign
        if index < arr.count {
            let first = arr[index]
            if first == .hyphen {
                isNegative = true
                index += 1
            } else if first == .plusSign {
                index += 1
            }
        }

        guard index < arr.count else { throw .empty }

        while index < arr.count {
            let code = arr[index]
            guard let digit = code.digitValue else {
                throw .invalidByte(position: index, found: code)
            }
            result = result * 10 + T(digit)
            index += 1
        }

        return isNegative ? -result : result
    }

    /// Parse unsigned integer from ASCII decimal bytes.
    @inlinable
    internal static func parseUnsigned<T: UnsignedInteger & FixedWidthInteger, Bytes: Collection>(
        _ bytes: Bytes
    ) throws(Error) -> T where Bytes.Element == Byte {
        // Type-up: lift to ASCII.Code at the entry boundary.
        let arr = Array<ASCII.Code>(bytes)
        var result: T = 0
        var index = 0

        // Handle optional plus sign
        if index < arr.count && arr[index] == .plusSign {
            index += 1
        }

        guard index < arr.count else { throw .empty }

        while index < arr.count {
            let code = arr[index]
            guard let digit = code.digitValue else {
                throw .invalidByte(position: index, found: code)
            }
            result = result * 10 + T(digit)
            index += 1
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
    ) where Buffer.Element == Byte {
        // INCITS_4_1986.Numeric.Serialization.serializeDecimal targets a
        // `Buffer.Element == UInt8` substrate; bridge to the Byte-typed
        // buffer via BSLI's `append(contentsOf: <UInt8>)` overload.
        var byteBuffer: [UInt8] = []
        INCITS_4_1986.Numeric.Serialization.serializeDecimal(value, into: &byteBuffer)
        buffer.append(contentsOf: byteBuffer)
    }

    @inlinable
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Void
    ) throws(Error) where Bytes.Element == Byte {
        self = try Binary.ASCII.Decimal.parseSigned(bytes)
    }
}

extension Int64: @retroactive Binary.Serializable, Binary.ASCII.Serializable {
    public typealias Error = Binary.ASCII.Decimal.Error

    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii value: Int64,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        var byteBuffer: [UInt8] = []
        INCITS_4_1986.Numeric.Serialization.serializeDecimal(value, into: &byteBuffer)
        buffer.append(contentsOf: byteBuffer)
    }

    @inlinable
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Void
    ) throws(Error) where Bytes.Element == Byte {
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
    ) where Buffer.Element == Byte {
        var byteBuffer: [UInt8] = []
        INCITS_4_1986.Numeric.Serialization.serializeDecimal(value, into: &byteBuffer)
        buffer.append(contentsOf: byteBuffer)
    }

    @inlinable
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Void
    ) throws(Error) where Bytes.Element == Byte {
        self = try Binary.ASCII.Decimal.parseUnsigned(bytes)
    }
}

extension UInt64: @retroactive Binary.Serializable, Binary.ASCII.Serializable {
    public typealias Error = Binary.ASCII.Decimal.Error

    @inlinable
    public static func serialize<Buffer: RangeReplaceableCollection>(
        ascii value: UInt64,
        into buffer: inout Buffer
    ) where Buffer.Element == Byte {
        var byteBuffer: [UInt8] = []
        INCITS_4_1986.Numeric.Serialization.serializeDecimal(value, into: &byteBuffer)
        buffer.append(contentsOf: byteBuffer)
    }

    @inlinable
    public init<Bytes: Collection>(
        ascii bytes: Bytes,
        in context: Void
    ) throws(Error) where Bytes.Element == Byte {
        self = try Binary.ASCII.Decimal.parseUnsigned(bytes)
    }
}
