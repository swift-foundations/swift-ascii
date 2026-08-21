import Testing

@testable import ASCII

@Suite
struct `ASCII Validation Tests` {

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
            let _: [ASCII.Code] = try .init([0x00] as [Byte])
            let _: [ASCII.Code] = try .init([0x7F] as [Byte])
            #expect(throws: ASCII.Code.Error.self) {
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

            let allASCII = (UInt8(0)...UInt8(127)).map(Byte.init)
            let _: [ASCII.Code] = try .init(allASCII)
        }

        @Test
        func `any non-ASCII byte fails validation`() {
            for value in UInt8(128)...UInt8(255) {
                let mixed: [Byte] = [0x41, Byte(value), 0x42]
                #expect(throws: ASCII.Code.Error.self) {
                    let _: [ASCII.Code] = try .init(mixed)
                }
            }
        }
    }
}
