public import Parser_Primitives
public import Binary_Parser_Primitives
public import Span_Protocol_Primitives
internal import Memory_Primitives

extension Binary.ASCII.Parsing.Whole {
    /// Parse entire byte array.
    @inlinable
    public func call(_ bytes: [Byte]) throws(Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output {
        try Binary_Parser_Primitives.Binary.withInput(bytes) { (input: inout Byte.Input) throws(Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output in
            let value: P.Output
            do throws(P.Failure) {
                value = try parser.parse(&input)
            } catch {
                throw Either<P.Failure, Binary.ASCII.Parsing.Error>.left(error)
            }
            if input.isEmpty {
                return value
            }
            throw Either<P.Failure, Binary.ASCII.Parsing.Error>.right(.end(remaining: input.count))
        }
    }

    /// Parse entire contiguous storage.
    @inlinable
    public func call<C: Span.`Protocol`>(
        _ source: borrowing C
    ) throws(Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output
    where C: ~Copyable, C.Element == Byte {
        unsafe try source.span.withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<Byte>) throws(Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output in
            let bytes: [Byte] = unsafe .init(buffer)
            return try call(bytes)
        }
    }

    /// Parse entire string (UTF-8 encoded).
    @inlinable
    public func call(
        _ string: some StringProtocol
    ) throws(Either<P.Failure, Binary.ASCII.Parsing.Error>) -> P.Output {
        let bytes: [Byte] = .init(string.utf8)
        return try call(bytes)
    }
}
