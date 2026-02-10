// Binary.ASCII.Parsing.Machine.Access.swift
// Zero-copy accessor wrapper for Machine parsers

public import Binary_Parser_Primitives

extension Binary.ASCII.Parsing.Machine {
    /// Accessor wrapper providing zero-copy `parser.ascii.whole/prefix` ergonomics.
    ///
    /// Unlike `Binary.ASCII.Access` which works with any `Parsing.Parser`,
    /// this wrapper is specialized for `Machine.Parser` and uses the
    /// `withBorrowed` path for zero-copy parsing.
    public struct Access<Output> {
        @usableFromInline
        internal let parser: Binary_Parser_Primitives.Binary.Bytes.Machine.Parser<Output>

        @inlinable
        internal init(_ parser: Binary_Parser_Primitives.Binary.Bytes.Machine.Parser<Output>) {
            self.parser = parser
        }

        /// Access whole-input parsing (requires all input consumed).
        @inlinable
        public var whole: Whole {
            Whole(parser)
        }

        /// Access prefix parsing (allows trailing input).
        @inlinable
        public var prefix: Prefix {
            Prefix(parser)
        }
    }
}
