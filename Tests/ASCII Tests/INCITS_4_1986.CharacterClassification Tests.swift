// INCITS_4_1986.Classification Tests.swift
// swift-incits-4-1986
//
// Tests for authoritative character classification predicates

import Testing
@testable import ASCII

@Suite
struct `INCITS_4_1986.Classification Tests` {
    @Suite
    struct `Whitespace Classification` {
        @Test(arguments: [
            INCITS_4_1986.SPACE.sp,
            INCITS_4_1986.Character.Control.htab,
            INCITS_4_1986.Character.Control.lf,
            INCITS_4_1986.Character.Control.cr,
        ])
        func `recognizes ASCII whitespace characters`(byte: UInt8) {
            #expect(INCITS_4_1986.Classification.isWhitespace(byte))
        }

        @Test(arguments: [
            INCITS_4_1986.Character.Graphic.A,
            INCITS_4_1986.Character.Graphic.`0`,
            INCITS_4_1986.Character.Control.nul,
            INCITS_4_1986.Character.Graphic.exclamationPoint,
        ])
        func `rejects non-whitespace characters`(byte: UInt8) {
            #expect(!INCITS_4_1986.Classification.isWhitespace(byte))
        }
    }

    @Suite
    struct `Control Character Classification` {
        @Test(arguments: Array(INCITS_4_1986.Character.Control.nul...INCITS_4_1986.Character.Control.us))
        func `recognizes control characters 0x00-0x1F`(byte: UInt8) {
            #expect(INCITS_4_1986.Classification.isControl(byte))
        }

        @Test
        func `recognizes DEL as control character`() {
            #expect(INCITS_4_1986.Classification.isControl(INCITS_4_1986.Character.Control.del))
        }

        @Test(arguments: Array(INCITS_4_1986.SPACE.sp...UInt8(0x7E)))
        func `rejects printable characters as control`(byte: UInt8) {
            #expect(!INCITS_4_1986.Classification.isControl(byte))
        }
    }

    @Suite
    struct `Digit Classification` {
        @Test(arguments: Array(INCITS_4_1986.Character.Graphic.`0`...INCITS_4_1986.Character.Graphic.`9`))
        func `recognizes ASCII digits 0-9`(byte: UInt8) {
            #expect(INCITS_4_1986.Classification.isDigit(byte))
        }

        @Test(arguments: [
            INCITS_4_1986.Character.Graphic.A,
            INCITS_4_1986.Character.Graphic.a,
            INCITS_4_1986.SPACE.sp,
            UInt8(0x2F),  // Before '0'
            UInt8(0x3A),  // After '9'
        ])
        func `rejects non-digit characters`(byte: UInt8) {
            #expect(!INCITS_4_1986.Classification.isDigit(byte))
        }
    }

    @Suite
    struct `Letter Classification` {
        @Test(arguments: Array(INCITS_4_1986.Character.Graphic.A...INCITS_4_1986.Character.Graphic.Z))
        func `recognizes uppercase letters A-Z`(byte: UInt8) {
            #expect(INCITS_4_1986.Classification.isLetter(byte))
            #expect(INCITS_4_1986.Classification.isUppercase(byte))
            #expect(!INCITS_4_1986.Classification.isLowercase(byte))
        }

        @Test(arguments: Array(INCITS_4_1986.Character.Graphic.a...INCITS_4_1986.Character.Graphic.z))
        func `recognizes lowercase letters a-z`(byte: UInt8) {
            #expect(INCITS_4_1986.Classification.isLetter(byte))
            #expect(INCITS_4_1986.Classification.isLowercase(byte))
            #expect(!INCITS_4_1986.Classification.isUppercase(byte))
        }

        @Test(arguments: [
            INCITS_4_1986.Character.Graphic.`0`,
            INCITS_4_1986.SPACE.sp,
            INCITS_4_1986.Character.Graphic.exclamationPoint,
            UInt8(0x40),  // Before 'A'
            UInt8(0x5B),  // After 'Z'
            UInt8(0x60),  // Before 'a'
            UInt8(0x7B),  // After 'z'
        ])
        func `rejects non-letter characters`(byte: UInt8) {
            #expect(!INCITS_4_1986.Classification.isLetter(byte))
        }
    }

