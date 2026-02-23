public import Parser_Primitives
public import Binary_Parser_Primitives
public import Memory_Primitives

extension Binary.ASCII.Parsing.Whole {
    /// Parse entire byte array.
    @inlinable
    public func call(_ bytes: [UInt8]) throws(Parser.Error.Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.ParseOutput {
        try Binary_Parser_Primitives.Binary.Bytes.withInput(bytes) { (input: inout Binary_Parser_Primitives.Binary.Bytes.Input) throws(Parser.Error.Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.ParseOutput in
            let value: P.ParseOutput
            do throws(P.Failure) {
                value = try parser.parse(&input)
            } catch {
                throw Parser.Error.Either<P.Failure, Binary.ASCII.Parsing.Error>.left(error)
            }
            if input.isEmpty {
                return value
            }
            throw Parser.Error.Either<P.Failure, Binary.ASCII.Parsing.Error>.right(.end(remaining: input.count))
        }
    }

    /// Parse entire contiguous storage.
    @inlinable
    public func call<C: Memory.Contiguous.`Protocol`>(
        _ source: borrowing C
    ) throws(Parser.Error.Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.ParseOutput
    where C: ~Copyable, C.Element == UInt8 {
        try source.withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<UInt8>) throws(Parser.Error.Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.ParseOutput in
            let bytes: [UInt8] = .init(buffer)
            return try call(bytes)
        }
    }

    /// Parse entire string (UTF-8 encoded).
    @inlinable
    public func call(
        _ string: some StringProtocol
    ) throws(Parser.Error.Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.ParseOutput {
        let bytes: [UInt8] = .init(string.utf8)
        return try call(bytes)
    }
}
