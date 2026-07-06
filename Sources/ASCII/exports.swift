// exports.swift
// swift-ascii
//
// ASCII serialization and parsing utilities built on INCITS 4-1986 (US-ASCII).

@_exported public import Binary_Primitives
@_exported public import Binary_Serializable_Primitives
@_exported public import INCITS_4_1986
// Deliberately link-only (NOT @_exported): re-exporting Parser_Primitives
// leaks Collection_Primitives' `struct Collection` (via
// Parser_Remaining_Primitives), shadowing stdlib `Collection` in every
// ASCII consumer, and floods consumers with parser surface (2026-07-03
// sweep incident, reverted in 13725b5 — do NOT let `swiftlint --fix`
// flip this line back). Carve-out escalated to the linter arc.
// swiftlint:disable:next exports_swift_strict_shape
internal import Parser_Primitives
