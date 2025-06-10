//
//  BenchmarkRunner.swift
//  transpiled-skip
//
//  Created by Adam Tokarski on 30/03/2025.
//

import Foundation

enum BenchmarkRunner {
	static func mesureTime(_ code: () -> Void) -> UInt64 {
#if SKIP
		let start = System.nanoTime()
		code()
		let end = System.nanoTime()
		
		let time = end - start
		
		return time.toULong()
#else
		let start = DispatchTime.now()
		code()
		let end = DispatchTime.now()
		
		let time = end.uptimeNanoseconds - start.uptimeNanoseconds
		
		return UInt64(time)
#endif
	}
}
