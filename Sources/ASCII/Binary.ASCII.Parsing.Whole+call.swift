public import Parsing_Primitives
public import Binary_Parsing_Primitives

extension Binary.ASCII.Parsing.Whole {
    /// Parse entire byte array.
    ///
    /// - Parameter bytes: The bytes to parse.
    /// - Returns: The parsed value.
    /// - Throws: Parser failure or `.end(remaining:)` if bytes remain (remaining = bytes, not characters).
    @inlinable
    public func call(_ bytes: [UInt8]) throws(Parsing_Primitives.Parsing.Error.Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output {
        try Binary_Parsing_Primitives.Binary.Bytes.withInput(bytes) { (input: inout Binary_Parsing_Primitives.Binary.Bytes.Input) throws(Parsing_Primitives.Parsing.Error.Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output in
            let value: P.Output
            do throws(P.Failure) {
                value = try parser.parse(&input)
            } catch {
                throw Parsing_Primitives.Parsing.Error.Either<P.Failure, Binary.ASCII.Parsing.Error>.left(error)
            }
            if input.isEmpty {
                return value
            }
            throw Parsing_Primitives.Parsing.Error.Either<P.Failure, Binary.ASCII.Parsing.Error>.right(.end(remaining: input.count))
        }
    }

    /// Parse entire byte collection.
    ///
    /// - Parameter bytes: The byte collection to parse.
    /// - Returns: The parsed value.
    /// - Throws: Parser failure or `.end(remaining:)` if bytes remain (remaining = bytes, not characters).
    @inlinable
    public func call<Bytes: Collection>(
        _ bytes: Bytes
    ) throws(Parsing_Primitives.Parsing.Error.Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output
    where Bytes.Element == UInt8 {
        try call(Array(bytes))
    }

    /// Parse entire string.
    ///
    /// - Parameter string: The string to parse (UTF-8 encoded).
    /// - Returns: The parsed value.
    /// - Throws: Parser failure or `.end(remaining:)` if bytes remain (remaining = UTF-8 code units, not characters).
    @inlinable
    public func call(
        _ string: some StringProtocol
    ) throws(Parsing_Primitives.Parsing.Error.Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output {
        try call(Array(string.utf8))
    }
}
