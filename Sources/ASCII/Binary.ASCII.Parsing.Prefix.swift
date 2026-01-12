public import Parsing_Primitives
public import Binary_Primitives
public import Serialization_Primitives

extension Binary.ASCII.Parsing {
    /// Capability wrapper for prefix ASCII parsing.
    ///
    /// Wraps a parser and provides `call` methods that parse a prefix,
    /// returning value and count consumed.
    public struct Prefix<P: Parsing_Primitives.Parsing.Parser & Sendable>: Sendable
    where P.Input == Binary_Primitives.Binary.Bytes.Input, P.Output: Sendable {
        @usableFromInline
        internal let parser: P

        @inlinable
        public init(_ parser: P) {
            self.parser = parser
        }
    }
}
