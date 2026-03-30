// Character+INCITS_4_1986.swift
// swift-ascii
//
// INCITS 4-1986: US-ASCII character classification
// Core Character.ASCII type and classification moved to ASCII Primitives (L1).

extension Character {
    /// Character case style for ASCII case conversion
    ///
    /// Typealias to `INCITS_4_1986.Case` for ASCII case transformations per INCITS 4-1986.
    /// Only affects ASCII letters ('A'...'Z', 'a'...'z').
    public typealias Case = INCITS_4_1986.Case
}
