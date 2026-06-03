public import Span_Protocol_Primitives
public import Parser_Primitives
public import Binary_Primitives
internal import Memory_Primitives

extension Binary.ASCII.Access where P.Output: Sendable {
    @inlinable
    public func prefix(_ bytes: [Byte]) throws(P.Failure) -> (value: P.Output, count: Index<Byte>.Count) {
        try Binary.ASCII.Parsing.Prefix(parser).call(bytes)
    }

    @inlinable
    public func prefix<C: Span.`Protocol`>(
        _ source: borrowing C
    ) throws(P.Failure) -> (value: P.Output, count: Index<Byte>.Count)
    where C: ~Copyable, C.Element == Byte {
        try Binary.ASCII.Parsing.Prefix(parser).call(source)
    }

    @inlinable
    public func prefix(
        _ string: some StringProtocol
    ) throws(P.Failure) -> (value: P.Output, count: Index<Byte>.Count) {
        try Binary.ASCII.Parsing.Prefix(parser).call(string)
    }
}
