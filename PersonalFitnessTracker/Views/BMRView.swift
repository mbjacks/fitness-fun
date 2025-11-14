//
//  BMRView.swift
//  PersonalFitnessTracker
//

import SwiftUI

struct BMRView: View {
    @StateObject private var viewModel = BMRViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // BMR Display Section
                VStack(spacing: 10) {
                    Text("Your Basal Metabolic Rate")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                    if viewModel.bmrValue > 0 {
                        Text("\(viewModel.bmrValue)")
                            .font(.system(size: 72, weight: .bold, design: .rounded))
                            .foregroundColor(.primary)
                        
                        Text("calories per day")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    } else {
                        VStack(spacing: 15) {
                            ProgressView()
                                .scaleEffect(1.5)
                            
                            Text("Calculating...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 100)
                    }
                }
                .padding(.top, 40)
                
                // Formula Picker Section
                VStack(alignment: .leading, spacing: 15) {
                    Text("Calculation Formula")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    Picker("Formula", selection: $viewModel.selectedFormula) {
                        Text("Mifflin-St Jeor").tag(BMRFormula.mifflinStJeor)
                        Text("Harris-Benedict").tag(BMRFormula.harrisBenedict)
                        Text("Katch-McArdle").tag(BMRFormula.katchMcArdle)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .onChange(of: viewModel.selectedFormula) { newFormula in
                        viewModel.updateFormula(newFormula)
                    }
                    
                    // Formula descriptions
                    VStack(alignment: .leading, spacing: 8) {
                        switch viewModel.selectedFormula {
                        case .mifflinStJeor:
                            Text("Mifflin-St Jeor (Recommended)")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Most accurate for general population. Based on weight, height, age, and sex.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        case .harrisBenedict:
                            Text("Harris-Benedict")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Classic formula revised in 1984. Similar to Mifflin-St Jeor but may slightly overestimate.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        case .katchMcArdle:
                            Text("Katch-McArdle")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                            Text("Based on lean body mass estimation. Good for athletic individuals.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                }
                
                Spacer()
                
                // Info Section
                VStack(spacing: 8) {
                    Text("What is BMR?")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    
                    Text("BMR is the number of calories your body burns at rest. Update your profile to recalculate.")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                .padding(.bottom, 20)
            }
            .navigationTitle("BMR Calculator")
        }
    }
}

#Preview {
    BMRView()
}
