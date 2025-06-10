//
//  ContentView.swift
//  SwiftApp
//
//  Created by Adam Tokarski on 17/03/2025.
//

import Shared
import SwiftUI

struct ContentView: View {
	var body: some View {
		VStack {
			DatabaseTestsView(numberOfTests: 100, numberOfInstances: 1_000)
			
			JSONTestsView(numberOfTests: 110)
			
			BenchmarksView(numberOfTests: 110,
						   fannkuchRedux: 8,
						   fasta: 100_000,
						   nBody: 100_000,
						   reverseComplement: 100_000)
		}
	}
}

#Preview {
	ContentView()
}

// MARK: - Database tests

struct DatabaseTestsView: View {
	
	let numberOfTests: Int
	let numberOfInstances: Int
	let database = Database(databaseDriverFactory: IOSDatabaseDriverFactory())
	
	var body: some View {
		VStack {
			Button("Run database atomic tests") {
				Task {
					let people: [Person] = (0..<numberOfInstances).map { Person(name: "Hello \($0)") }
					
					// insert
					for i in 0..<numberOfTests {
						let result = BenchmarkRunner.mesureTime {
							database.insertPeople(people: people)
						}
						
						database.deletePeople()
						print("(\(i + 1)/\(numberOfTests)) INSERT \(numberOfInstances) instances: \(result) [ns]")
					}
					
					// select
					for i in 0..<numberOfTests {
						database.insertPeople(people: people)
						
						let result = BenchmarkRunner.mesureTime {
							database.selectPeople()
						}
						
						database.deletePeople()
						print("(\(i + 1)/\(numberOfTests)) SELECT \(numberOfInstances) instances: \(result) [ns]")
					}
					
					// update
					for i in 0..<numberOfTests {
						database.insertPeople(people: people)
						
						let result = BenchmarkRunner.mesureTime {
							database.updatePeople(people: people)
						}
						
						database.deletePeople()
						print("(\(i + 1)/\(numberOfTests)) UPDATE \(numberOfInstances) instances: \(result) [ns]")
					}
					
					// delete
					for i in 0..<numberOfTests {
						database.insertPeople(people: people)
						
						let result = BenchmarkRunner.mesureTime {
							database.deletePeople()
						}
						
						print("(\(i + 1)/\(numberOfTests)) DELETE \(numberOfInstances) instances: \(result) [ns]")
					}
				}
			}
			.buttonStyle(.borderedProminent)
			
			Button("Run full database tests") {
				Task {
					let people: [Person] = (0..<numberOfInstances).map { Person(name: "Hello \($0)") }
					
					for i in 0..<numberOfTests {
						let result = BenchmarkRunner.mesureTime {
							database.insertPeople(people: people)
							database.selectPeople()
							database.updatePeople(people: people)
							database.deletePeople()
						}
						
						print("(\(i + 1)/\(numberOfTests)) DATABASE \(numberOfInstances) instances: \(result) [ns]")
					}
				}
			}
			.buttonStyle(.borderedProminent)
		}
	}
}

// MARK: - JSON tests

struct JSONTestsView: View {
	
	let numberOfTests: Int
//	let files = ["API_1", "API_100", "API_1000", "API_10000", "API_33462"]
	let files = ["API_33462"]
	
	var body: some View {
		VStack {
			Button("Run JSON tests") {
				for file in files {
					let url = Bundle.main.url(forResource: file, withExtension: "json")!
					let string = try! String(contentsOf: url, encoding: .utf8)
					let tester = JSONTester()
					let objects = tester.encode(string: string)!
					
					for i in 0..<numberOfTests {
						let result = BenchmarkRunner.mesureTime {
							_ = tester.encode(string: string)
						}
						let cpuUsage = CPUCalculator.cpuUsage()
						
						print("(\(i + 1)/\(numberOfTests)) ENCODE \(file); \(result) [ns]; \(cpuUsage) [%]")
					}
					
					for i in 0..<numberOfTests {
						let result = BenchmarkRunner.mesureTime {
							_ = tester.decode(objects: objects)
						}
						let cpuUsage = CPUCalculator.cpuUsage()
						
						print("(\(i + 1)/\(numberOfTests)) DECODE \(file); \(result) [ns]; \(cpuUsage) [%]")
					}
				}
			}
			.buttonStyle(.borderedProminent)
			.tint(.green)
		}
	}
}

