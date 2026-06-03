// Binary.ASCII.Parsing.Machine.Access.Prefix.swift
// Zero-copy prefix parsing wrapper for Machine parsers

public import Binary_Parser_Primitives
internal import Memory_Primitives
// W3 PRUNE: parse re-homed to the Span.Borrowed.`Protocol` byte-span seam;
// `Swift.Span: Span.Borrowed.`Protocol`` conformance needed in scope (Finding 3/8).
public import Span_Protocol_Primitives

extension Binary.ASCII.Parsing.Machine.Access {
    /// Prefix parsing capability for Machine parsers.
    ///
    /// Parses a prefix of the input without requiring all bytes to be consumed.
    /// Delegates to the byte-span `parsePrefix` (on `Span.Borrowed.`Protocol``)
    /// for zero-copy execution with consumed count.
    public struct Prefix {
        @usableFromInline
        internal let parser: Binary_Parser_Primitives.Binary.Machine.Parser<Output>

        @inlinable
        internal init(_ parser: Binary_Parser_Primitives.Binary.Machine.Parser<Output>) {
            self.parser = parser
        }
    }
}

extension Binary.ASCII.Parsing.Machine.Access.Prefix where Output: Sendable {
    /// Parse prefix of byte array, returning value and consumed count.
    @inlinable
    public func call(_ bytes: [Byte]) throws(Binary_Parser_Primitives.Binary.Machine.Fault) -> (value: Output, count: Index<Byte>.Count) {
        try Binary_Parser_Primitives.Binary(bytes).parsePrefix(parser)
    }

    /// Parse prefix of contiguous storage, returning value and consumed count.
    @inlinable
    public func call<C: Span.`Protocol`>(
        _ source: borrowing C
    ) throws(Binary_Parser_Primitives.Binary.Machine.Fault) -> (value: Output, count: Index<Byte>.Count)
    where C: ~Copyable, C.Element == Byte {
        // W3 PRUNE: the borrowed view IS the source's Swift.Span<Byte>.
        try source.span.parsePrefix(parser)
    }

    /// Parse prefix of string (UTF-8), returning value and consumed count.
    @inlinable
    public func call(_ string: some StringProtocol) throws(Binary_Parser_Primitives.Binary.Machine.Fault) -> (value: Output, count: Index<Byte>.Count) {
        let bytes: [Byte] = .init(string.utf8)
        return try call(bytes)
    }
}
