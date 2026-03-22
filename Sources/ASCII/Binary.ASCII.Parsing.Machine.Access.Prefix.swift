// Binary.ASCII.Parsing.Machine.Access.Prefix.swift
// Zero-copy prefix parsing wrapper for Machine parsers

public import Binary_Parser_Primitives
public import Serialization_Primitives
internal import Memory_Primitives

extension Binary.ASCII.Parsing.Machine.Access {
    /// Prefix parsing capability for Machine parsers.
    ///
    /// Parses a prefix of the input without requiring all bytes to be consumed.
    /// Uses `withBorrowed.prefix` for zero-copy execution with consumed count.
    public struct Prefix {
        @usableFromInline
        internal let parser: Binary_Parser_Primitives.Binary.Bytes.Machine.Parser<Output>

        @inlinable
        internal init(_ parser: Binary_Parser_Primitives.Binary.Bytes.Machine.Parser<Output>) {
            self.parser = parser
        }
    }
}

extension Binary.ASCII.Parsing.Machine.Access.Prefix where Output: Sendable {
    /// Parse prefix of byte array, returning value and consumed count.
    @inlinable
    public func call(_ bytes: [UInt8]) throws(Binary_Parser_Primitives.Binary.Bytes.Machine.Fault) -> Serialization.Parsing.Prefix.Result<Output, Index<UInt8>.Count> {
        try Binary_Parser_Primitives.Binary.Bytes.withBorrowed.prefix(bytes, parser)
    }

    /// Parse prefix of contiguous storage, returning value and consumed count.
    @inlinable
    public func call<C: Memory.Contiguous.`Protocol`>(
        _ source: borrowing C
    ) throws(Binary_Parser_Primitives.Binary.Bytes.Machine.Fault) -> Serialization.Parsing.Prefix.Result<Output, Index<UInt8>.Count>
    where C: ~Copyable, C.Element == UInt8 {
        try Binary_Parser_Primitives.Binary.Bytes.withBorrowed.prefix(source, parser)
    }

    /// Parse prefix of string (UTF-8), returning value and consumed count.
    @inlinable
    public func call(_ string: some StringProtocol) throws(Binary_Parser_Primitives.Binary.Bytes.Machine.Fault) -> Serialization.Parsing.Prefix.Result<Output, Index<UInt8>.Count> {
        let bytes: [UInt8] = .init(string.utf8)
        return try call(bytes)
    }
}
