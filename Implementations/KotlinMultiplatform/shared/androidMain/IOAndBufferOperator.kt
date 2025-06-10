package com.admi126n.magisterka

actual class IOAndBufferOperator actual constructor() {
    actual fun read(buf: ByteArray, off: Int, len: Int): Int {
        return System.`in`.read(buf, off, len)
    }

    actual fun writeBytes(buf: ByteArray, off: Int, len: Int) {
        System.out.write(buf, off, len)
    }

    actual fun flush() {
        System.out.flush()
    }
}