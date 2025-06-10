//
//  JSONTestsView.swift
//  compiled-skip
//
//  Created by Adam Tokarski on 30/03/2025.
//

import SwiftUI
import CompiledSkipModel

struct JSONTestsView: View {
	
	let numberOfTests: Int
	let viewModel: JSONViewModel
	
	let files = ["API_1", "API_100", "API_1000", "API_10000", "API_33462"]
	
	var body: some View {
		VStack {
			Button("Run JSON tests") {
				for file in files {
					runEncode(file)
					runDecode(file)
				}
			}
			.buttonStyle(.borderedProminent)
			.tint(.green)
		}
	}
	
	init(numberOfTests: Int) {
		self.numberOfTests = numberOfTests
		self.viewModel = JSONViewModel(numberOfTests: numberOfTests)
	}
	
	private func runEncode(_ file: String) {
		let data = viewModel.getDataFromBundle(forFile: file)
		
		for i in 0..<numberOfTests {
			let result = BenchmarkRunner.mesureTime {
				viewModel.encode(from: data)
			}
			let cpuUsage = CPUCalculator.cpuUsage()
				
			print("(\(i + 1)/\(numberOfTests)) ENCODE \(file); \(result) [ns]; \(cpuUsage) [%]")
		}
	}
	
	private func runDecode(_ file: String) {
		let data = viewModel.getDataFromBundle(forFile: file)
		let objects = viewModel.encode(from: data)
		
		for i in 0..<numberOfTests {
			let result = BenchmarkRunner.mesureTime {
				viewModel.decode(objects)
			}
			let cpuUsage = CPUCalculator.cpuUsage()
				
			print("(\(i + 1)/\(numberOfTests)) DECODE \(file); \(result) [ns]; \(cpuUsage) [%]")
		}
	}
}

#Preview {
	return JSONTestsView(numberOfTests: 1)
}
