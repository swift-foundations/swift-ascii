public import Parser_Primitives
public import Binary_Parser_Primitives

extension Binary.ASCII {
    /// Accessor wrapper providing `parser.ascii.whole/prefix` ergonomics.
    public struct Access<P: Parser.`Protocol` & Sendable>: Sendable
    where P.Input == Byte.Input {
        @usableFromInline
        internal let parser: P

        @inlinable
        internal init(_ parser: P) {
            self.parser = parser
        }
    }
}
