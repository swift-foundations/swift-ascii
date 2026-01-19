// Binary.ASCII.Parsing.Machine.Access.Whole.swift
// Zero-copy whole-input parsing wrapper for Machine parsers

public import Binary_Parsing_Primitives

extension Binary.ASCII.Parsing.Machine.Access {
    /// Whole-input parsing capability for Machine parsers.
    ///
    /// Enforces that all input must be consumed by appending an `.end` check
    /// to the parser program. Uses `withBorrowed` for zero-copy execution.
    ///
    /// The "with end" parser is pre-built at construction time, not on each call.
    public struct Whole {
        /// The parser with `.end` appended.
        @usableFromInline
        internal let wholeParser: Binary_Parsing_Primitives.Binary.Bytes.Machine.Parser<Output>

        @inlinable
        internal init(_ parser: Binary_Parsing_Primitives.Binary.Bytes.Machine.Parser<Output>) {
            // Pre-build parser with .end check
            self.wholeParser = Binary_Parsing_Primitives.Binary.Bytes.Machine.build { builder in
                let inner = builder.embed(parser)
                let end = Binary_Parsing_Primitives.Binary.Bytes.Machine.end(in: &builder)
                return Binary_Parsing_Primitives.Binary.Bytes.Machine.sequence(
                    inner,
                    end,
                    combine: { value, _ in value },
                    in: &builder
                )
            }
        }
    }
}

extension Binary.ASCII.Parsing.Machine.Access.Whole {
    /// Parse entire byte array.
    ///
    /// Uses zero-copy borrowed path. Fails if any bytes remain after parsing.
    ///
    /// - Parameter bytes: The bytes to parse.
    /// - Returns: The parsed value.
    /// - Throws: `Machine.Fault` if parsing fails or input remains.
    @inlinable
    public func call(_ bytes: [UInt8]) throws(Binary_Parsing_Primitives.Binary.Bytes.Machine.Fault) -> Output {
        try Binary_Parsing_Primitives.Binary.Bytes.withBorrowed(bytes, wholeParser)
    }

    /// Parse entire string (UTF-8).
    ///
    /// Uses zero-copy borrowed path. Fails if any bytes remain after parsing.
    ///
    /// - Parameter string: The string to parse.
    /// - Returns: The parsed value.
    /// - Throws: `Machine.Fault` if parsing fails or input remains.
    @inlinable
    public func call(_ string: some StringProtocol) throws(Binary_Parsing_Primitives.Binary.Bytes.Machine.Fault) -> Output {
        try call(Array(string.utf8))
    }
}
