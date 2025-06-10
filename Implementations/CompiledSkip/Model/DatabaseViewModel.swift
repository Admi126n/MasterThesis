import Foundation
import Observation
import SkipFuse
import SQLiteDB

public struct Person: Identifiable, Hashable, Codable {
	public var id = UUID()
	public var name: String
	
	public init(name: String) {
		self.id = UUID()
		self.name = name
	}
}

public struct DatabaseViewModel {
	
	public let numberOfTests: Int
	public let numberOfInstances: Int
	
	let allColumns: [any Expressible] = [
		Table("people")[SQLExpression<UUID>("id")],
		Table("people")[SQLExpression<String>("name")]
	]
	
	let dbPath = URL.applicationSupportDirectory.appendingPathComponent("compiledSkip.sqlite")
	let tableName = "people"
	
	var db: Connection
	
	public init(numberOfTests: Int, numberOfInstances: Int) {
		self.numberOfTests = numberOfTests
		self.numberOfInstances = numberOfInstances
		
		do {
			try FileManager.default.createDirectory(at: dbPath.deletingLastPathComponent(), withIntermediateDirectories: true)
			self.db = try Connection(self.dbPath.path)
			print("Connected")
			
			createSchema()
		} catch {
			print(error.localizedDescription)
			fatalError("Cannot init db")
		}
		
	}
	
	private func createSchema() {
		do {
			try db.run(Table(tableName).create { builder in
				builder.column(SQLExpression<UUID>("id"), primaryKey: true)
				builder.column(SQLExpression<String>("name"))
			})
			
			print("Database created")
		} catch {
			print(error.localizedDescription)
		}
	}
	
	public func insertPeople(_ people: [Person]) {
		do {
			try db.transaction {
				for person in people {
					try db.run(Table(tableName).insert(person))
				}
			}
		} catch {
			print(error.localizedDescription)
		}
	}
	
	public func selectPeople() {
		do {
			let query = Table(tableName).select(allColumns)
			let _: [Person] = try db.prepare(query).map { try $0.decode() }
		} catch {
			print(error.localizedDescription)
		}
	}
	
	public func updatePeople(_ people: [Person]) {
		do {
			try db.transaction {
				for person in people {
					let query = Table(tableName).filter(person.name == SQLExpression<String>("name"))
					try db.run(query.update(Person(name: "hello")))
				}
			}
		} catch {
			print(error.localizedDescription)
		}
	}
	
	public func deletePeople() {
		do {
			let query = Table(tableName).select(allColumns)
			try db.run(query.delete())
		} catch {
			print(error.localizedDescription)
		}
	}
}
