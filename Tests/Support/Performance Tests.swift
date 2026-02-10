// Performance Tests.swift
// swift-incits-4-1986
//
// Top-level performance test suite with serialized execution.
// All performance tests extend this suite via extension in their respective test files.

import Testing

@MainActor
@Suite(
    .serialized
)
package struct `Performance Tests` {}
