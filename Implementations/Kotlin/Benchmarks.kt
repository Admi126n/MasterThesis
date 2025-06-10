package com.example.kotlinapp

import android.util.Log
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.material3.Button
import androidx.compose.material3.ButtonDefaults
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import kotlin.math.min
import kotlin.math.roundToInt
import kotlin.math.sqrt

@Composable
fun BenchmarksView(numberOfTests: Int, fannkuchRedux: Int, fasta: Int, nBody: Int, reverseComplement: Int) {
    Column(Modifier.fillMaxWidth(), horizontalAlignment = Alignment.CenterHorizontally) {
        Button(
            onClick = {
                val fr = FannkuchRedux()

                for (i in (0..<numberOfTests)) {
                    val start = System.nanoTime()
                    fr.runBenchmark(fannkuchRedux)
                    val end = System.nanoTime()

                    Log.d(
                        "FANNKUCH TIME",
                        "(${i + 1}/$numberOfTests) FannkuchRedux; ${end - start} [ns]"
                    )
                }
            },
            colors = ButtonDefaults.buttonColors(containerColor = Color.Red)
        ) {
            Text("Run FannkuchRedux")
        }

        Button(
            onClick = {
                val f = Fasta()

                for (i in (0..<numberOfTests)) {
                    val start = System.nanoTime()
                    f.runBenchmark(fasta)
                    val end = System.nanoTime()

                    Log.d("FASTA TIME", "(${i + 1}/$numberOfTests) Fasta; ${end - start} [ns]")
                }
            },
            colors = ButtonDefaults.buttonColors(containerColor = Color.Red)
        ) {
            Text("Run Fasta")
        }

        Button(
            onClick = {
                val n = NBody()

                for (i in (0..<numberOfTests)) {
                    val start = System.nanoTime()
                    n.runBenchmark(nBody)
                    val end = System.nanoTime()

                    Log.d("NBODY TIME", "(${i + 1}/$numberOfTests) NBody; ${end - start} [ns]")
                }
            },
            colors = ButtonDefaults.buttonColors(containerColor = Color.Red)
        ) {
            Text("Run NBody")
        }

        Button(
            onClick = {
                val r = ReverseComplement()

                for (i in (0..<numberOfTests)) {
                    val start = System.nanoTime()
                    r.runBenchmark(reverseComplement)
                    val end = System.nanoTime()

                    Log.d(
                        "REVERSECOMPLEMENT TIME",
                        "(${i + 1}/$numberOfTests) ReverseComplement; ${end - start} [ns]"
                    )
                }
            },
            colors = ButtonDefaults.buttonColors(containerColor = Color.Red)
        ) {
            Text("Run ReverseComplement")
        }
    }
}

class FannkuchRedux {
    fun fannkuch(n: Int): Int {
        val perm = IntArray(n)
        val perm1 = IntArray(n)
        val count = IntArray(n)
        var maxFlipsCount = 0
        var permCount = 0
        var checksum = 0

        for (j in 0 until n) perm1[j] = j
        var r = n

        while (true) {

            while (r != 1) {
                count[r - 1] = r
                r--
            }

            for (j in 0 until n) perm[j] = perm1[j]
            var flipsCount = 0
            var k: Int = perm[0]

            //Perform the left rotations
            while (k != 0) {
                val k2 = k + 1 shr 1
                for (i in 0 until k2) {
                    val temp = perm[i]
                    perm[i] = perm[k - i]
                    perm[k - i] = temp
                }
                k = perm[0]
                flipsCount++
            }

            maxFlipsCount = maxOf(maxFlipsCount, flipsCount)
            checksum += if (permCount % 2 == 0) flipsCount else -flipsCount

            // Use incremental change to generate another permutation
            while (true) {
                if (r == n) {
                    return maxFlipsCount
                }
                val perm0 = perm1[0]
                var i = 0
                while (i < r) {
                    val j = i + 1
                    perm1[i] = perm1[j]
                    i = j
                }
                perm1[r] = perm0

                count[r] = count[r] - 1
                if (count[r] > 0) break
                r++
            }

            permCount++
        }
    }

