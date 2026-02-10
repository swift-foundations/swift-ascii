public import Parser_Primitives
public import Binary_Parser_Primitives

extension Binary.ASCII.Parsing {
    /// Capability wrapper for whole-input ASCII parsing.
    ///
    /// Wraps a parser and provides `call` methods that parse entire input,
    /// failing if any bytes remain. Uses borrowed fast paths when available.
    public struct Whole<P: Parser.`Protocol` & Sendable>: Sendable
    where P.Input == Binary_Parser_Primitives.Binary.Bytes.Input {
        @usableFromInline
        internal let parser: P

        @inlinable
        public init(_ parser: P) {
            self.parser = parser
        }
    }
}
