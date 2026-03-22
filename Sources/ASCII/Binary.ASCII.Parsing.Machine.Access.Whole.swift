// Binary.ASCII.Parsing.Machine.Access.Whole.swift
// Zero-copy whole-input parsing wrapper for Machine parsers

public import Binary_Parser_Primitives
internal import Memory_Primitives

extension Binary.ASCII.Parsing.Machine.Access {
    /// Whole-input parsing capability for Machine parsers.
    ///
    /// Enforces that all input must be consumed by checking the consumed count
    /// at execution time. Uses `withBorrowed.whole` for zero-copy execution.
    public struct Whole {
        @usableFromInline
        internal let parser: Binary.Bytes.Machine.Parser<Output>

        @inlinable
        internal init(_ parser: Binary.Bytes.Machine.Parser<Output>) {
            self.parser = parser
        }
    }
}

extension Binary.ASCII.Parsing.Machine.Access.Whole {
    /// Parse entire byte array.
    @inlinable
    public func call(_ bytes: [UInt8]) throws(Binary.Bytes.Machine.Fault) -> Output {
        try Binary.Bytes.withBorrowed.whole(bytes, parser)
    }

    /// Parse entire contiguous storage.
    @inlinable
    public func call<C: Memory.Contiguous.`Protocol`>(
        _ source: borrowing C
    ) throws(Binary.Bytes.Machine.Fault) -> Output
    where C: ~Copyable, C.Element == UInt8 {
        try Binary.Bytes.withBorrowed.whole(source, parser)
    }

    /// Parse entire string (UTF-8).
    @inlinable
    public func call(_ string: some StringProtocol) throws(Binary.Bytes.Machine.Fault) -> Output {
        let bytes: [UInt8] = .init(string.utf8)
        return try call(bytes)
    }
}
