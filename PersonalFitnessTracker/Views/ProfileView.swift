//
//  ProfileView.swift
//  PersonalFitnessTracker
//

import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel: ProfileViewModel
    @State private var heightFeet: String = ""
    @State private var heightInches: String = ""
    @State private var heightCentimeters: String = ""
    @State private var weightPounds: String = ""
    @State private var weightKilograms: String = ""
    @State private var showingSaveConfirmation = false
    @State private var showingSaveError = false
    @State private var saveErrorMessage: String = ""
    
    init(viewModel: ProfileViewModel = ProfileViewModel()) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        NavigationView {
            Form {
                // Unit System Section
                Section(header: Text("Unit System")) {
                    Picker("Unit System", selection: $viewModel.profile.unitSystem) {
                        Text("Metric").tag(UnitSystem.metric)
                        Text("Imperial").tag(UnitSystem.imperial)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: viewModel.profile.unitSystem) {
                        viewModel.toggleUnitSystem()
                        updateLocalFields()
                    }
                }
                
                // Personal Information Section
                Section(header: Text("Personal Information")) {
                    // Age Input
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text("Age")
                            if viewModel.validationErrors["age"] != nil {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .foregroundColor(.red)
                                    .font(.caption)
                            }
                            Spacer()
                            TextField("Age", value: $viewModel.profile.age, format: .number)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 100)
                        }
                        
                        if let error = viewModel.validationErrors["age"] {
                            HStack(spacing: 4) {
                                Image(systemName: "info.circle.fill")
                                    .font(.caption2)
                                Text(error)
                                    .font(.caption)
                            }
                            .foregroundColor(.red)
                        }
                    }
                    
                    // Sex Picker
                    Picker("Sex", selection: $viewModel.profile.sex) {
                        Text("Male").tag(Sex.male)
                        Text("Female").tag(Sex.female)
                    }
                }
                
                // Height Section
                Section(header: Text("Height")) {
                    if viewModel.profile.unitSystem == .metric {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Centimeters")
                                if viewModel.validationErrors["height"] != nil {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                                Spacer()
                                TextField("cm", text: $heightCentimeters)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                    .onChange(of: heightCentimeters) {
                                        if let cm = Double(heightCentimeters) {
                                            viewModel.profile.height = Height(centimeters: cm)
                                        }
                                    }
                            }
                            
                            if let error = viewModel.validationErrors["height"] {
                                HStack(spacing: 4) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.caption2)
                                    Text(error)
                                        .font(.caption)
                                }
                                .foregroundColor(.red)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Feet")
                                if viewModel.validationErrors["height"] != nil {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                                Spacer()
                                TextField("ft", text: $heightFeet)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 60)
                                    .onChange(of: heightFeet) {
                                        updateHeightFromImperial()
                                    }
                            }
                            
                            HStack {
                                Text("Inches")
                                Spacer()
                                TextField("in", text: $heightInches)
                                    .keyboardType(.numberPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 60)
                                    .onChange(of: heightInches) {
                                        updateHeightFromImperial()
                                    }
                            }
                            
                            if let error = viewModel.validationErrors["height"] {
                                HStack(spacing: 4) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.caption2)
                                    Text(error)
                                        .font(.caption)
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                // Weight Section
                Section(header: Text("Weight")) {
                    if viewModel.profile.unitSystem == .metric {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Kilograms")
                                if viewModel.validationErrors["weight"] != nil {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                                Spacer()
                                TextField("kg", text: $weightKilograms)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                    .onChange(of: weightKilograms) {
                                        if let kg = Double(weightKilograms) {
                                            viewModel.profile.weight = Weight(kilograms: kg)
                                        }
                                    }
                            }
                            
                            if let error = viewModel.validationErrors["weight"] {
                                HStack(spacing: 4) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.caption2)
                                    Text(error)
                                        .font(.caption)
                                }
                                .foregroundColor(.red)
                            }
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("Pounds")
                                if viewModel.validationErrors["weight"] != nil {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                                Spacer()
                                TextField("lbs", text: $weightPounds)
                                    .keyboardType(.decimalPad)
                                    .multilineTextAlignment(.trailing)
                                    .frame(width: 100)
                                    .onChange(of: weightPounds) {
                                        if let lbs = Double(weightPounds) {
                                            viewModel.profile.weight = Weight(pounds: lbs)
                                        }
                                    }
                            }
                            
                            if let error = viewModel.validationErrors["weight"] {
                                HStack(spacing: 4) {
                                    Image(systemName: "info.circle.fill")
                                        .font(.caption2)
                                    Text(error)
                                        .font(.caption)
                                }
                                .foregroundColor(.red)
                            }
                        }
                    }
                }
                
                // Optional Fields Section
                Section(header: Text("Optional Information")) {
                    HStack {
                        Text("Resting Heart Rate")
                        Spacer()
                        TextField("bpm", value: $viewModel.profile.restingHeartRate, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    HStack {
                        Text("Desired Exercise Time")
                        Spacer()
                        TextField("minutes", value: $viewModel.profile.desiredExerciseTime, format: .number)
                            .keyboardType(.numberPad)
                            .multilineTextAlignment(.trailing)
                            .frame(width: 100)
                    }
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Exercise Goals")
                        TextEditor(text: Binding(
                            get: { viewModel.profile.exerciseGoals ?? "" },
                            set: { viewModel.profile.exerciseGoals = $0.isEmpty ? nil : $0 }
                        ))
                        .frame(minHeight: 80)
                    }
                }
                
                // Save Button Section
                Section {
                    Button(action: {
                        viewModel.saveProfile()
                        if let saveError = viewModel.validationErrors["save"] {
                            saveErrorMessage = saveError
                            showingSaveError = true
                        } else if viewModel.validationErrors.isEmpty {
                            showingSaveConfirmation = true
                        }
                    }) {
                        HStack {
                            Spacer()
                            Text("Save Profile")
                                .fontWeight(.semibold)
                            Spacer()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    
                    if let error = viewModel.validationErrors["save"] {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("Profile")
            .onAppear {
                updateLocalFields()
            }
            .alert("Profile Saved", isPresented: $showingSaveConfirmation) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your profile has been saved successfully.")
            }
            .alert("Save Failed", isPresented: $showingSaveError) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(saveErrorMessage)
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func updateLocalFields() {
        // Update height fields
        if viewModel.profile.unitSystem == .metric {
            heightCentimeters = String(format: "%.1f", viewModel.profile.height.centimeters)
        } else {
            let (feet, inches) = viewModel.profile.height.inFeetAndInches
            heightFeet = String(feet)
            heightInches = String(inches)
        }
        
        // Update weight fields
        if viewModel.profile.unitSystem == .metric {
            weightKilograms = String(format: "%.1f", viewModel.profile.weight.kilograms)
        } else {
            weightPounds = String(format: "%.1f", viewModel.profile.weight.inPounds)
        }
    }
    
    private func updateHeightFromImperial() {
        if let feet = Int(heightFeet), let inches = Int(heightInches) {
            viewModel.profile.height = Height(feet: feet, inches: inches)
        }
    }
}

#Preview {
    ProfileView()
}
