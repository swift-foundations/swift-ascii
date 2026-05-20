// [UInt8]+INCITS_4_1986 Tests.swift
// swift-incits-4-1986
//
// Tests for byte-array ASCII extension methods.
//
// Substrate per the ASCII-domain retyping arc (2026-05-19): the
// `[UInt8].ascii.X` surface this file originally tested has migrated
// to `[ASCII.Code]` (collection extensions on
// `Collection where Element == ASCII.Code`), and the byte-canonical
// minimize-UInt8 policy (`feedback_byte_canonical_minimize_uint8.md`)
// rules out adding `@_disfavoredOverload [UInt8]` ergonomic forwarders.
// Tests exercise the post-cascade `[ASCII.Code]` surface, bridging to
// `[Byte]` / `[UInt8]` where call sites require it.
//
// File rename to `[ASCII.Code]+INCITS_4_1986 Tests.swift` is OUT OF
// SCOPE per the handoff brief (renames require design discussion); the
// file body has been migrated in place.

import Testing
import ASCII_Test_Support
@testable import ASCII

// File-private helper bridging "is [Byte] all ASCII?" to the
// constructor-lift form. Successful `[ASCII.Code]` lift IS validation.
private func isAllASCII(_ bytes: [Byte]) -> Bool {
    (try? [ASCII.Code](bytes)) != nil
}

@Suite
struct `[UInt8] Tests` {
    @Suite
    struct `[UInt8] - API Surface` {
        @Test
        func `byte array has validation method`() {
            let ascii: [Byte] = [0x48, 0x65, 0x6C, 0x6C, 0x6F]
            #expect(isAllASCII(ascii))

            let nonAscii: [Byte] = [0x48, 0xFF]
            #expect(!isAllASCII(nonAscii))
        }

        @Test
        func `byte array has case conversion method`() {
            let codes: [ASCII.Code] = [.H, .e, .l, .l, .o]  // "Hello"
            let upper = codes.ascii(case: .upper)
            #expect(upper == [.H, .E, .L, .L, .O])  // "HELLO"
        }

        @Test
        func `byte array has line ending conversion`() {
            let lf = [ASCII.Code](ascii: .lf)
            #expect(lf == [.lf])

            let crlf = [ASCII.Code](ascii: .crlf)
            #expect(crlf == [.cr, .lf])
        }

        @Test
        func `byte array has string conversion`() {
            let codes: [ASCII.Code] = [.H, .e, .l, .l, .o]
            #expect([ASCII.Code](ascii: "Hello") == codes)
        }

        @Test
        func `byte array has whitespaces constant`() {
            // `INCITS_4_1986.whitespaces` is `Set<ASCII.Code>` post-cascade;
            // the byte-array-domain accessor lives on
            // `[ASCII.Code].ascii.whitespaces` per
            // `[ASCII.Code]+INCITS_4_1986.ASCII.swift`.
            let ws = [ASCII.Code].ascii.whitespaces
            #expect(ws.contains(.sp))      // Space
            #expect(ws.contains(.htab))    // Tab
            #expect(ws.contains(.lf))      // LF
            #expect(ws.contains(.cr))      // CR
        }
    }
}

//extension `Performance Tests` {
//    @Suite
//    struct `[UInt8] - Performance` {
//        @Test(.timed(threshold: .milliseconds(150)))
//        func `byte array string conversion 10K times`() {
//            for _ in 0..<10000 {
//                _ = [UInt8](ascii: "Hello World!")
//            }
//        }
//
//        @Test(.timed(threshold: .milliseconds(2000)))
//        func `byte array case conversion 10K arrays`() {
//            let bytes: [UInt8] = Array(repeating: 0x41, count: 100)  // "AAA..."
//            for _ in 0..<10000 {
//                _ = bytes.ascii(case: Character.Case.lower)
//            }
//        }
//
//        @Test(
//            .timed(threshold: .milliseconds(10000))
//        )
//        func `byte array validation 10K arrays`() {
//            let bytes: [UInt8] = Array(repeating: 0x41, count: 1000)
//            for _ in 0..<10000 {
//                _ = bytes.ascii.isAllASCII
//            }
//        }
//    }
//}
