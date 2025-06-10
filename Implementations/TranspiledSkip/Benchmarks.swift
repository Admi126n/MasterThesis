//
//  File.swift
//  transpiled-skip
//
//  Created by Adam Tokarski on 09/04/2025.
//

import Foundation

// MARK: - FannkuchRedux

enum FannkuchRedux {
	static func fannkuch(_ n: Int) -> Int {
		var perm = Array(repeating: 0, count: n)
		var count = Array(repeating: 0, count: n)
		
		var perm1 = Array(repeating: 0, count: n)
		
		for j in 0...(n - 1) {
			perm1[j] = j
		}
		
		var f = 0
		var i = 0
		var k = 0
		var r = 0
		var flips = 0
		var nperm = 0
		var checksum = 0
		
		r = n
		while r > 0 {
			i = 0
			while r != 1 {
				count[r - 1] = r
				r -= 1
			}
			while i < n {
				perm[i] = perm1[i]
				i += 1
			}
			
			f = 0
			k = perm[0]
			while k != 0 {
				i = 0
				while 2 * i < k {
					let t = perm[i]
					perm[i] = perm[k - i]
					perm[k - i] = t
					i += 1
				}
				k = perm[0]
				f += 1
			}
			if f > flips {
				flips = f
			}
			
			if (nperm&0x1) == 0 {
				checksum += f
			} else {
				checksum -= f
			}
			
			var go = true
			while go {
				if r == n {
					return flips
				}
				let p0 = perm1[0]
				i = 0
				while i < r {
					let j = i + 1
					perm1[i] = perm1[j]
					i = j
				}
				perm1[r] = p0
				
				count[r] -= 1
				if count[r] > 0 {
					go = false
				} else {
					r += 1
				}
			}
			nperm += 1
		}
		return flips
	}
	
	static func runBenchmark(n: Int){
		_ = fannkuch(n)
	}
}

// MARK: - Fasta

class Fasta {
	struct AminoAcid {
		var prob: Double
		var sym: Int
	}
	
	let IM = 139968
	let IA = 3877
	let IC = 29573
	var seed = 42
		
	let bufferSize = 61 * 1024
	let width = 60
	
	let aluString = "GGCCGGGCGCGGTGGCTCACGCCTGTAATCCCAGCACTTTGG" +
	"GAGGCCGAGGCGGGCGGATCACCTGAGGTCAGGAGTTCGAGA" +
	"CCAGCCTGGCCAACATGGTGAAACCCCGTCTCTACTAAAAAT" +
	"ACAAAAATTAGCCGGGCGTGGTGGCGCGCGCCTGTAATCCCA" +
	"GCTACTCGGGAGGCTGAGGCAGGAGAATCGCTTGAACCCGGG" +
	"AGGCGGAGGTTGCAGTGAGCCGAGATCGCGCCACTGCACTCC" +
	"AGCCTGGGCGACAGAGCGAGACTCCGTCTCAAAAA"
	
	var iub = [
		AminoAcid(prob: 0.27, sym: 97), // "a")
		AminoAcid(prob: 0.12, sym: 99), // "c")
		AminoAcid(prob: 0.12, sym: 103), // "g")
		AminoAcid(prob: 0.27, sym: 116), // "t")
		AminoAcid(prob: 0.02, sym: 66), // "B")
		AminoAcid(prob: 0.02, sym: 68), // "D")
		AminoAcid(prob: 0.02, sym: 72), // "H")
		AminoAcid(prob: 0.02, sym: 75), // "K")
		AminoAcid(prob: 0.02, sym: 77), // "M")
		AminoAcid(prob: 0.02, sym: 78), // "N")
		AminoAcid(prob: 0.02, sym: 82), // "R")
		AminoAcid(prob: 0.02, sym: 83), // "S")
		AminoAcid(prob: 0.02, sym: 86), // "V")
		AminoAcid(prob: 0.02, sym: 87), // "W")
		AminoAcid(prob: 0.02, sym: 89), // "Y")
	]
	
	var homosapiens = [
		AminoAcid(prob: 0.3029549426680, sym: 97), // "a")
		AminoAcid(prob: 0.1979883004921, sym: 99), // "c")
		AminoAcid(prob: 0.1975473066391, sym: 103), // "g")
		AminoAcid(prob: 0.3015094502008, sym: 116), // "t")
	]
	
