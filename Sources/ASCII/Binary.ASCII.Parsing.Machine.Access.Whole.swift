// Binary.ASCII.Parsing.Machine.Access.Whole.swift
// Zero-copy whole-input parsing wrapper for Machine parsers

public import Binary_Parser_Primitives
internal import Memory_Primitives

extension Binary.ASCII.Parsing.Machine.Access {
    /// Whole-input parsing capability for Machine parsers.
    ///
    /// Enforces that all input must be consumed by checking the consumed count
    /// at execution time. Delegates to `Binary.Borrowed.parseWhole` for
    /// zero-copy execution.
    public struct Whole {
        @usableFromInline
        internal let parser: Binary.Machine.Parser<Output>

        @inlinable
        internal init(_ parser: Binary.Machine.Parser<Output>) {
            self.parser = parser
        }
    }
}

extension Binary.ASCII.Parsing.Machine.Access.Whole {
    /// Parse entire byte array.
    @inlinable
    public func call(_ bytes: [Byte]) throws(Binary.Machine.Fault) -> Output {
        try Binary(bytes).parseWhole(parser)
    }

    /// Parse entire contiguous storage.
    @inlinable
    public func call<C: Memory.Contiguous.`Protocol`>(
        _ source: borrowing C
    ) throws(Binary.Machine.Fault) -> Output
    where C: ~Copyable, C.Element == Byte {
        try Binary.Borrowed(source.span).parseWhole(parser)
    }

    /// Parse entire string (UTF-8).
    @inlinable
    public func call(_ string: some StringProtocol) throws(Binary.Machine.Fault) -> Output {
        let bytes: [Byte] = .init(string.utf8)
        return try call(bytes)
    }
}
