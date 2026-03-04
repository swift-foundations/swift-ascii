public import Parser_Primitives
public import Binary_Primitives
public import Memory_Primitives

extension Binary.ASCII.Access {
    @inlinable
    public func whole(_ bytes: [UInt8]) throws(Parser.Error.Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output {
        try Binary.ASCII.Parsing.Whole(parser).call(bytes)
    }

    @inlinable
    public func whole<C: Memory.Contiguous.`Protocol`>(
        _ source: borrowing C
    ) throws(Parser.Error.Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output
    where C: ~Copyable, C.Element == UInt8 {
        try Binary.ASCII.Parsing.Whole(parser).call(source)
    }

    @inlinable
    public func whole(
        _ string: some StringProtocol
    ) throws(Parser.Error.Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output {
        try Binary.ASCII.Parsing.Whole(parser).call(string)
    }
}
