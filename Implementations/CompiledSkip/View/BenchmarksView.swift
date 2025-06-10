//
//  SwiftUIView.swift
//  compiled-skip
//
//  Created by Adam Tokarski on 10/04/2025.
//

import SwiftUI
import CompiledSkipModel

struct BenchmarksView: View {
	
	let numberOfTests: Int
	let fannkuchRedux: Int
	let fasta: Int
	let nBody: Int
	let reverseComplement: Int
	
	var body: some View {
		VStack {
			Button("Run FannkuchRedux") {
				runBenchmark("FannkuchRedux") {
					FannkuchRedux.runBenchmark(n: fannkuchRedux)
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
				
				print("(\(i + 1)/\(numberOfTests)) \(name); \(result) [ns]; \(cpuUsage) [%]")
			}
		}
	}
}

#Preview {
	BenchmarksView(numberOfTests: 1, fannkuchRedux: 1, fasta: 1, nBody: 1, reverseComplement: 1)
}
