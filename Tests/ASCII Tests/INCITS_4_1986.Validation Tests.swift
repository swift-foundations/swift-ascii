// INCITS_4_1986.Validation Tests.swift
// swift-incits-4-1986
//
// Tests for ASCII validation expressed through the typed-throws
// constructor `ASCII.Code(_ byte: Byte) throws(ASCII.Code.Error)`.
// The type system witnesses correctness: a successful `[ASCII.Code]`
// lift from `[Byte]` IS the "all bytes are valid ASCII" predicate.

import Testing
@testable import ASCII

@Suite
struct `ASCII Validation Tests` {
    // MARK: - ASCII Validation

    @Suite
    struct `Correctness Tests` {
        @Test
        func `Valid ASCII bytes`() throws {
            let bytes: [Byte] = [0x00, 0x41, 0x7F]
            let _: [ASCII.Code] = try .init(bytes)
        }

        @Test
        func `Invalid ASCII bytes`() {
            let bytes: [Byte] = [0x41, 0x80, 0xFF]
            #expect(throws: ASCII.Code.Error.self) {
                let _: [ASCII.Code] = try .init(bytes)
            }
        }

        @Test
        func `Empty array is valid ASCII`() throws {
            let codes: [ASCII.Code] = try .init([] as [Byte])
            #expect(codes.isEmpty)
        }

        @Test
        func `Boundary values`() throws {
            let _: [ASCII.Code] = try .init([0x00] as [Byte])     // Minimum ASCII
            let _: [ASCII.Code] = try .init([0x7F] as [Byte])     // Maximum ASCII
            #expect(throws: ASCII.Code.Error.self) {              // Just above ASCII range
                let _: [ASCII.Code] = try .init([0x80] as [Byte])
            }
        }
    }

    @Suite
    struct `Boundary Values Tests` {
        @Test(arguments: [0x00, 0x01, 0x7E, 0x7F] as [Byte])
        func `valid ASCII bytes`(byte: Byte) throws {
            let _: ASCII.Code = try ASCII.Code(byte)
        }

        @Test(arguments: [0x80, 0x81, 0xFE, 0xFF] as [Byte])
        func `invalid ASCII bytes`(byte: Byte) {
            #expect(throws: ASCII.Code.Error.notASCII(byte: byte)) {
                let _: ASCII.Code = try ASCII.Code(byte)
            }
        }

        @Test
        func `all valid ASCII bytes pass validation`() throws {
            // Byte is not Strideable per [API-BYTE-002]; iterate on UInt8
            // with per-element Byte bridge at the lift site.
            let allASCII = (UInt8(0)...UInt8(127)).map(Byte.init)
            let _: [ASCII.Code] = try .init(allASCII)
        }

        @Test
        func `any non-ASCII byte fails validation`() {
            for value in UInt8(128)...UInt8(255) {
                let mixed: [Byte] = [0x41, Byte(value), 0x42]  // A, byte, B
                #expect(throws: ASCII.Code.Error.self) {
                    let _: [ASCII.Code] = try .init(mixed)
                }
            }
        }
    }
}

// MARK: - Performance

//extension `Performance Tests` {
//    @Suite
//    struct `ASCII Validation - Performance` {
//        @Test(.timed(threshold: .milliseconds(2000)))
//        func `validate 1M ASCII bytes`() throws {
//            let ascii: [Byte] = Array(repeating: 0x41, count: 1_000_000)
//            let _: [ASCII.Code] = try .init(ascii)
//        }
//
//        @Test(.timed(threshold: .milliseconds(150)))
//        func `validate 1M mixed bytes - early exit`() {
//            var bytes: [Byte] = Array(repeating: 0x41, count: 1_000_000)
//            bytes[100] = 0x80  // Non-ASCII early in array
//            #expect(throws: ASCII.Code.Error.self) {
//                let _: [ASCII.Code] = try .init(bytes)
//            }
//        }
//
//        @Test(.timed(threshold: .milliseconds(2000)))
//        func `validate 1M mixed bytes - late exit`() {
//            var bytes: [Byte] = Array(repeating: 0x41, count: 1_000_000)
//            bytes[999_999] = 0x80  // Non-ASCII at end
//            #expect(throws: ASCII.Code.Error.self) {
//                let _: [ASCII.Code] = try .init(bytes)
//            }
//        }
//    }
//}
