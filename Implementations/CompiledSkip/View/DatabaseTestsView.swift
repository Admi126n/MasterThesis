//
//  DatabaseTestsView.swift
//  compiled-skip
//
//  Created by Adam Tokarski on 30/03/2025.
//

import SwiftUI
import CompiledSkipModel

struct DatabaseTestsView: View {
	let viewModel: DatabaseViewModel
	public let numberOfTests: Int
	let numberOfInstances: Int
	
	var body: some View {
		VStack {
			Button("Run database atomic tests") {
				runAtomicTests()
			}
			.buttonStyle(.borderedProminent)
			
			Button("Run full database tests") {
				runComplexTests()
			}
			.buttonStyle(.borderedProminent)
		}
	}
	
	init(numberOfTests: Int, numberOfInstances: Int) {
		self.numberOfTests = numberOfTests
		self.numberOfInstances = numberOfInstances
		self.viewModel = DatabaseViewModel(numberOfTests: numberOfTests, numberOfInstances: numberOfInstances)
	}
	
	func runAtomicTests() {
		let instances = [1, 10, 100, 1000]
		
		for instance in instances {
			let people: [Person] = (0..<instance).map { Person(name: "Hello \($0)") }
			
			// insert
			for i in 0..<numberOfTests {
				let result = BenchmarkRunner.mesureTime {
					viewModel.insertPeople(people)
				}
				
				print("(\(i + 1)/\(numberOfTests)) INSERT \(instance) instances: \(result) [ns]")
				viewModel.deletePeople()
			}
			
			// select
			for i in 0..<numberOfTests {
				viewModel.insertPeople(people)
				
				let result = BenchmarkRunner.mesureTime {
					viewModel.selectPeople()
				}
				
				print("(\(i + 1)/\(numberOfTests)) SELECT \(instance) instances: \(result) [ns]")
				viewModel.deletePeople()
			}
			
			// update
			for i in 0..<numberOfTests {
				viewModel.insertPeople(people)
				
				let result = BenchmarkRunner.mesureTime {
					viewModel.updatePeople(people)
				}
				
				print("(\(i + 1)/\(numberOfTests)) UPDATE \(instance) instances: \(result) [ns]")
				viewModel.deletePeople()
			}
			
			// delete
			for i in 0..<numberOfTests {
				viewModel.insertPeople(people)
				
				let result = BenchmarkRunner.mesureTime {
					viewModel.deletePeople()
				}
				
				print("(\(i + 1)/\(numberOfTests)) DELETE \(instance) instances \(result) [ns]")
			}
		}
	}
	
	func runComplexTests() {
		let instances = [1, 10, 100, 1000]
		for instance in instances {
			
			let people: [Person] = (0..<instance).map { Person(name: "Hello \($0)") }
			
			for i in 0..<numberOfTests {
				let time = BenchmarkRunner.mesureTime {
					viewModel.insertPeople(people)
					viewModel.selectPeople()
					viewModel.updatePeople(people)
					viewModel.deletePeople()
				}
				let cpuUsage = CPUCalculator.cpuUsage()
				
				print("(\(i + 1)/\(numberOfTests)) DATABASE \(instance) instances; \(time) [ns]; \(cpuUsage) [%]")
			}
		}
		
	}
}