	func repeatFasta(id: String, desc: String, gene: [Int], n: Int) {
		let gene2 = gene + gene
		var buffer = [Int](repeating: 10, count: bufferSize)
		
		let descStr = String(">" + id + " " + desc + "\n")
		_ = [UInt8](descStr.utf8)
		
		var pos = 0
		var rpos = 0
		var cnt = n
		var lwidth = width
		while cnt > 0 {
			if pos + lwidth > buffer.count {
				pos = 0
			}
			if rpos + lwidth > gene.count {
				rpos = rpos % gene.count
			}
			if cnt < lwidth {
				lwidth = cnt
			}
			buffer[pos..<pos + lwidth] = gene2[rpos..<rpos + lwidth]
			buffer[pos + lwidth] = 10
			pos += lwidth + 1
			rpos += lwidth
			cnt -= lwidth
		}
		if pos > 0 && pos < buffer.count {
			buffer[pos] = 10
		} else if pos == buffer.count {
			buffer[0] = 10
		}
	}
	
	func search(rnd: Double, within arr: [AminoAcid]) -> Int {
		var low = 0
		var high = arr.count - 1
		while low <= high {
			let mid = low + (high - low) / 2
			if arr[mid].prob >= rnd {
				high = mid - 1
			} else {
				low = mid + 1
			}
		}
		return arr[high + 1].sym
	}
	
	func accumulateProbabilities(acid: inout [AminoAcid]) {
		for i in 1..<acid.count {
			acid[i].prob += acid[i - 1].prob
		}
	}
	
	func randomFasta(id: String, desc: String, acid: inout [AminoAcid], _ n: Int) {
		var cnt = n
		accumulateProbabilities(acid: &acid)
		var buffer = [Int](repeating: 10, count: bufferSize)
		
		let descStr = String(">" + id + " " + desc + "\n")
		_ = [UInt8](descStr.utf8)
		
		var pos = 0
		while cnt > 0 {
			var m = cnt
			if m > width {
				m = width
			}
			let f = 1.0 / Double(IM)
			var myrand = seed
			for _ in 0..<m {
				myrand = (myrand * IA + IC) % IM
				let r = Double(myrand) * f
				buffer[pos] = search(rnd: r, within: acid)
				pos += 1
				if pos == buffer.count {
					pos = 0
				}
			}
			seed = myrand
			buffer[pos] = 10
			pos += 1
			if pos == buffer.count {
				pos = 0
			}
			cnt -= m
		}
		if pos > 0 { }
	}
	
	func runBenchmark(n: Int) {
		var alu: [Int] = []
		
		for char in aluString {
			switch char {
			case "A":
				alu.append(65)
			case "C":
				alu.append(67)
			case "G":
				alu.append(71)
			case "T":
				alu.append(84)
			default:
				fatalError("Unknown char")
			}
		}
		
		_ = alu.popLast()
		
		repeatFasta(id: "ONE", desc: "Homo sapiens alu", gene: alu, n: 2 * n)
		randomFasta(id: "TWO", desc: "IUB ambiguity codes", acid: &iub, 3 * n)
		randomFasta(id: "THREE", desc: "Homo sapiens frequency", acid: &homosapiens, 5 * n)
	}
}

// MARK: - NBody

class Body {
	var x: Double = 0.0
	var y: Double = 0.0
	var z: Double = 0.0
	var vx: Double = 0.0
	var vy: Double = 0.0
	var vz: Double = 0.0
	var mass: Double = 0.0
}

class NBody {
	
	let SOLAR_MASS = 4 * Double.pi * Double.pi
	let DAYS_PER_YEAR = 365.24
	
	func jupiter() -> Body {
		let p = Body()
		p.x = 4.8414314424647209
		p.y = -1.16032004402742839
		p.z = -0.103622044471123109
		p.vx = 1.66007664274403694e-03 * DAYS_PER_YEAR
		p.vy = 7.69901118419740425e-03 * DAYS_PER_YEAR
		p.vz = -6.90460016972063023e-05 * DAYS_PER_YEAR
		p.mass = 9.54791938424326609e-04 * SOLAR_MASS
		return p
	}
	
	func saturn() -> Body {
		let p = Body()
		p.x = 8.34336671824457987
		p.y = 4.12479856412430479
		p.z = -4.03523417114321381e-01
		p.vx = -2.76742510726862411e-03 * DAYS_PER_YEAR
		p.vy = 4.99852801234917238e-03 * DAYS_PER_YEAR
		p.vz = 2.30417297573763929e-05 * DAYS_PER_YEAR
		p.mass = 2.85885980666130812e-04 * SOLAR_MASS
		return p
	}
	
