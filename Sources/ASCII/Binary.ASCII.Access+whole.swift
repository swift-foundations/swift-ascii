public import Span_Protocol_Primitives
public import Parser_Primitives
public import Binary_Primitives
internal import Memory_Primitives

extension Binary.ASCII.Access {
    @inlinable
    public func whole(_ bytes: [Byte]) throws(Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output {
        try Binary.ASCII.Parsing.Whole(parser).call(bytes)
    }

    @inlinable
    public func whole<C: Span.`Protocol`>(
        _ source: borrowing C
    ) throws(Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output
    where C: ~Copyable, C.Element == Byte {
        try Binary.ASCII.Parsing.Whole(parser).call(source)
    }

    @inlinable
    public func whole(
        _ string: some StringProtocol
    ) throws(Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output {
        try Binary.ASCII.Parsing.Whole(parser).call(string)
    }
}
