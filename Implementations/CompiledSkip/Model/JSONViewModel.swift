//
//  File.swift
//  compiled-skip
//
//  Created by Adam Tokarski on 30/03/2025.
//

import Foundation
import Observation
import SkipFuse

public struct JSONViewModel {
	
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
	public func encode(from data: Data) -> [APIResponse] {
		try! JSONDecoder().decode([APIResponse].self, from: data)
	}
	
	public func decode(_ objects: [APIResponse]) {
		_ = try! JSONEncoder().encode(objects)
	}
}
