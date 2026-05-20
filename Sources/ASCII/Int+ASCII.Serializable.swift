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
        ///   - found: The byte value encountered. Carried as `Byte` (not
        ///     `ASCII.Code`) because invalid input may include non-ASCII
        ///     bytes (≥ 0x80) that cannot be represented as `ASCII.Code`
        ///     under its typed-throws contract.
        case invalidByte(position: Int, found: Byte)
    }
}

// MARK: - Primitive Parsing Functions

extension Binary.ASCII.Decimal {
    /// Parse signed integer from ASCII decimal bytes.
    @inlinable
    internal static func parseSigned<T: SignedInteger & FixedWidthInteger, Bytes: Collection>(
        _ bytes: Bytes
    ) throws(Error) -> T where Bytes.Element == Byte {
        // Byte-level dispatch using named ASCII constants via `.byte`. The
        // bulk `Array<ASCII.Code>(bytes)` lift was replaced with per-byte
        // comparison because the SLI throwing lift loses position info, and
        // ASCII.Code's typed-throws contract cannot carry a non-ASCII byte
        // for the `.invalidByte(found:)` error case (now Byte-typed).
        let arr = Array(bytes)
        var result: T = 0
        var isNegative = false
        var index = 0

        // Handle sign
        if index < arr.count {
            let first = arr[index]
            if first == ASCII.Code.hyphen.byte {
                isNegative = true
                index += 1
            } else if first == ASCII.Code.plusSign.byte {
                index += 1
            }
        }

        guard index < arr.count else { throw .empty }

        while index < arr.count {
            let byte = arr[index]
            guard byte >= ASCII.Code.`0`.byte && byte <= ASCII.Code.`9`.byte else {
                throw .invalidByte(position: index, found: byte)
            }
            let digit = byte.underlying &- 0x30
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
        // Byte-level dispatch — same rationale as parseSigned above.
        let arr = Array(bytes)
        var result: T = 0
        var index = 0

        // Handle optional plus sign
        if index < arr.count && arr[index] == ASCII.Code.plusSign.byte {
            index += 1
        }

        guard index < arr.count else { throw .empty }

        while index < arr.count {
            let byte = arr[index]
            guard byte >= ASCII.Code.`0`.byte && byte <= ASCII.Code.`9`.byte else {
                throw .invalidByte(position: index, found: byte)
            }
            let digit = byte.underlying &- 0x30
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
