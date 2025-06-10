import SwiftUI

struct ContentView: View {
	var body: some View {
		VStack {
			DatabaseTestsView(numberOfTests: 110, numberOfInstances: 1)
			
			JSONTestsView(numberOfTests: 110)
			
			BenchmarksView(numberOfTests: 110,
						   fannkuchRedux: 8,
						   fasta: 100_000,
						   nBody: 100_000,
						   reverseComplement: 100_000)
		}
	}
}
