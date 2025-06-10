//
//  JSONTestsView.swift
//  transpiled-skip
//
//  Created by Adam Tokarski on 30/03/2025.
//

import SwiftUI

struct JSONTestsView: View {
	
	@State var viewModel: JSONViewModel
	
	let files = ["API_33462"]
	
	var body: some View {
		VStack {
			Button("Run JSON tests") {
				for file in files {
					viewModel.encodeTest(file)
					viewModel.decodeTest(file)
				}
			}
			.buttonStyle(.borderedProminent)
			.tint(.green)
		}
	}
	
	init(numberOfTests: Int) {
		self.viewModel = JSONViewModel(numberOfTests: numberOfTests)
	}
}

#Preview {
	return JSONTestsView(numberOfTests: 1)
}