	func uranus() -> Body {
		let p = Body()
		p.x = 1.28943695621391310e+01
		p.y = -1.51111514016986312e+01
		p.z = -2.23307578892655734e-01
		p.vx = 2.96460137564761618e-03 * DAYS_PER_YEAR
		p.vy = 2.37847173959480950e-03 * DAYS_PER_YEAR
		p.vz = -2.96589568540237556e-05 * DAYS_PER_YEAR
		p.mass = 4.36624404335156298e-05 * SOLAR_MASS
		return p
	}
	
	func neptune() -> Body {
		let p = Body()
		p.x = 1.53796971148509165e+01
		p.y = -2.59193146099879641e+01
		p.z = 1.79258772950371181e-01
		p.vx = 2.68067772490389322e-03 * DAYS_PER_YEAR
		p.vy = 1.62824170038242295e-03 * DAYS_PER_YEAR
		p.vz = -9.51592254519715870e-05 * DAYS_PER_YEAR
		p.mass = 5.15138902046611451e-05 * SOLAR_MASS
		return p
	}
	
	func sun() -> Body {
		let p = Body()
		p.mass = SOLAR_MASS
		return p
	}
	
	func advance(_ bodies: inout [Body], dt: Double) {
		for i in 0..<bodies.count {
			for j in (i + 1)..<bodies.count {
				let (dx, dy, dz) = (bodies[i].x - bodies[j].x,
									bodies[i].y - bodies[j].y,
									bodies[i].z - bodies[j].z)
				
				let dSquared = dx * dx + dy * dy + dz * dz
				let distance = sqrt(dSquared)
				let mag = dt / (dSquared * distance)
				
				bodies[i].vx = bodies[i].vx - dx * bodies[j].mass * mag
				bodies[i].vy = bodies[i].vy - dy * bodies[j].mass * mag
				bodies[i].vz = bodies[i].vz - dz * bodies[j].mass * mag
				
				bodies[j].vx = bodies[j].vx + dx * bodies[i].mass * mag
				bodies[j].vy = bodies[j].vy + dy * bodies[i].mass * mag
				bodies[j].vz = bodies[j].vz + dz * bodies[i].mass * mag
			}
		}
		
		for i in 0..<bodies.count {
			bodies[i].x = bodies[i].x + dt * bodies[i].vx
			bodies[i].y = bodies[i].y + dt * bodies[i].vy
			bodies[i].z = bodies[i].z + dt * bodies[i].vz
		}
	}
	
	func energy(_ bodies: [Body]) -> Double {
		var energy = 0.0
		for (i, body) in bodies.enumerated() {
			energy += 0.5 * body.mass * (body.vx * body.vx
									   + body.vy * body.vy
									   + body.vz * body.vz)
			for jbody in bodies[(i + 1)..<bodies.count] {
				let dx = body.x - jbody.x
				let dy = body.y - jbody.y
				let dz = body.z - jbody.z
				let distance = sqrt(dx * dx + dy * dy + dz * dz)
				energy -= (body.mass * jbody.mass) / distance
			}
		}
		
		return energy
	}

	public func runBenchmark(n: Int) {
		var bodies = [sun(), jupiter(), saturn(), uranus(), neptune()]
		
		var tmp0 = 0.0
		var tmp1 = 0.0
		var tmp2 = 0.0
		
		for body in bodies {
			tmp0 += body.vx * body.mass
			tmp1 += body.vy * body.mass
			tmp2 += body.vz * body.mass
		}
		bodies[0].vx = -tmp0 / SOLAR_MASS
		bodies[0].vy = -tmp1 / SOLAR_MASS
		bodies[0].vz = -tmp2 / SOLAR_MASS
		
		_ = (round(energy(bodies) * 1000000000) / 1000000000.0)
		
		for _ in 0..<n {
			advance(&bodies, dt: 0.01)
		}
		
		_ = (round(energy(bodies) * 1000000000) / 1000000000.0)
	}
}

// MARK: - ReverseComplement

class ReverseComplement {
	
	private let transFrom = "ACGTUMRWSYKVHDBN"
	private let transTo = "TGCAAKYWSRMBDHVN"
	private var transMap = [Int](repeating: 0, count: 128)

