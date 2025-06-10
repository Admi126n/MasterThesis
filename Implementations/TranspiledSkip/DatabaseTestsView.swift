//
//  SwiftUIView.swift
//  transpiled-skip
//
//  Created by Adam Tokarski on 30/03/2025.
//

import SwiftUI

struct DatabaseTestsView: View {
	@State var viewModel: DatabaseViewModel
	
	var body: some View {
		VStack {
			Button("Run database atomic tests") {
				Task {
					let instances  = [1, 10, 100, 1000]
					for instance in instances {
						
						
						let people: [Person] = (0..<instance).map { Person(name: "Hello \($0)") }
						viewModel.numberOfInstances = instance
						let peopleInsert = viewModel.getInsertQueries(for: people)
						let peopleUpdate = viewModel.getUpdateQueries(for: people)
						
						viewModel.testInsert(peopleInsert)
						viewModel.testSelect(peopleInsert)
						viewModel.testUpdate(peopleInsert, peopleUpdate)
						viewModel.testDelete(peopleInsert)
					}
				}
			}
			.buttonStyle(.borderedProminent)
			
			Button("Run full database tests") {
				Task {
					let instances  = [1, 10, 100, 1000]
					for instance in instances {
						let people: [Person] = (0..<instance).map { Person(name: "Hello \($0)") }
						viewModel.numberOfInstances = instance
						let peopleInsert = viewModel.getInsertQueries(for: people)
						let peopleUpdate = viewModel.getUpdateQueries(for: people)
						
						viewModel.runDatabaseRamTest(peopleInsert, peopleUpdate)
					}
				}
			}
			.buttonStyle(.borderedProminent)
		}
		.environment(viewModel)
	}
	
	init(numberOfTests: Int, numberOfInstances: Int) {
		self._viewModel = State(wrappedValue: DatabaseViewModel(numberOfTests: numberOfTests, numberOfInstances: numberOfInstances))
	}
}

#Preview {
	DatabaseTestsView(numberOfTests: 1, numberOfInstances: 1)
}