    @Suite
    struct `Alphanumeric Classification` {
        @Test(
            arguments:
                Array(INCITS_4_1986.Character.Graphic.`0`...INCITS_4_1986.Character.Graphic.`9`)
                + Array(INCITS_4_1986.Character.Graphic.A...INCITS_4_1986.Character.Graphic.Z)
                + Array(INCITS_4_1986.Character.Graphic.a...INCITS_4_1986.Character.Graphic.z)
        )
        func `recognizes alphanumeric characters`(byte: UInt8) {
            #expect(INCITS_4_1986.Classification.isAlphanumeric(byte))
        }

        @Test(arguments: [
            INCITS_4_1986.SPACE.sp,
            INCITS_4_1986.Character.Graphic.exclamationPoint,
            INCITS_4_1986.Character.Control.lf,
            UInt8(0x40),  // @
            UInt8(0x5B),  // [
            UInt8(0x60),  // `
        ])
        func `rejects non-alphanumeric characters`(byte: UInt8) {
            #expect(!INCITS_4_1986.Classification.isAlphanumeric(byte))
        }
    }

    @Suite
    struct `Visible Character Classification` {
        @Test(arguments: Array(INCITS_4_1986.Character.Graphic.exclamationPoint...UInt8(0x7E)))
        func `recognizes visible characters 0x21-0x7E`(byte: UInt8) {
            #expect(INCITS_4_1986.Classification.isVisible(byte))
        }

        @Test
        func `rejects SPACE as visible`() {
            #expect(!INCITS_4_1986.Classification.isVisible(INCITS_4_1986.SPACE.sp))
        }

        @Test(
            arguments: Array(INCITS_4_1986.Character.Control.nul...INCITS_4_1986.Character.Control.us) + [
                INCITS_4_1986.Character.Control.del
            ])
        func `rejects control characters as visible`(byte: UInt8) {
            #expect(!INCITS_4_1986.Classification.isVisible(byte))
        }
    }

    @Suite
    struct `Printable Character Classification` {
        @Test(arguments: Array(INCITS_4_1986.SPACE.sp...UInt8(0x7E)))
        func `recognizes printable characters 0x20-0x7E`(byte: UInt8) {
            #expect(INCITS_4_1986.Classification.isPrintable(byte))
        }

        @Test
        func `includes SPACE as printable`() {
            #expect(INCITS_4_1986.Classification.isPrintable(INCITS_4_1986.SPACE.sp))
        }

        @Test(
            arguments: Array(INCITS_4_1986.Character.Control.nul...INCITS_4_1986.Character.Control.us) + [
                INCITS_4_1986.Character.Control.del
            ])
        func `rejects control characters as printable`(byte: UInt8) {
            #expect(!INCITS_4_1986.Classification.isPrintable(byte))
        }
    }

    @Suite
    struct `Hexadecimal Digit Classification` {
        @Test(arguments: Array(INCITS_4_1986.Character.Graphic.`0`...INCITS_4_1986.Character.Graphic.`9`))
        func `recognizes hex digits 0-9`(byte: UInt8) {
            #expect(INCITS_4_1986.Classification.isHexDigit(byte))
        }

        @Test(arguments: Array(INCITS_4_1986.Character.Graphic.A...INCITS_4_1986.Character.Graphic.F))
        func `recognizes hex digits A-F`(byte: UInt8) {
            #expect(INCITS_4_1986.Classification.isHexDigit(byte))
        }

        @Test(arguments: Array(INCITS_4_1986.Character.Graphic.a...INCITS_4_1986.Character.Graphic.f))
        func `recognizes hex digits a-f`(byte: UInt8) {
            #expect(INCITS_4_1986.Classification.isHexDigit(byte))
        }

        @Test(arguments: [
            INCITS_4_1986.Character.Graphic.G,
            INCITS_4_1986.Character.Graphic.g,
            INCITS_4_1986.Character.Graphic.Z,
            INCITS_4_1986.Character.Graphic.z,
            INCITS_4_1986.SPACE.sp,
        ])
        func `rejects non-hex characters`(byte: UInt8) {
            #expect(!INCITS_4_1986.Classification.isHexDigit(byte))
        }
    }

