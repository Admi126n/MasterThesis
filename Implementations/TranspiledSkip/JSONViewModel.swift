//
//  JSONViewModel.swift
//  transpiled-skip
//
//  Created by Adam Tokarski on 30/03/2025.
//

import Foundation
import Observation
import OSLog

@Observable public class JSONViewModel {
	
	let numberOfTests: Int
	
	public struct APIResponse: Codable {
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
	
	public init(numberOfTests: Int) {
		self.numberOfTests = numberOfTests
	}
	
	public func getDataFromBundle(forFile named: String) -> Data {
		let url = Bundle.module.url(forResource: named, withExtension: ".json")!
		
		return try! Data(contentsOf: url)
	}
	
	@discardableResult
	private func encode(from data: Data) -> [APIResponse] {
		try! JSONDecoder().decode([APIResponse].self, from: data)
	}
	
	@discardableResult
	private func decode(_ objects: [APIResponse]) -> Data {
		try! JSONEncoder().encode(objects)
	}
	
	func encodeTest(_ file: String) {
		let data = getDataFromBundle(forFile: file)
		
		for i in 0..<numberOfTests {
			let result = BenchmarkRunner.mesureTime {
				encode(from: data)
			}
			let cpuUsage = CPUCalculator.cpuUsage()
			
			print("(\(i + 1)/\(numberOfTests)) ENCODE \(file); \(result) [ns]; \(cpuUsage) [%]")
		}
	}
	
	func decodeTest(_ file: String) {
		let data = getDataFromBundle(forFile: file)
		let objects = encode(from: data)
		
		for i in 0..<numberOfTests {
			let result = BenchmarkRunner.mesureTime {
				decode(objects)
			}
			let cpuUsage = CPUCalculator.cpuUsage()
			
			print("(\(i + 1)/\(numberOfTests)) DECODE \(file); \(result) [ns]; \(cpuUsage) [%]")
		}
	}
}
