package com.admi126n.magisterka

expect class IOAndBufferOperator() {
    fun read(buf: ByteArray, off: Int, len: Int): Int
    fun writeBytes(buf: ByteArray, off: Int, len:Int)
    fun flush()
}