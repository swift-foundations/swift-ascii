public import Parsing_Primitives
public import Binary_Primitives
public import Serialization_Primitives

extension Binary.ASCII.Parsing.Prefix {
    /// Parse prefix of byte array.
    ///
    /// - Parameter bytes: The bytes to parse.
    /// - Returns: The parsed value and count of bytes consumed.
    @inlinable
    public func call(_ bytes: [UInt8]) throws(P.Failure) -> Serialization_Primitives.Serialization.Parsing.Prefix.Result<P.Output> {
        try Binary_Primitives.Binary.Bytes.withInput(bytes) { (input: inout Binary_Primitives.Binary.Bytes.Input) throws(P.Failure) -> Serialization_Primitives.Serialization.Parsing.Prefix.Result<P.Output> in
            let value = try parser.parse(&input)
            return .init(value: value, count: input.consumedCount)
        }
    }

    /// Parse prefix of byte collection.
    ///
    /// - Parameter bytes: The byte collection to parse.
    /// - Returns: The parsed value and count of bytes consumed.
    @inlinable
    public func call<Bytes: Collection>(
        _ bytes: Bytes
    ) throws(P.Failure) -> Serialization_Primitives.Serialization.Parsing.Prefix.Result<P.Output>
    where Bytes.Element == UInt8 {
        try call(Array(bytes))
    }

    /// Parse prefix of string.
    ///
    /// - Parameter string: The string to parse (UTF-8 encoded).
    /// - Returns: The parsed value and count of bytes (UTF-8 code units) consumed.
    @inlinable
    public func call(
        _ string: some StringProtocol
    ) throws(P.Failure) -> Serialization_Primitives.Serialization.Parsing.Prefix.Result<P.Output> {
        try call(Array(string.utf8))
    }
}
