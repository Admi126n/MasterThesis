package com.admi126n.magisterka

class Fasta {

    data class AminoAcid(var prob: Double, var char: Byte)

    val IM = 139968
    val IA = 3877
    val IC = 29573

    val LINE_LENGTH = 60
    val BUFFER_SIZE = (LINE_LENGTH + 1) * 1024 // add 1 for '\n'
    val operator = IOAndBufferOperator()
    var last = 42

    // Weighted selection from alphabet
    var ALU = (
            "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG"
                    + "GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA"
                    + "CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT"
                    + "ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA"
                    + "GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG"
                    + "AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC"
                    + "AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA")

    private val IUB = arrayOf(
        AminoAcid(0.27, 97), // "a"),
        AminoAcid(0.12, 99), // "c"),
        AminoAcid(0.12, 103), // "g"),
        AminoAcid(0.27, 116), // "t"),
        AminoAcid(0.02, 66), // "B"),
        AminoAcid(0.02, 68), // "D"),
        AminoAcid(0.02, 72), // "H"),
        AminoAcid(0.02, 75), // "K"),
        AminoAcid(0.02, 77), // "M"),
        AminoAcid(0.02, 78), // "N"),
        AminoAcid(0.02, 82), // "R"),
        AminoAcid(0.02, 83), // "S"),
        AminoAcid(0.02, 86), // "V"),
        AminoAcid(0.02, 87), // "W"),
        AminoAcid(0.02, 89), // "Y"),
    )

    private val HOMO_SAPIENS = arrayOf(
        AminoAcid(0.3029549426680, 97), // "a"),
        AminoAcid(0.1979883004921, 99), // "c"),
        AminoAcid(0.1975473066391, 103), // "g"),
        AminoAcid(0.3015094502008, 116), // "t"),
    )

    fun accumulateProbabilities( acids: Array<AminoAcid>) {
        for (i in 1 until acids.size) {
            acids[i].prob += acids[i-1].prob
        }
    }

    fun makeRandomFasta(
        id: String, desc: String,
        acids: Array<AminoAcid>, nChars: Int
    ) {
        accumulateProbabilities(acids)
        var nChars = nChars
        val buffer = ByteArray(BUFFER_SIZE)

        // Write the id and description to standard out
        val descStr = ">" + id + " " + desc + '\n'.toString()
        var descByteArray = descStr.encodeToByteArray()
        operator.writeBytes(descByteArray, 0, descByteArray.size)

        var bufferIndex = 0
        while (nChars > 0) {
            val chunkSize: Int
            if (nChars >= LINE_LENGTH) {
                chunkSize = LINE_LENGTH
            } else {
                chunkSize = nChars
            }

            if (bufferIndex == BUFFER_SIZE) {
                operator.writeBytes(buffer, 0, bufferIndex)
                bufferIndex = 0
            }

            for (rIndex in 0 until chunkSize) {
                val r = random(1.0f).toDouble()
                buffer[bufferIndex++] = binarySearch(r, acids)
            }

            buffer[bufferIndex++] = '\n'.code.toByte()

            nChars -= chunkSize
        }

        operator.writeBytes(buffer, 0, bufferIndex)
    }

    fun makeRepeatFasta(
        id: String, desc: String, alu: String,
        nChars: Int
    ) {
        var nChars = nChars
        val aluBytes = alu.encodeToByteArray()
        var aluIndex = 0

        val buffer = ByteArray(BUFFER_SIZE)

        // Write the id and description to standard out
        val descStr = ">" + id + " " + desc + '\n'.toString()
        var descByteArray = descStr.encodeToByteArray()
        operator.writeBytes(descByteArray, 0, descByteArray.size)

        var bufferIndex = 0
        while (nChars > 0) {
            val chunkSize: Int
            if (nChars >= LINE_LENGTH) {
                chunkSize = LINE_LENGTH
            } else {
                chunkSize = nChars
            }

            if (bufferIndex == BUFFER_SIZE) {
                operator.writeBytes(buffer, 0, bufferIndex)
                bufferIndex = 0
            }

            for (i in 0 until chunkSize) {
                if (aluIndex == aluBytes.size) {
                    aluIndex = 0
                }

                buffer[bufferIndex++] = aluBytes[aluIndex++]
            }
            buffer[bufferIndex++] = '\n'.code.toByte()

            nChars -= chunkSize
        }

        operator.writeBytes(buffer, 0, bufferIndex)
    }

    // pseudo-random number generator
    fun random(max: Float): Float {
        val oneOverIM = 1.0f / IM
        last = (last * IA + IC) % IM
        return max * last.toFloat() * oneOverIM
    }

    fun binarySearch(rnd: Double, acids: Array<AminoAcid>): Byte {
        var low = 0
        var high = acids.size - 1
        while (low <= high) {
            val mid = low + (high - low) / 2
            if (acids[mid].prob >= rnd) {
                high = mid - 1
            } else {
                low = mid + 1
            }
        }
        return acids[high + 1].char

    }

    fun runBenchmark(n: Int) {
        makeRepeatFasta("ONE", "Homo sapiens alu", ALU, n * 2)
        makeRandomFasta("TWO", "IUB ambiguity codes", IUB, n * 3)
        makeRandomFasta("THREE", "Homo sapiens frequency", HOMO_SAPIENS, n * 5)
    }
}