	public init() {
		for i in transMap.indices {
			transMap[i] = i
		}
		for j in 0..<transFrom.count {
			let c = transFrom[transFrom.index(transFrom.startIndex, offsetBy: j)]
			transMap[Int(c.lowercased().utf8.first!)] = Int(String(transTo[transTo.index(transTo.startIndex, offsetBy: j)]).utf8.first!)
#if SKIP
			transMap[c.code] = transMap[Int(c.lowercased().utf8.first!)]
#else
			transMap[Int(c.utf8.first!)] = transMap[Int(c.lowercased().utf8.first!)]
#endif
		}
	}

	private var buffer: [Int] = [Int](repeating: 0, count: 65536)
	private var pos: Int = 0
	private var limit: Int = 0
	private var start: Int = 0
	private var end: Int = 0

	private func endPos() -> Int {
		for off in pos..<limit {
			if buffer[off] == 10 {
				return off
			}
		}
		return -1
	}
	
	private func nextLine() -> Bool {
		while true {
			end = endPos()
			if end >= 0 {
				start = pos
				pos = end + 1
				if buffer[end - 1] == 114 {
					end -= 1
				}
				while buffer[start] == 32 {
					start += 1
				}
				while end > start && buffer[end - 1] == 32 {
					end -= 1
				}
				if end > start {
					return true
				}
			} else {
				if pos > 0 && limit > pos {
					limit -= pos
					buffer[0..<limit] = buffer[pos..<limit + pos]
					pos = 0
				} else {
					limit = 0
					pos = limit
				}
				
				let r = readFromSdt()
				
				// end of stream was reached
				if r <= 0 {
					return false
				}
				limit += r
			}
		}
	}
	
	// SKIP REPLACE:
	// fun readFromSdt(): Int {
	//     val tmp = ByteArray(buffer.count) { i -> buffer[i].toByte() }
	//     return System.`in`.read(tmp, limit, buffer.count - limit)
	// }
	func readFromSdt() -> Int {
		read(STDIN_FILENO, &buffer[limit], buffer.count - limit)
	}
	
	private var LINE_WIDTH = 0
	private var data = [Int](repeating: 0, count: 1048576)
	private var size: Int = 0
	private var outputBuffer = [Int](repeating: 0, count: 65536)
	private var outputPos = 0
	
	private func flushData() {
#if SKIP
		let tmp = outputBuffer.map { String($0) }.joined().toByteArray()
		System.out.write(tmp, 0, outputPos)
#else
		let data = Data((outputBuffer as! [UInt8])[0..<outputPos])
		let handle = FileHandle.standardOutput
		handle.write(data)
#endif
		outputPos = 0
	}
	
	private func prepareWrite(len: Int) {
		if (outputPos + len > outputBuffer.count) {
			flushData()
		}
	}
	
	private func write(b: Int) {
		outputBuffer[outputPos] = b
		outputPos += 1
	}
	
	private func write(buf: [Int], off: Int, len: Int) {
		prepareWrite(len: len)
		outputBuffer.insert(contentsOf: buf[off..<(off + len)], at: outputPos)
		outputPos += len
	}
	
	private func finishData() {
		while size > 0 {
			let len = min(LINE_WIDTH, size)
			prepareWrite(len: len + 1)
			for _ in 0..<len {
				write(b: Int(data[size - 1]))
				size -= 1
			}
			write(b: Int(10))
		}
		resetData()
	}
	
	private func resetData() {
		LINE_WIDTH = 0
		size = 0
	}
	
	private func appendLine() {
		let len = end - start
		if (LINE_WIDTH == 0) {
			LINE_WIDTH = len
		}
		
		if (size + len > data.count) {
			let data0 = data
			data = [Int](repeating: 0, count: data.count * 2)
			data.insert(contentsOf: data0[0..<size], at: 0)
		}
		for i in start..<end {
			data[size] = transMap[Int(buffer[i])]
			size += 1
		}
	}

	private func solve() {
		limit = 0
		pos = limit
		outputPos = 0
		resetData()
		while (nextLine()) {
			if buffer[start] == 62 {
				finishData()
				write(buf: buffer, off: start, len: pos - start)
			} else {
				appendLine()
			}
		}
		finishData()
		if outputPos > 0 {
			flushData()
		}
#if SKIP
		System.out.flush()
#else
		fflush(stdout)
#endif
	}
	
	public func runBenchmark(n: Int) {
		solve()
	}
}
