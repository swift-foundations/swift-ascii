public import Parsing_Primitives
public import Binary_Primitives

extension Binary.ASCII.Access {
    @inlinable
    public func whole(_ bytes: [UInt8]) throws(Parsing_Primitives.Parsing.Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output {
        try Binary.ASCII.Parsing.Whole(parser).call(bytes)
    }

    @inlinable
    public func whole<Bytes: Collection>(
        _ bytes: Bytes
    ) throws(Parsing_Primitives.Parsing.Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output
    where Bytes.Element == UInt8 {
        try Binary.ASCII.Parsing.Whole(parser).call(bytes)
    }

    @inlinable
    public func whole(
        _ string: some StringProtocol
    ) throws(Parsing_Primitives.Parsing.Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output {
        try Binary.ASCII.Parsing.Whole(parser).call(string)
    }
}
