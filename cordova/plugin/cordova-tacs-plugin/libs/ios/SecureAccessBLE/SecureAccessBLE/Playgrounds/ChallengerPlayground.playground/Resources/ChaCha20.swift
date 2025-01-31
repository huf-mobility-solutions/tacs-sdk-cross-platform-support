//
//  ChaCha20.swift
//  CryptoSwift
//
//  Created by Marcin Krzyzanowski on 25/08/14.
//  Copyright (c) 2014 Marcin Krzyzanowski. All rights reserved.
//

import Foundation

public final class ChaCha20 {
    enum Error: ErrorType {
        case MissingContext
    }

    static let blockSize = 64 // 512 / 8
    private let stateSize = 16
    private var context: Context?

    private final class Context {
        var input: [UInt32] = [UInt32](count: 16, repeatedValue: 0)

        deinit {
            for var i = 0; i < input.count; i++ {
                input[i] = 0x00
            }
        }
    }

    public init?(key: [UInt8], iv: [UInt8]) {
        if let c = contextSetup(iv: iv, key: key) {
            context = c
        } else {
            return nil
        }
    }

    public convenience init?(key: String, iv: String) {
        if let kkey = key.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)?.arrayOfBytes(), let iiv = iv.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false)?.arrayOfBytes() {
            self.init(key: kkey, iv: iiv)
        }
        return nil
    }

    public func encrypt(bytes: [UInt8]) throws -> [UInt8] {
        guard context != nil else {
            throw Error.MissingContext
        }

        return try encryptBytes(bytes)
    }

    public func decrypt(bytes: [UInt8]) throws -> [UInt8] {
        return try encrypt(bytes)
    }

    private final func wordToByte(input: [UInt32] /* 64 */ ) -> [UInt8]? /* 16 */ {
        if input.count != stateSize {
            return nil
        }

        var x = input

        var i = 10
        while i > 0 {
            quarterround(&x[0], &x[4], &x[8], &x[12])
            quarterround(&x[1], &x[5], &x[9], &x[13])
            quarterround(&x[2], &x[6], &x[10], &x[14])
            quarterround(&x[3], &x[7], &x[11], &x[15])
            quarterround(&x[0], &x[5], &x[10], &x[15])
            quarterround(&x[1], &x[6], &x[11], &x[12])
            quarterround(&x[2], &x[7], &x[8], &x[13])
            quarterround(&x[3], &x[4], &x[9], &x[14])
            i -= 2
        }

        var output = [UInt8]()
        output.reserveCapacity(16)

        for i in 0 ..< 16 {
            x[i] = x[i] &+ input[i]
            output.appendContentsOf([
                UInt8((x[i] & 0xFFFF_FFFF) >> 24),
                UInt8((x[i] & 0xFFFFFF) >> 16),
                UInt8((x[i] & 0xFFFF) >> 8),
                UInt8((x[i] & 0xFF) >> 0)
            ])
        }

        return output
    }

    private func contextSetup(iv iv: [UInt8], key: [UInt8]) -> Context? {
        let ctx = Context()
        let kbits = key.count * 8

        if kbits != 128, kbits != 256 {
            return nil
        }

        // 4 - 8
        for var i = 0; i < 4; i++ {
            let start = i * 4
            ctx.input[i + 4] = wordNumber(key[start ..< (start + 4)])
        }

        var addPos = 0
        switch kbits {
        case 256:
            addPos += 16
            // sigma
            ctx.input[0] = 0x6170_7865 // apxe
            ctx.input[1] = 0x3320_646E // 3 dn
            ctx.input[2] = 0x7962_2D32 // yb-2
            ctx.input[3] = 0x6B20_6574 // k et
        default:
            // tau
            ctx.input[0] = 0x6170_7865 // apxe
            ctx.input[1] = 0x3620_646E // 6 dn
            ctx.input[2] = 0x7962_2D31 // yb-1
            ctx.input[3] = 0x6B20_6574 // k et
        }

        // 8 - 11
        for var i = 0; i < 4; i++ {
            let start = addPos + (i * 4)

            let bytes = key[start ..< (start + 4)]
            ctx.input[i + 8] = wordNumber(bytes)
        }

        // iv
        ctx.input[12] = 0
        ctx.input[13] = 0
        ctx.input[14] = wordNumber(iv[0 ..< 4])
        ctx.input[15] = wordNumber(iv[4 ..< 8])

        return ctx
    }

    private final func encryptBytes(message: [UInt8]) throws -> [UInt8] {
        guard let ctx = context else {
            throw Error.MissingContext
        }

        var c: [UInt8] = [UInt8](count: message.count, repeatedValue: 0)

        var cPos: Int = 0
        var mPos: Int = 0
        var bytes = message.count

        while true {
            if let output = wordToByte(ctx.input) {
                ctx.input[12] = ctx.input[12] &+ 1
                if ctx.input[12] == 0 {
                    ctx.input[13] = ctx.input[13] &+ 1
                    /* stopping at 2^70 bytes per nonce is user's responsibility */
                }
                if bytes <= ChaCha20.blockSize {
                    for var i = 0; i < bytes; i++ {
                        c[i + cPos] = message[i + mPos] ^ output[i]
                    }
                    return c
                }
                for var i = 0; i < ChaCha20.blockSize; i++ {
                    c[i + cPos] = message[i + mPos] ^ output[i]
                }
                bytes -= ChaCha20.blockSize
                cPos += ChaCha20.blockSize
                mPos += ChaCha20.blockSize
            }
        }
    }

    private final func quarterround(inout a: UInt32, inout _ b: UInt32, inout _ c: UInt32, inout _ d: UInt32) {
        a = a &+ b
        d = rotateLeft(d ^ a, n: 16) // FIXME: WAT? n:

        c = c &+ d
        b = rotateLeft(b ^ c, n: 12)

        a = a &+ b
        d = rotateLeft(d ^ a, n: 8)

        c = c &+ d
        b = rotateLeft(b ^ c, n: 7)
    }
}

// MARK: Helpers

/// Change array to number. It's here because arrayOfBytes is too slow
private func wordNumber(bytes: ArraySlice<UInt8>) -> UInt32 {
    var value: UInt32 = 0
    for (var i: UInt32 = 0, j = bytes.startIndex; i < 4; i++, j++) {
        value = value | UInt32(bytes[j]) << (8 * i)
    }
    return value
}
