public import Parsing_Primitives
public import Binary_Primitives
public import Serialization_Primitives

extension Binary.ASCII.Access where P.Output: Sendable {
    @inlinable
    public func prefix(_ bytes: [UInt8]) throws(P.Failure) -> Serialization_Primitives.Serialization.Parsing.Prefix.Result<P.Output> {
        try Binary.ASCII.Parsing.Prefix(parser).call(bytes)
    }

    @inlinable
    public func prefix<Bytes: Collection>(
        _ bytes: Bytes
    ) throws(P.Failure) -> Serialization_Primitives.Serialization.Parsing.Prefix.Result<P.Output>
    where Bytes.Element == UInt8 {
        try Binary.ASCII.Parsing.Prefix(parser).call(bytes)
    }

    @inlinable
    public func prefix(
        _ string: some StringProtocol
    ) throws(P.Failure) -> Serialization_Primitives.Serialization.Parsing.Prefix.Result<P.Output> {
        try Binary.ASCII.Parsing.Prefix(parser).call(string)
    }
}
