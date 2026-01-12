public import Parsing_Primitives
public import Binary_Primitives

extension Parsing_Primitives.Parsing.Parser where Self: Sendable, Input == Binary_Primitives.Binary.Bytes.Input {
    /// Access to ASCII parsing capabilities.
    ///
    /// Provides `whole` and `prefix` methods for parsing ASCII strings and bytes.
    /// Uses borrowed fast paths when available for zero-allocation parsing.
    ///
    /// ## Example
    ///
    /// ```swift
    /// let value = try parser.ascii.whole("123")
    /// let result = try parser.ascii.prefix("123abc")
    /// ```
    @inlinable
    public var ascii: Binary.ASCII.Access<Self> {
        Binary.ASCII.Access(self)
    }
}
