/// ASCII.Code+INCITS_4_1986.swift
/// swift-ascii
///
/// Bridges ASCII.Code (Layer 1) to INCITS 4-1986 case conversion (Layer 3).

extension ASCII.Code {
    /// Converts ASCII letter to specified case via call syntax.
    ///
    /// Enables `byte.ascii(case: .upper)` and `byte.ascii(case: .lower)`.
    ///
    /// Non-letter bytes are returned unchanged.
    @inlinable
    public func callAsFunction(case: Character.Case) -> UInt8 {
        INCITS_4_1986.Case.Conversion.convert(underlying, to: `case`)
    }
}