    fun runBenchmark(n: Int) {
        fannkuch(n)
    }
}

class Fasta {
    data class AminoAcid(var prob: Double, var char: Byte)

    val IM = 139968
    val IA = 3877
    val IC = 29573

    val LINE_LENGTH = 60
    val BUFFER_SIZE = (LINE_LENGTH + 1) * 1024 // add 1 for '\n'
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
        System.out.write(descByteArray, 0, descByteArray.size)

        var bufferIndex = 0
        while (nChars > 0) {
            val chunkSize: Int
            if (nChars >= LINE_LENGTH) {
                chunkSize = LINE_LENGTH
            } else {
                chunkSize = nChars
            }

            if (bufferIndex == BUFFER_SIZE) {
                System.out.write(buffer, 0, bufferIndex)
                bufferIndex = 0
            }

            for (rIndex in 0 until chunkSize) {
                val r = random(1.0f).toDouble()
                buffer[bufferIndex++] = binarySearch(r, acids)
            }

            buffer[bufferIndex++] = '\n'.code.toByte()

            nChars -= chunkSize
        }

        System.out.write(buffer, 0, bufferIndex)
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
        val descStr = ">$id $desc\n"
        var descByteArray = descStr.encodeToByteArray()
        System.out.write(descByteArray, 0, descByteArray.size)

