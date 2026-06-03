// Binary.ASCII.Parsing.Machine.Access.Whole.swift
// Zero-copy whole-input parsing wrapper for Machine parsers

public import Binary_Parser_Primitives
internal import Memory_Primitives
// W3 PRUNE: parse re-homed to the Span.Borrowed.`Protocol` byte-span seam;
// `Swift.Span: Span.Borrowed.`Protocol`` conformance needed in scope (Finding 3/8).
internal import Span_Protocol_Primitives

extension Binary.ASCII.Parsing.Machine.Access {
    /// Whole-input parsing capability for Machine parsers.
    ///
    /// Enforces that all input must be consumed by checking the consumed count
    /// at execution time. Delegates to the byte-span `parseWhole` (on
    /// `Span.Borrowed.`Protocol``) for zero-copy execution.
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
        // W3 PRUNE: the borrowed view IS the source's Swift.Span<Byte>.
        try source.span.parseWhole(parser)
    }

    /// Parse entire string (UTF-8).
    @inlinable
    public func call(_ string: some StringProtocol) throws(Binary.Machine.Fault) -> Output {
        let bytes: [Byte] = .init(string.utf8)
        return try call(bytes)
    }
}
