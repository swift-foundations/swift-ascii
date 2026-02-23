public import Parser_Primitives
public import Binary_Primitives
public import Serialization_Primitives
public import Memory_Primitives

extension Binary.ASCII.Access where P.ParseOutput: Sendable {
    @inlinable
    public func prefix(_ bytes: [UInt8]) throws(P.Failure) -> Serialization_Primitives.Serialization.Parsing.Prefix.Result<P.ParseOutput, Index<UInt8>.Count> {
        try Binary.ASCII.Parsing.Prefix(parser).call(bytes)
    }

    @inlinable
    public func prefix<C: Memory.Contiguous.`Protocol`>(
        _ source: borrowing C
    ) throws(P.Failure) -> Serialization_Primitives.Serialization.Parsing.Prefix.Result<P.ParseOutput, Index<UInt8>.Count>
    where C: ~Copyable, C.Element == UInt8 {
        try Binary.ASCII.Parsing.Prefix(parser).call(source)
    }

    @inlinable
    public func prefix(
        _ string: some StringProtocol
    ) throws(P.Failure) -> Serialization_Primitives.Serialization.Parsing.Prefix.Result<P.ParseOutput, Index<UInt8>.Count> {
        try Binary.ASCII.Parsing.Prefix(parser).call(string)
    }
}
