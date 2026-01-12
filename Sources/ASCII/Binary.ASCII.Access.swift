public import Parsing_Primitives
public import Binary_Primitives

extension Binary.ASCII {
    /// Accessor wrapper providing `parser.ascii.whole/prefix` ergonomics.
    public struct Access<P: Parsing_Primitives.Parsing.Parser & Sendable>: Sendable
    where P.Input == Binary_Primitives.Binary.Bytes.Input {
        @usableFromInline
        internal let parser: P

        @inlinable
        internal init(_ parser: P) {
            self.parser = parser
        }
    }
}
