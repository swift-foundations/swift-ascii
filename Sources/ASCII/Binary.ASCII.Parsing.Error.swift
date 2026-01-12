public import Binary_Primitives

extension Binary.ASCII.Parsing {
    /// Error type for ASCII parsing operations.
    public enum Error: Swift.Error, Sendable, Equatable {
        /// Input was not fully consumed.
        ///
        /// - Parameter remaining: Number of bytes (UTF-8 code units) remaining, not characters.
        case end(remaining: Int)
    }
}