// MARK: - Benchmarks tests

struct BenchmarksView: View {
	
	let numberOfTests: Int
	let fannkuchRedux: Int32
	let fasta: Int32
	let nBody: Int32
	let reverseComplement: Int32
	
	var body: some View {
		VStack {
			Button("Run FannkuchRedux") {
				runBenchmark("FannkuchRedux") {
					FannkuchRedux().runBenchmark(n: fannkuchRedux)
				}
			}
			.buttonStyle(.borderedProminent)
			.tint(.orange)
			
			Button("Run Fasta") {
				runBenchmark("Fasta") {
					Fasta().runBenchmark(n: fasta)
				}
			}
			.buttonStyle(.borderedProminent)
			.tint(.orange)
			
			Button("Run NBody") {
				runBenchmark("NBody") {
					NBody().runBenchmark(n: nBody)
				}
			}
			.buttonStyle(.borderedProminent)
			.tint(.orange)
			
			Button("Run ReverseComplement") {
				runBenchmark("ReverseComplement") {
					ReverseComplement().runBenchmark(n: reverseComplement)
				}
			}
			.buttonStyle(.borderedProminent)
			.tint(.orange)
		}
	}
	
	private func runBenchmark(_ name: String, _ benchmark: @escaping () -> Void) {
		Task {
			for i in 0..<numberOfTests {
				let result = BenchmarkRunner.mesureTime {
					benchmark()
				}
				let cpuUsage = CPUCalculator.cpuUsage()
				
				print("(\(i + 1)/\(numberOfTests)) \(name); \(result); [ns]; \(cpuUsage); [%]")
			}
		}
	}
}

// MARK: - Benchmark runner

enum BenchmarkRunner {
	static func mesureTime(_ code: () -> Void) -> UInt64 {
		let start = DispatchTime.now()
		code()
		let end = DispatchTime.now()
		
		let time = end.uptimeNanoseconds - start.uptimeNanoseconds
		
		return time
	}
}

// MARK: - CPU calculator

enum CPUCalculator {
	static func cpuUsage() -> Double {
		var totalUsageOfCPU: Double = 0.0
		var threadsList: thread_act_array_t?
		var threadsCount = mach_msg_type_number_t(0)
		let threadsResult = withUnsafeMutablePointer(to: &threadsList) {
			return $0.withMemoryRebound(to: thread_act_array_t?.self, capacity: 1) {
				task_threads(mach_task_self_, $0, &threadsCount)
			}
		}
		
		if threadsResult == KERN_SUCCESS, let threadsList = threadsList {
			for index in 0..<threadsCount {
				var threadInfo = thread_basic_info()
				var threadInfoCount = mach_msg_type_number_t(THREAD_INFO_MAX)
				let infoResult = withUnsafeMutablePointer(to: &threadInfo) {
					$0.withMemoryRebound(to: integer_t.self, capacity: 1) {
						thread_info(threadsList[Int(index)], thread_flavor_t(THREAD_BASIC_INFO), $0, &threadInfoCount)
					}
				}
				
				guard infoResult == KERN_SUCCESS else {
					break
				}
				
				let threadBasicInfo = threadInfo as thread_basic_info
				if threadBasicInfo.flags & TH_FLAGS_IDLE == 0 {
					totalUsageOfCPU = (totalUsageOfCPU + (Double(threadBasicInfo.cpu_usage) / Double(TH_USAGE_SCALE) * 100.0))
				}
			}
		}
		
		vm_deallocate(mach_task_self_, vm_address_t(UInt(bitPattern: threadsList)), vm_size_t(Int(threadsCount) * MemoryLayout<thread_t>.stride))
		return totalUsageOfCPU
	}
}
