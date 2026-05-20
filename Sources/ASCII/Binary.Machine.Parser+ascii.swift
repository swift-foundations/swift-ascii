// Binary.Machine.Parser+ascii.swift
// Zero-copy ASCII accessor for Machine parsers

public import Binary_Parser_Primitives

extension Binary_Parser_Primitives.Binary.Machine.Parser {
    /// Access to zero-copy ASCII parsing capabilities.
    ///
    /// Provides `whole` and `prefix` methods that use the borrowed path
    /// for zero-copy, zero-allocation parsing (except for Value arena boxing).
    ///
    /// ## Example
    ///
    /// ```swift
    /// let parser = Binary.ASCII.Parsing.Machine.unsignedDecimal(as: UInt32.self)
    /// let value = try parser.ascii.whole("123")
    /// let result = try parser.ascii.prefix("123abc")
    /// ```
    @inlinable
    public var ascii: Binary.ASCII.Parsing.Machine.Access<Output> {
        Binary.ASCII.Parsing.Machine.Access(self)
    }
}
