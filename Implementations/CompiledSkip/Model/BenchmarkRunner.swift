//
//  File.swift
//  compiled-skip
//
//  Created by Adam Tokarski on 30/03/2025.
//

import Foundation

public enum BenchmarkRunner {
	public static func mesureTime(_ code: () -> Void) -> Int64 {
		let start = DispatchTime.now()
		code()
		let end = DispatchTime.now()
		
		let time = end.uptimeNanoseconds - start.uptimeNanoseconds
		
		return Int64(time)
	}
}
