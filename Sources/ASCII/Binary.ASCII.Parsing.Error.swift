public import Binary_Primitives
public import Byte_Primitives
internal import Binary_Parser_Primitives
public import Ordinal_Protocol_Primitives
public import Index_Primitives

extension Binary.ASCII.Parsing {
    /// Error type for ASCII parsing operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Input was not fully consumed.
        ///
        /// - Parameter remaining: Count of bytes (UTF-8 code units) remaining, not characters.
        case end(remaining: Index_Primitives.Index<Byte>.Count)
    }
}
