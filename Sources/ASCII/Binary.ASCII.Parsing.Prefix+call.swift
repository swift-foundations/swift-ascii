public import Parser_Primitives
public import Binary_Parser_Primitives
public import Span_Protocol_Primitives
internal import Memory_Primitives

extension Binary.ASCII.Parsing.Prefix {
    /// Parse prefix of byte array.
    @inlinable
    public func call(_ bytes: [Byte]) throws(P.Failure) -> (value: P.Output, count: Index<Byte>.Count) {
        try Binary_Parser_Primitives.Binary.withInput(bytes) { (input: inout Byte.Input) throws(P.Failure) -> (value: P.Output, count: Index<Byte>.Count) in
            let value = try parser.parse(&input)
            return (value: value, count: input.consumed)
        }
    }

    /// Parse prefix of contiguous storage.
    @inlinable
    public func call<C: Span.`Protocol`>(
        _ source: borrowing C
    ) throws(P.Failure) -> (value: P.Output, count: Index<Byte>.Count)
    where C: ~Copyable, C.Element == Byte {
        unsafe try source.span.withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<Byte>) throws(P.Failure) -> (value: P.Output, count: Index<Byte>.Count) in
            let bytes: [Byte] = unsafe .init(buffer)
            return try call(bytes)
        }
    }

    /// Parse prefix of string (UTF-8 encoded).
    @inlinable
    public func call(
        _ string: some StringProtocol
    ) throws(P.Failure) -> (value: P.Output, count: Index<Byte>.Count) {
        let bytes: [Byte] = .init(string.utf8)
        return try call(bytes)
    }
}
