public import Parser_Primitives
public import Binary_Parser_Primitives
internal import Memory_Primitives

extension Binary.ASCII.Parsing.Prefix {
    /// Parse prefix of byte array.
    @inlinable
    public func call(_ bytes: [UInt8]) throws(P.Failure) -> (value: P.Output, count: Index<Byte>.Count) {
        try Binary_Parser_Primitives.Binary.Bytes.withInput(bytes) { (input: inout Byte.Input) throws(P.Failure) -> (value: P.Output, count: Index<Byte>.Count) in
            let value = try parser.parse(&input)
            return (value: value, count: input.consumed.retag(Byte.self))
        }
    }

    /// Parse prefix of contiguous storage.
    @inlinable
    public func call<C: Memory.Contiguous.`Protocol`>(
        _ source: borrowing C
    ) throws(P.Failure) -> (value: P.Output, count: Index<Byte>.Count)
    where C: ~Copyable, C.Element == UInt8 {
        unsafe try source.withUnsafeBufferPointer { (buffer: UnsafeBufferPointer<UInt8>) throws(P.Failure) -> (value: P.Output, count: Index<Byte>.Count) in
            let bytes: [UInt8] = unsafe .init(buffer)
            return try call(bytes)
        }
    }

    /// Parse prefix of string (UTF-8 encoded).
    @inlinable
    public func call(
        _ string: some StringProtocol
    ) throws(P.Failure) -> (value: P.Output, count: Index<Byte>.Count) {
        let bytes: [UInt8] = .init(string.utf8)
        return try call(bytes)
    }
}
