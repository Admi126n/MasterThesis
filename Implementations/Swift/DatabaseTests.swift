//
//  DatabseTestsView.swift
//  SwiftApp
//
//  Created by Adam Tokarski on 30/03/2025.
//

import SwiftData
import SwiftUI

@Model
final class Person {
	var name: String
	
	init(name: String) {
		self.name = name
	}
}

struct DatabaseTestsView: View {
	
	let numberOfTests: Int
	let numberOfInstances: Int
	
	@Environment(\.modelContext) var modelContext
	
	var body: some View {
		VStack {
			Button("Run database atomic tests") {
				Task {
					let people: [Person] = (0..<numberOfInstances).map { Person(name: "Hello \($0)") }
					
					testInsert(people)
					testSelect(people)
					testUpdate(people)
					testDelete(people)
				}
			}
			.buttonStyle(.borderedProminent)
			
			Button("Run full database tests") {
				Task {
					let people: [Person] = (0..<numberOfInstances).map { Person(name: "Hello \($0)") }
					
					runDatabaseRamTest(people)
				}
			}
			.buttonStyle(.borderedProminent)
		}
	}
	
	// MARK: - Tests
	private func testInsert(_ people: [Person]) {
		for i in 0..<numberOfTests {
			let result = BenchmarkRunner.mesureTime {
				insertPeople(people)
			}
			
			print("(\(i + 1)/\(numberOfTests)) INSERT \(numberOfInstances) instances: \(result) [ns]")
			deletePeople(people)
		}
	}
	
	private func testSelect(_ people: [Person]) {
		for i in 0..<numberOfTests {
			insertPeople(people)
			
			let result = BenchmarkRunner.mesureTime {
				selectPeople()
			}
			
			print("(\(i + 1)/\(numberOfTests)) SELECT \(numberOfInstances) instances: \(result) [ns]")
			deletePeople(people)
		}
	}
	
	private func testUpdate(_ people: [Person]) {
		for i in 0..<numberOfTests {
			insertPeople(people)
			
			let result = BenchmarkRunner.mesureTime {
				updatePeople(people)
			}
			
			print("(\(i + 1)/\(numberOfTests)) UPDATE \(numberOfInstances) instances: \(result) [ns]")
			deletePeople(people)
		}
	}
	
	private func testDelete(_ people: [Person]) {
		for i in 0..<numberOfTests {
			insertPeople(people)
			
			let result = BenchmarkRunner.mesureTime {
				deletePeople(people)
			}
			
			print("(\(i + 1)/\(numberOfTests)) DELETE \(numberOfInstances) instances \(result) [ns]")
		}
	}
	
	private func runDatabaseRamTest(_ people: [Person]) {
		for i in 0..<numberOfTests {
			let time = BenchmarkRunner.mesureTime {
				insertPeople(people)
				selectPeople()
				updatePeople(people)
				deletePeople(people)
			}
			let cpuUsage = CPUCalculator.cpuUsage()
			
			print("(\(i + 1)/\(numberOfTests)) DATABASE \(numberOfInstances) instances; \(time) [ns]; \(cpuUsage) [%]")
		}
	}
	
	// MARK: - Swift Data
	
	private func insertPeople(_ people: [Person]) {
		for person in people {
			modelContext.insert(person)
		}
		
		do {
			try modelContext.save()
		} catch {
			fatalError("Error occured: \(error.localizedDescription)")
		}
	}
	
	private func selectPeople() {
		do {
			_ = try modelContext.fetch(FetchDescriptor<Person>())
		} catch {
			fatalError("Error occured: \(error.localizedDescription)")
		}
	}
	
	private func updatePeople(_ people: [Person]) {
		for person in people {
			person.name = "Hello"
		}
		
		do {
			try modelContext.save()
		} catch {
			fatalError("Error occured: \(error.localizedDescription)")
		}
	}
	
	private func deletePeople(_ people: [Person]) {
		for person in people {
			modelContext.delete(person)
		}
		
		do {
			try modelContext.save()
		} catch {
			fatalError("Error occured: \(error.localizedDescription)")
		}
	}
}

#Preview {
	let config = ModelConfiguration(isStoredInMemoryOnly: true)
	let container = try! ModelContainer(for: Person.self, configurations: config)
	
	return DatabaseTestsView(numberOfTests: 100, numberOfInstances: 1_000)
		.modelContainer(container)
}
