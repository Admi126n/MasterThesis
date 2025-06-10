import Foundation
import Observation
import OSLog
import SkipSQL

struct Person {
	var name: String
}

@Observable public class DatabaseViewModel {
	
	let numberOfTests: Int
	var numberOfInstances: Int
	
	private let ctx: SQLContext
	
	public init(numberOfTests: Int, numberOfInstances: Int) {
		self.numberOfTests = numberOfTests
		self.numberOfInstances = numberOfInstances
		
		do {
			ctx = try SQLContext(
				path: URL.documentsDirectory.appendingPathComponent("databake.sqlite").path,
				flags: [.create, .readWrite],
				logLevel: .debug
			)
			
			createSchema()
		} catch {
			fatalError("Cannot initialize ctx")
		}
	}
	
	private func createSchema() {
		let query = "CREATE TABLE people (id INTEGER PRIMARY KEY AUTOINCREMENT, name TEXT NOT NULL)"
		
		do {
			try ctx.transaction {
				try ctx.exec(sql: query)
				print("Created")
			}
		} catch {
			print(error.localizedDescription)
		}
	}
	
	func getInsertQueries(for people: [Person]) -> [String] {
		var output: [String] = []
		
		for person in people {
			output.append("INSERT INTO people (name) VALUES ('\(person.name)')")
		}
		
		return output
	}
	
	func getUpdateQueries(for people: [Person]) -> [String] {
		var output: [String] = []
		
		for person in people {
			output.append("UPDATE people SET name='hello' WHERE name = '\(person.name)'")
		}
		
		return output
	}

	private func dropSchema() {
		do {
			try ctx.close()
			try FileManager.default.removeItem(at: URL.documentsDirectory.appendingPathComponent("databake.sqlite"))
			print("Database deleted")
		} catch {
			print(error.localizedDescription)
		}
	}
	
	private func insertPeople(_ queries: [String]) {
		do {
			try ctx.transaction {
				for query in queries {
					try ctx.exec(sql: query)
				}
			}
		} catch {
			print(error.localizedDescription)
		}
	}
	
	private func selectPeople() {
		do {
			try ctx.transaction {
				_ = try ctx.query(sql: "SELECT name FROM people ORDER BY name DESC")
			}
		} catch {
			print(error.localizedDescription)
		}
	}
	
	private func updatePeople(_ queries: [String]) {
		do {
			try ctx.transaction {
				for query in queries {
					try ctx.exec(sql: query)
				}
			}
		} catch {
			print(error.localizedDescription)
		}
	}
	
	private func deletePeople() {
		do {
			try ctx.transaction {
				try ctx.exec(sql: "DELETE FROM people")
			}
		} catch {
			print(error.localizedDescription)
		}
	}
	
	// MARK: - Tests
	func testInsert(_ insertQueries: [String]) {
		for i in 0..<numberOfTests {
			let result = BenchmarkRunner.mesureTime {
				insertPeople(insertQueries)
			}
			
			print("(\(i + 1)/\(numberOfTests)) INSERT \(numberOfInstances) instances: \(result) [ns]")
			deletePeople()
		}
	}
	
	func testSelect(_ insertQueries: [String]) {
		for i in 0..<numberOfTests {
			insertPeople(insertQueries)
			
			let result = BenchmarkRunner.mesureTime {
				selectPeople()
			}
			
			print("(\(i + 1)/\(numberOfTests)) SELECT \(numberOfInstances) instances: \(result) [ns]")
			deletePeople()
		}
	}
	
	func testUpdate(_ insertQueries: [String], _ updateQueries: [String]) {
		for i in 0..<numberOfTests {
			insertPeople(insertQueries)
			
			let result = BenchmarkRunner.mesureTime {
				updatePeople(updateQueries)
			}
			
			print("(\(i + 1)/\(numberOfTests)) UPDATE \(numberOfInstances) instances: \(result) [ns]")
			deletePeople()
		}
	}
	
	func testDelete(_ insertQueries: [String]) {
		for i in 0..<numberOfTests {
			insertPeople(insertQueries)
			
			let result = BenchmarkRunner.mesureTime {
				deletePeople()
			}
			
			print("(\(i + 1)/\(numberOfTests)) DELETE \(numberOfInstances) instances \(result) [ns]")
		}
	}
	
	func runDatabaseRamTest(_ insertQueries: [String], _ updateQueries: [String]) {
		for i in 0..<numberOfTests {
			let time = BenchmarkRunner.mesureTime {
				insertPeople(insertQueries)
				selectPeople()
				updatePeople(updateQueries)
				deletePeople()
			}
			let cpuUsage = CPUCalculator.cpuUsage()
			
			print("(\(i + 1)/\(numberOfTests)) DATABASE \(numberOfInstances) instances; \(time) [ns]; \(cpuUsage) [%]")
		}
	}
}
