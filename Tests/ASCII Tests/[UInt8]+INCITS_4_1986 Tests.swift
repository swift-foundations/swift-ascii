import ASCII_Test_Support
import Testing

@testable import ASCII

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
            let codes: [ASCII.Code] = [.H, .e, .l, .l, .o]
            let upper = codes.ascii(case: .upper)
            #expect(upper == [.H, .E, .L, .L, .O])
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

            let ws = [ASCII.Code].ascii.whitespaces
            #expect(ws.contains(.sp))
            #expect(ws.contains(.htab))
            #expect(ws.contains(.lf))
            #expect(ws.contains(.cr))
        }
    }
}
