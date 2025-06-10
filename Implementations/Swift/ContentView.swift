//
//  ContentView.swift
//  SwiftApp
//
//  Created by Adam Tokarski on 17/03/2025.
//

import SwiftUI

struct ContentView: View {
	var body: some View {
		VStack {
			DatabaseTestsView(numberOfTests: 100, numberOfInstances: 1_000)
			
			JSONTestsView(numberOfTests: 110)
			
			BenchmarksView(numberOfTests: 110,
						   fannkuchRedux: 8,
						   fasta: 100_000,
						   nBody: 100_000,
						   reverseComplement: 100_000)
		}
	}
}

#Preview {
	return ContentView()
}
