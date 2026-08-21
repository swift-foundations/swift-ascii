import Testing

@testable import ASCII

@Suite
struct `StringOperator Tests` {
    @Suite
    struct `String Trimming - Correctness` {
        @Test
        func `trim leading whitespace`() {
            #expect("  hello".trimming(Set<Character>.ascii.whitespaces) == "hello")
            #expect("\t\nhello".trimming(Set<Character>.ascii.whitespaces) == "hello")
        }

        @Test
        func `trim trailing whitespace`() {
            #expect("hello  ".trimming(Set<Character>.ascii.whitespaces) == "hello")
            #expect("hello\t\n".trimming(Set<Character>.ascii.whitespaces) == "hello")
        }

        @Test
        func `trim both ends`() {
            #expect("  hello  ".trimming(.ascii.whitespaces) == "hello")

            #expect("\t\nhello\r\n".trimming(where: Set<Character>.ascii.isWhitespace) == "hello")
        }

        @Test
        func `preserve internal whitespace`() {
            #expect("  hello world  ".trimming(Set<Character>.ascii.whitespaces) == "hello world")
        }

        @Test
        func `empty string unchanged`() {
            #expect("".trimming(Set<Character>.ascii.whitespaces).isEmpty)
        }

        @Test
        func `all whitespace becomes empty`() {
            #expect("   \t\n\r   ".trimming(Set<Character>.ascii.whitespaces).isEmpty)
        }

        @Test
        func `trim custom character set`() {
            #expect("***text***".trimming(["*"]) == "text")
            #expect("abcHELLOcba".trimming(["a", "b", "c"]) == "HELLO")
        }
    }

    @Suite
    struct `Substring Trimming - Correctness` {
        @Test
        func `trim substring`() {
            let str = "  hello  "
            let sub = str[...]
            #expect(sub.trimming(Set<Character>.ascii.whitespaces) == "hello")
        }
    }
}
