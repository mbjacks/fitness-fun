//
//  ImportJSONSheet.swift
//  PersonalFitnessTracker
//

import SwiftUI
import UniformTypeIdentifiers

struct ImportJSONSheet: View {
    // MARK: - Environment
    
    @Environment(\.dismiss) private var dismiss
    
    // MARK: - Binding
    
    @Binding var jsonText: String
    @Binding var errorMessage: String?
    
    // MARK: - State
    
    @State private var showingFilePicker = false
    
    // MARK: - Callbacks
    
    let onImport: (String) -> Void
    let onImportFile: (URL) -> Void
    
    // MARK: - Helper Methods
    
    private func getRecoverySuggestion(for error: String) -> String? {
        if error.contains("malformed") || error.contains("parsed") {
            return "Ensure your JSON follows the correct format with 'name', 'totalDuration', and 'intervals' fields."
        } else if error.contains("already exists") {
            return "Rename the plan in the JSON file before importing, or delete the existing plan first."
        } else if error.contains("invalid data") {
            return "Check that all intervals have positive timestamps, speed, and incline values."
        } else if error.contains("access") {
            return "Make sure the file is accessible and not protected by system restrictions."
        }
        return nil
    }
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // Text editor for pasting JSON
                VStack(alignment: .leading, spacing: 8) {
                    Text("Paste JSON")
                        .font(.headline)
                    
                    TextEditor(text: $jsonText)
                        .font(.system(.body, design: .monospaced))
                        .frame(minHeight: 200)
                        .padding(8)
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(.systemGray4), lineWidth: 1)
                        )
                }
                
                // File picker button
                Button(action: {
                    showingFilePicker = true
                }) {
                    Label("Import from File", systemImage: "doc.badge.plus")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray5))
                        .foregroundColor(.primary)
                        .cornerRadius(10)
                }
                
                // Error message display
                if let error = errorMessage {
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text("Import Error")
                                .font(.headline)
                                .foregroundColor(.red)
                        }
                        
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.primary)
                        
                        if let suggestion = getRecoverySuggestion(for: error) {
                            Divider()
                            Text(suggestion)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .italic()
                        }
                    }
                    .padding()
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color.red.opacity(0.1))
                    .cornerRadius(8)
                }
                
                Spacer()
                
                // Import button
                Button(action: {
                    onImport(jsonText)
                }) {
                    Text("Import JSON")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(jsonText.isEmpty ? Color.gray : Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(jsonText.isEmpty)
            }
            .padding()
            .navigationTitle("Import Exercise Plan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingFilePicker) {
                DocumentPicker(onDocumentPicked: { url in
                    onImportFile(url)
                })
            }
        }
    }
}

// MARK: - Document Picker

struct DocumentPicker: UIViewControllerRepresentable {
    let onDocumentPicked: (URL) -> Void
    
    func makeUIViewController(context: Context) -> UIDocumentPickerViewController {
        let picker = UIDocumentPickerViewController(forOpeningContentTypes: [.json], asCopy: true)
        picker.delegate = context.coordinator
        picker.allowsMultipleSelection = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIDocumentPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(onDocumentPicked: onDocumentPicked)
    }
    
    class Coordinator: NSObject, UIDocumentPickerDelegate {
        let onDocumentPicked: (URL) -> Void
        
        init(onDocumentPicked: @escaping (URL) -> Void) {
            self.onDocumentPicked = onDocumentPicked
        }
        
        func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
            guard let url = urls.first else { return }
            onDocumentPicked(url)
        }
    }
}

// MARK: - Preview

#Preview {
    ImportJSONSheet(
        jsonText: .constant(""),
        errorMessage: .constant(nil),
        onImport: { _ in },
        onImportFile: { _ in }
    )
}