        var bufferIndex = 0
        while (nChars > 0) {
            val chunkSize: Int
            if (nChars >= LINE_LENGTH) {
                chunkSize = LINE_LENGTH
            } else {
                chunkSize = nChars
            }

            if (bufferIndex == BUFFER_SIZE) {
                System.out.write(buffer, 0, bufferIndex)
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

        System.out.write(buffer, 0, bufferIndex)
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

internal class Body {

    var x: Double = 0.0
    var y: Double = 0.0
    var z: Double = 0.0
    var vx: Double = 0.0
    var vy: Double = 0.0
    var vz: Double = 0.0
    var mass: Double = 0.0

    fun offsetMomentum(px: Double, py: Double, pz: Double): Body {
        vx = -px / SOLAR_MASS
        vy = -py / SOLAR_MASS
        vz = -pz / SOLAR_MASS
        return this
    }

    companion object {
        val PI = 3.141592653589793
        val SOLAR_MASS = 4.0 * PI * PI
        val DAYS_PER_YEAR = 365.24

        fun jupiter(): Body {
            val p = Body()
            p.x = 4.84143144246472090e+00
            p.y = -1.16032004402742839e+00
            p.z = -1.03622044471123109e-01
            p.vx = 1.66007664274403694e-03 * DAYS_PER_YEAR
            p.vy = 7.69901118419740425e-03 * DAYS_PER_YEAR
            p.vz = -6.90460016972063023e-05 * DAYS_PER_YEAR
            p.mass = 9.54791938424326609e-04 * SOLAR_MASS
            return p
        }

        fun saturn(): Body {
            val p = Body()
            p.x = 8.34336671824457987e+00
            p.y = 4.12479856412430479e+00
            p.z = -4.03523417114321381e-01
            p.vx = -2.76742510726862411e-03 * DAYS_PER_YEAR
            p.vy = 4.99852801234917238e-03 * DAYS_PER_YEAR
            p.vz = 2.30417297573763929e-05 * DAYS_PER_YEAR
            p.mass = 2.85885980666130812e-04 * SOLAR_MASS
            return p
        }

        fun uranus(): Body {
            val p = Body()
            p.x = 1.28943695621391310e+01
            p.y = -1.51111514016986312e+01
            p.z = -2.23307578892655734e-01
            p.vx = 2.96460137564761618e-03 * DAYS_PER_YEAR
            p.vy = 2.37847173959480950e-03 * DAYS_PER_YEAR
            p.vz = -2.96589568540237556e-05 * DAYS_PER_YEAR
            p.mass = 4.36624404335156298e-05 * SOLAR_MASS
            return p
        }

        fun neptune(): Body {
            val p = Body()
            p.x = 1.53796971148509165e+01
            p.y = -2.59193146099879641e+01
            p.z = 1.79258772950371181e-01
            p.vx = 2.68067772490389322e-03 * DAYS_PER_YEAR
            p.vy = 1.62824170038242295e-03 * DAYS_PER_YEAR
            p.vz = -9.51592254519715870e-05 * DAYS_PER_YEAR
            p.mass = 5.15138902046611451e-05 * SOLAR_MASS
            return p
        }

        fun sun(): Body {
            val p = Body()
            p.mass = SOLAR_MASS
            return p
        }
    }
}

class NBody {
    private val bodies: Array<Body>

    init {
        bodies = arrayOf(Body.sun(), Body.jupiter(), Body.saturn(), Body.uranus(), Body.neptune())

        var px = 0.0
        var py = 0.0
        var pz = 0.0
        for (i in bodies.indices) {
            px += bodies[i].vx * bodies[i].mass
            py += bodies[i].vy * bodies[i].mass
            pz += bodies[i].vz * bodies[i].mass
        }
        bodies[0].offsetMomentum(px, py, pz)
    }

    fun advance(dt: Double) {
        for (i in bodies.indices) {
            val iBody = bodies[i]
            for (j in i + 1 until bodies.size) {
                val dx = iBody.x - bodies[j].x
                val dy = iBody.y - bodies[j].y
                val dz = iBody.z - bodies[j].z

                val dSquared = dx * dx + dy * dy + dz * dz
                val distance = sqrt(dSquared)
                val mag = dt / (dSquared * distance)

                iBody.vx -= dx * bodies[j].mass * mag
                iBody.vy -= dy * bodies[j].mass * mag
                iBody.vz -= dz * bodies[j].mass * mag

                bodies[j].vx += dx * iBody.mass * mag
                bodies[j].vy += dy * iBody.mass * mag
                bodies[j].vz += dz * iBody.mass * mag
            }
        }

        for (body in bodies) {
            body.x += dt * body.vx
            body.y += dt * body.vy
            body.z += dt * body.vz
        }
    }

    fun energy(): Double {
        var dx: Double
        var dy: Double
        var dz: Double
        var distance: Double
        var e = 0.0

        for (i in bodies.indices) {
            val iBody = bodies[i]
            e += 0.5 * iBody.mass *
                    (iBody.vx * iBody.vx
                            + iBody.vy * iBody.vy
                            + iBody.vz * iBody.vz)

            for (j in i + 1 until bodies.size) {
                val jBody = bodies[j]
                dx = iBody.x - jBody.x
                dy = iBody.y - jBody.y
                dz = iBody.z - jBody.z

                distance = sqrt(dx * dx + dy * dy + dz * dz)
                e -= iBody.mass * jBody.mass / distance
            }
        }
        return e
    }

    fun runBenchmark(n: Int) {
        val before = (energy() * 1000000000.0).roundToInt() / 1000000000.0

        for (i in 0 until n)
            advance(0.01)

        val after = (energy() * 1000000000.0).roundToInt() / 1000000000.0
    }
}

class ReverseComplement {

    private val transFrom = "ACGTUMRWSYKVHDBN"
    private val transTo = "TGCAAKYWSRMBDHVN"
    private val transMap = ByteArray(128)

    init {
        for (i in transMap.indices) transMap[i] = i.toByte()
        for (j in 0 until transFrom.length) {
            val c = transFrom[j]
            transMap[c.lowercase().single().code] = transTo[j].code.toByte()
            transMap[c.code] = transMap[c.lowercase().single().code]
        }
    }

    private var buffer = ByteArray(65536)   // 64*1024

    private var pos: Int = 0
    private var limit: Int = 0
    private var start: Int = 0
    private var end: Int = 0

    private fun endPos(): Int {
        for (off in pos until limit) {
            if (buffer[off] == '\n'.code.toByte())
                return off
        }
        return -1
    }

    /**
     * Reads from standard input to buffer
     */
    private fun nextLine(): Boolean {
        while (true) {
            end = endPos()
            if (end >= 0) {
                start = pos
                pos = end + 1
                if (buffer[end - 1] == '\r'.code.toByte())
                    end--
                while (buffer[start] == ' '.code.toByte()) start++
                while (end > start && buffer[end - 1] == ' '.code.toByte()) end--
                if (end > start)
                    return true
            } else {
                if (pos > 0 && limit > pos) {
                    limit -= pos
                    // copy contents of buffer after index pos to the beginning of buffer
                    buffer.copyInto(buffer, 0, pos, pos+limit)
                    pos = 0
                } else {
                    limit = 0
                    pos = limit
                }
                val r = System.`in`.read(buffer, limit, buffer.size - limit)

                if (r <= 0)
                    return false
                limit += r
            }
        }
    }

    private var LINE_WIDTH = 0
    private var data = ByteArray(1 shl 20) // 1 shl 20 = 1048576
    private var size: Int = 0
    private var outputBuffer = ByteArray(65536)
    private var outputPos = 0

    /**
     * Writes __outputBuffer__ contents from index 0 to __outputPos__ to standard output.
     */
    private fun flushData() {
        System.out.write(outputBuffer, 0, outputPos)
        outputPos = 0
    }

    /**
     * If the __outputBuffer__ cannot add [len] bytes without overflowing buffer, flush the
     * contents of the buffer to standard output. Otherwise, do nothing.
     */
    private fun prepareWrite(len: Int) {
        if (outputPos + len > outputBuffer.size)
            flushData()
    }

    /**
     * Writes [b].toByte() into __outputBuffer__.
     */
    private fun write(b: Int) {
        outputBuffer[outputPos++] = b.toByte()
    }

    /**
     * Writes [len] bytes from [buf] starting at [off] to __outputBuffer__.
     */
    private fun write(buf: ByteArray, off: Int, len: Int) {
        prepareWrite(len)
        buf.copyInto(outputBuffer, outputPos, off, off+len)
        outputPos += len
    }

    /**
     * Writes the remaining contents of __data__ to __outputBuffer__ if __size__ > 0.
     */
    private fun finishData() {
        while (size > 0) {
            var len = min(LINE_WIDTH, size)
            prepareWrite(len + 1)
            while (len-- != 0) {
                write(data[--size].toInt())
            }
            write('\n'.code)
        }
        resetData()
    }

    private fun resetData() {
        LINE_WIDTH = 0
        size = 0
    }

    /**
     * Inserts characters encoded to bytes in __data__ from __transmap__ by extracting characters
     * using the __buffer__ contents \[__start__ to __end__] .
     */
    private fun appendLine() {
        val len = end - start
        if (LINE_WIDTH == 0) LINE_WIDTH = len
        // Doubles the size of the global data array if size + len > data.size
        if (size + len > data.size) {
            val data0 = data
            data = ByteArray(data.size * 2)
            data0.copyInto(data, 0, 0, size)
        }
        for (i in start until end) {
            data[size++] = transMap[buffer[i].toInt()]
        }
    }

    private fun solve() {
        limit = 0
        pos = limit
        outputPos = 0
        resetData()
        while (nextLine()) {
            if (buffer[start] == '>'.code.toByte()) {
                finishData()
                write(buffer, start, pos - start)
            } else {
                appendLine()
            }
        }
        finishData()
        if (outputPos > 0) flushData()
        System.out.flush()
    }

    fun runBenchmark(n: Int) {
        solve()
    }
}

