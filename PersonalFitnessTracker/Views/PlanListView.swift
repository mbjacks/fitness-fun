//
//  PlanListView.swift
//  PersonalFitnessTracker
//

import SwiftUI

struct PlanListView: View {
    // MARK: - ViewModel
    
    @StateObject private var viewModel: PlanListViewModel
    
    // MARK: - State
    
    @State private var jsonText = ""
    @State private var showingActionSheet = false
    @State private var showingErrorAlert = false
    @State private var errorAlertMessage = ""
    
    // MARK: - Initialization
    
    init(viewModel: PlanListViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            ZStack {
                if viewModel.plans.isEmpty {
                    emptyStateView
                } else {
                    planListView
                }
            }
            .navigationTitle("Exercise Plans")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: {
                        showingActionSheet = true
                    }) {
                        Image(systemName: "plus")
                    }
                }
            }
            .confirmationDialog("Import Exercise Plan", isPresented: $showingActionSheet) {
                Button("Paste JSON") {
                    jsonText = ""
                    viewModel.importError = nil
                    viewModel.showingImportSheet = true
                }
                
                Button("Import from File") {
                    // This will be handled by the ImportJSONSheet
                    jsonText = ""
                    viewModel.importError = nil
                    viewModel.showingImportSheet = true
                }
                
                Button("Cancel", role: .cancel) {}
            }
            .sheet(isPresented: $viewModel.showingImportSheet) {
                ImportJSONSheet(
                    jsonText: $jsonText,
                    errorMessage: $viewModel.importError,
                    onImport: { json in
                        viewModel.importFromJSON(string: json)
                    },
                    onImportFile: { url in
                        viewModel.importFromFile(url: url)
                    }
                )
            }
            .alert("Operation Failed", isPresented: $showingErrorAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(errorAlertMessage)
            }
            .onChange(of: viewModel.importError) { newError in
                if let error = newError, !viewModel.showingImportSheet {
                    errorAlertMessage = error
                    showingErrorAlert = true
                }
            }
        }
    }
    
    // MARK: - Empty State View
    
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "figure.run")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            
            Text("No Exercise Plans")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Import a plan to get started with your workouts")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            Button(action: {
                showingActionSheet = true
            }) {
                Label("Import Plan", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .padding()
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding(.top)
        }
    }
    
    // MARK: - Plan List View
    
    private var planListView: some View {
        List {
            ForEach(viewModel.plans) { plan in
                NavigationLink(destination: PlanDetailView(plan: plan)) {
                    PlanRowView(plan: plan)
                }
            }
            .onDelete(perform: deletePlans)
        }
    }
    
    // MARK: - Helper Methods
    
    private func deletePlans(at offsets: IndexSet) {
        for index in offsets {
            let plan = viewModel.plans[index]
            viewModel.deletePlan(id: plan.id)
        }
    }
}

// MARK: - Plan Row View

struct PlanRowView: View {
    let plan: ExercisePlan
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(plan.name)
                .font(.headline)
            
            HStack {
                Label(formatDuration(plan.totalDuration), systemImage: "clock")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Text("\(plan.intervals.count) intervals")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
    
    private func formatDuration(_ duration: TimeInterval) -> String {
        let minutes = Int(duration) / 60
        let seconds = Int(duration) % 60
        
        if seconds == 0 {
            return "\(minutes) min"
        } else {
            return "\(minutes):\(String(format: "%02d", seconds))"
        }
    }
}

// MARK: - Preview

#Preview {
    let repository = try! FileManagerPlanRepository()
    let viewModel = PlanListViewModel(repository: repository)
    return PlanListView(viewModel: viewModel)
}
