// INCITS_4_1986.SPACE Tests.swift
// swift-incits-4-1986
//
// Tests for INCITS_4_1986.SPACE character.
//
// Substrate per the ASCII-domain retyping arc (2026-05-19):
// `UInt8.ascii.sp` resolves to `ASCII.Code` (per
// `swift-ascii-primitives/UInt8+ASCII.swift` — `UInt8.ascii` is
// `ASCII.Code.Type`, so `.sp` returns the `ASCII.Code` constant). The
// classification predicates (`isWhitespace`, `isPrintable`, …) live
// directly on `ASCII.Code` per `ASCII.Code+Classification.swift`, so
// the test calls drop the `.ascii` step.

import Testing
@testable import ASCII

@Suite
struct SPACE {
    // MARK: - SPACE Character

    @Suite
    struct `Character Tests` {
        @Test
        func `SPACE constant is 0x20`() {
            #expect(INCITS_4_1986.SPACE.sp == 0x20)
            #expect(UInt8.ascii.sp == 0x20)
        }

        @Test
        func `SPACE is recognized as whitespace`() {
            let sp = UInt8.ascii.sp
            #expect(sp.isWhitespace)
        }

        @Test
        func `SPACE is printable`() {
            let sp = UInt8.ascii.sp
            #expect(sp.isPrintable)
        }

        @Test
        func `SPACE is not a control character`() {
            let sp = UInt8.ascii.sp
            #expect(!sp.isControl)
        }

        @Test
        func `SPACE is not visible (visible = graphic characters only)`() {
            let sp = UInt8.ascii.sp
            #expect(!sp.isVisible, "SPACE is printable but not visible (visible = 0x21-0x7E)")
        }

        @Test
        func `SPACE accessible directly without namespace`() {
            #expect(UInt8.ascii.sp == INCITS_4_1986.SPACE.sp)
        }
    }
}

// MARK: - Performance

//extension `Performance Tests` {
//    @Suite
//    struct `SPACE - Performance` {
//        @Test(.timed(threshold: .milliseconds(2000)))
//        func `SPACE access 1M times`() {
//            for _ in 0..<1_000_000 {
//                _ = UInt8.ascii.sp
//            }
//        }
//
//        @Test(.timed(threshold: .milliseconds(2000)))
//        func `SPACE whitespace check 1M times`() {
//            let sp = UInt8.ascii.sp
//            for _ in 0..<1_000_000 {
//                _ = sp.isWhitespace
//            }
//        }
//    }
//}
