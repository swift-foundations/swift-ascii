# swift-ascii

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

ASCII validation, case conversion, line-ending normalization, and decimal serialization for Swift strings, characters, and integers, built on the INCITS 4-1986 (US-ASCII) specification.

---

## Key Features

- **Validated `String` construction** — `String(ascii:)` builds a string from bytes or `ASCII.Code` values and returns `nil` when any byte falls outside the 7-bit range (0x00–0x7F), instead of decoding it to a replacement character.
- **ASCII-only case conversion** — `string.ascii.uppercased()` / `.lowercased()` fold the letters `A`–`Z` / `a`–`z` and leave every non-ASCII scalar untouched.
- **Line-ending normalization** — `normalized(to:)` rewrites mixed LF, CR, and CRLF endings to one consistent style.
- **7-bit ASCII predicate** — `string.ascii.isAllASCII` reports whether a string contains only US-ASCII characters.
- **Decimal integer serialization** — `Int`, `Int64`, `UInt`, and `UInt64` serialize to their ASCII decimal byte representation through `Binary.Serializable`.
- **INCITS 4-1986 grounding** — classification, case, and format-effector behavior follow the US-ASCII specification.

---

## Quick Start

```swift
import ASCII

// Reject non-ASCII on construction instead of decoding it to replacement characters.
let greeting = String(ascii: [104, 101, 108, 108, 111])  // "hello"
let rejected = String(ascii: [0xFF])                     // nil — 0xFF is not 7-bit ASCII

// Test whether a string is pure 7-bit ASCII.
let pure = "hello".ascii.isAllASCII   // true
let mixed = "café".ascii.isAllASCII   // false

// Fold only ASCII letters; non-ASCII scalars pass through unchanged.
let shout = "HELLO🌍".ascii.lowercased()  // "hello🌍"

// Normalize mixed CR / LF / CRLF line endings to a single style.
let body = "line1\nline2\r\nline3".normalized(to: .crlf)
// "line1\r\nline2\r\nline3"
```

---

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-foundations/swift-ascii.git", branch: "main")
]
```

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "ASCII", package: "swift-ascii")
    ]
)
```

Requires Swift 6.3.1 and macOS 26 / iOS 26 / tvOS 26 / watchOS 26 / visionOS 26.

---

## Community

<!-- BEGIN: discussion -->
*Discussion thread will be created at first public flip.*
<!-- END: discussion -->

## License

Apache 2.0. See [LICENSE](LICENSE.md).
