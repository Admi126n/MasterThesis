//
//  JSONTestsView.swift
//  SwiftApp
//
//  Created by Adam Tokarski on 30/03/2025.
//

import SwiftUI

struct JSONTestsView: View {
	
	let numberOfTests: Int
	let files = ["API_1", "API_100", "API_1000", "API_10000", "API_33462"]
	
	var body: some View {
		VStack {
			Button("Run JSON tests") {
				for file in files {
					encodeTest(file: file)
					decodeTest(file: file)
				}
			}
			.buttonStyle(.borderedProminent)
			.tint(.green)
		}
	}
	
	private func encodeTest(file: String) {
		let data = JSONTester.getDataFromBundle(forFile: file)
		
		for i in 0..<numberOfTests {
			let result = BenchmarkRunner.mesureTime {
				JSONTester.encode(from: data)
			}
			let cpuUsage = CPUCalculator.cpuUsage()
			
			print("(\(i + 1)/\(numberOfTests)) ENCODE \(file); \(result) [ns]; \(cpuUsage) [%]")
		}
	}
	
	private func decodeTest(file: String) {
		let data = JSONTester.getDataFromBundle(forFile: file)
		let objects = JSONTester.encode(from: data)
		
		for i in 0..<numberOfTests {
			let result = BenchmarkRunner.mesureTime {
				JSONTester.decode(objects)
			}
			let cpuUsage = CPUCalculator.cpuUsage()
			
			print("(\(i + 1)/\(numberOfTests)) DECODE \(file); \(result) [ns]; \(cpuUsage) [%]")
		}
	}
}

struct APIResponse: Codable {
	let brake: Int
	let date: String
	let driver_number: Int
	let drs: Int
	let meeting_key: Int
	let n_gear: Int
	let rpm: Int
	let session_key: Int
	let speed: Int
	let throttle: Int
}

enum JSONTester {
	
	static func getDataFromBundle(forFile named: String) -> Data {
		let url = Bundle.main.url(forResource: named, withExtension: ".json")!
		
		return try! Data(contentsOf: url)
	}
	
	@discardableResult
	static func encode(from data: Data) -> [APIResponse] {
		try! JSONDecoder().decode([APIResponse].self, from: data)
	}
	
	static func decode(_ objects: [APIResponse]) {
		_ = try! JSONEncoder().encode(objects)
	}
	
}

#Preview {
	return JSONTestsView(numberOfTests: 100)
}