    @Suite
    struct `Mutual Exclusivity` {
        @Test
        func `control and printable are mutually exclusive`() {
            for byte in UInt8(0)...UInt8(127) {
                let isControl = INCITS_4_1986.Classification.isControl(byte)
                let isPrintable = INCITS_4_1986.Classification.isPrintable(byte)
                #expect(isControl != isPrintable, "Byte \(byte) should be either control or printable, not both")
            }
        }

        @Test
        func `every ASCII byte is either control or printable`() {
            for byte in UInt8(0)...UInt8(127) {
                let isControl = INCITS_4_1986.Classification.isControl(byte)
                let isPrintable = INCITS_4_1986.Classification.isPrintable(byte)
                #expect(isControl || isPrintable, "Byte \(byte) must be either control or printable")
            }
        }

        @Test
        func `uppercase and lowercase are mutually exclusive`() {
            for byte in UInt8(0)...UInt8(127) {
                let isUpper = INCITS_4_1986.Classification.isUppercase(byte)
                let isLower = INCITS_4_1986.Classification.isLowercase(byte)
                #expect(!(isUpper && isLower), "Byte \(byte) cannot be both uppercase and lowercase")
            }
        }

        @Test
        func `letter implies alphanumeric`() {
            for byte in UInt8(0)...UInt8(127) {
                if INCITS_4_1986.Classification.isLetter(byte) {
                    #expect(INCITS_4_1986.Classification.isAlphanumeric(byte))
                }
            }
        }

        @Test
        func `digit implies alphanumeric`() {
            for byte in UInt8(0)...UInt8(127) {
                if INCITS_4_1986.Classification.isDigit(byte) {
                    #expect(INCITS_4_1986.Classification.isAlphanumeric(byte))
                }
            }
        }
    }

    @Suite
    struct `Boundary Conditions` {
        @Test
        func `digit boundaries are precise`() {
            #expect(!INCITS_4_1986.Classification.isDigit(UInt8(0x2F)))  // Before '0'
            #expect(INCITS_4_1986.Classification.isDigit(UInt8(0x30)))  // '0'
            #expect(INCITS_4_1986.Classification.isDigit(UInt8(0x39)))  // '9'
            #expect(!INCITS_4_1986.Classification.isDigit(UInt8(0x3A)))  // After '9'
        }

        @Test
        func `letter boundaries are precise`() {
            #expect(!INCITS_4_1986.Classification.isLetter(UInt8(0x40)))  // Before 'A'
            #expect(INCITS_4_1986.Classification.isLetter(UInt8(0x41)))  // 'A'
            #expect(INCITS_4_1986.Classification.isLetter(UInt8(0x5A)))  // 'Z'
            #expect(!INCITS_4_1986.Classification.isLetter(UInt8(0x5B)))  // After 'Z'
            #expect(!INCITS_4_1986.Classification.isLetter(UInt8(0x60)))  // Before 'a'
            #expect(INCITS_4_1986.Classification.isLetter(UInt8(0x61)))  // 'a'
            #expect(INCITS_4_1986.Classification.isLetter(UInt8(0x7A)))  // 'z'
            #expect(!INCITS_4_1986.Classification.isLetter(UInt8(0x7B)))  // After 'z'
        }

        @Test
        func `visible boundaries are precise`() {
            #expect(!INCITS_4_1986.Classification.isVisible(UInt8(0x20)))  // SPACE
            #expect(INCITS_4_1986.Classification.isVisible(UInt8(0x21)))  // !
            #expect(INCITS_4_1986.Classification.isVisible(UInt8(0x7E)))  // ~
            #expect(!INCITS_4_1986.Classification.isVisible(UInt8(0x7F)))  // DEL
        }

        @Test
        func `printable boundaries are precise`() {
            #expect(!INCITS_4_1986.Classification.isPrintable(UInt8(0x1F)))  // Before SPACE
            #expect(INCITS_4_1986.Classification.isPrintable(UInt8(0x20)))  // SPACE
            #expect(INCITS_4_1986.Classification.isPrintable(UInt8(0x7E)))  // ~
            #expect(!INCITS_4_1986.Classification.isPrintable(UInt8(0x7F)))  // DEL
        }
    }
}
