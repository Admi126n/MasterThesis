package com.admi126n.magisterka

import kotlinx.cinterop.*
import kotlinx.cinterop.refTo
import platform.Foundation.*
import platform.posix.*

actual class IOAndBufferOperator actual constructor() {
    @OptIn(ExperimentalForeignApi::class)
    actual fun read(buf: ByteArray, off: Int, len: Int): Int {
        return read(STDIN_FILENO, buf.refTo(off), len.toULong()).toInt()
    }

    actual fun writeBytes(buf: ByteArray, off: Int, len: Int) {
        val data = buf.copyOfRange(off, off+len).toNSData()
        val handle = NSFileHandle.fileHandleWithStandardOutput()
        handle.writeData(data)
    }
    //https://stackoverflow.com/questions/58521108/how-to-convert-kotlin-bytearray-to-nsdata-and-viceversa
    //https://ronaldvanduren.medium.com/moving-to-kotlin-multiplatform-part-3-4-ea687333a2cb
    @OptIn(ExperimentalForeignApi::class)
    private fun ByteArray.toNSData(): NSData = memScoped {
        NSData.create(bytes = allocArrayOf(this@toNSData), size.toULong())
    }

    @OptIn(ExperimentalForeignApi::class)
    actual fun flush() {
        fflush(stdout)
    }
}