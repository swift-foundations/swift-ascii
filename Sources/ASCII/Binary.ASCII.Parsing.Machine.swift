// Binary.ASCII.Parsing.Machine.swift
// Machine-based ASCII parsing infrastructure

public import Binary_Parser_Primitives

extension Binary.ASCII.Parsing {
    /// Namespace for Machine-based ASCII parsers.
    ///
    /// These parsers use the defunctionalized Machine IR for zero-copy,
    /// zero-allocation parsing when combined with `withBorrowed`.
    public enum Machine {}
}
