import SwiftUI
import SwiftData

struct ScanView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = ScanViewModel()
    @State private var cameraPermissionDenied = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if viewModel.isCameraActive {
                    cameraSection
                }

                resultSection
            }
            .navigationTitle(String(localized: "scan.title"))
            .navigationBarTitleDisplayMode(.inline)
            .onDisappear {
                viewModel.reset()
            }
        }
    }

    private var cameraSection: some View {
        ZStack {
            if cameraPermissionDenied {
                cameraPermissionView
            } else {
                CameraPreviewView(
                    onBarcodeDetected: { barcode in
                        viewModel.processBarcodeResult(barcode, context: modelContext)
                    },
                    onTextDetected: { text in
                        viewModel.processOCRResults(text)
                    },
                    onPermissionDenied: {
                        cameraPermissionDenied = true
                    }
                )
                .frame(height: 300)
                .clipShape(RoundedRectangle(cornerRadius: 16))
                .padding()
            }

            VStack {
                Spacer()
                HStack {
                    if viewModel.detectedBarcode != nil {
                        Label("Barcode", systemImage: "checkmark.circle.fill")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.green.opacity(0.9))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                    if viewModel.selectedDate != nil {
                        Label(String(localized: "scan.date_detected"), systemImage: "checkmark.circle.fill")
                            .font(.caption.bold())
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(.green.opacity(0.9))
                            .foregroundStyle(.white)
                            .clipShape(Capsule())
                    }
                }
                .padding(.bottom, 24)
            }
        }
    }

    private var cameraPermissionView: some View {
        VStack(spacing: 12) {
            Image(systemName: "camera.fill")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text(String(localized: "scan.camera_permission.title"))
                .font(.headline)
            Text(String(localized: "scan.camera_permission.message"))
                .font(.caption)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
            Button(String(localized: "scan.camera_permission.open_settings")) {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(.green)
        }
        .frame(height: 300)
        .frame(maxWidth: .infinity)
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .padding()
    }

    private var resultSection: some View {
        ScrollView {
            VStack(spacing: 16) {
                Text(String(localized: "scan.result"))
                    .font(.headline)
                    .frame(maxWidth: .infinity, alignment: .leading)

                // Product name
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "scan.product_name"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    TextField(String(localized: "scan.product_name.placeholder"), text: $viewModel.productName)
                        .textFieldStyle(.roundedBorder)
                }

                // Expiry date
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "scan.expiry_date"))
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    if viewModel.detectedDates.count > 1 {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(viewModel.detectedDates, id: \.self) { date in
                                    Button {
                                        viewModel.selectedDate = date
                                    } label: {
                                        Text(date.formatted(date: .numeric, time: .omitted))
                                            .padding(.horizontal, 12)
                                            .padding(.vertical, 6)
                                            .background(viewModel.selectedDate == date ? Color.green : Color(.systemGray6))
                                            .foregroundStyle(viewModel.selectedDate == date ? .white : .primary)
                                            .clipShape(Capsule())
                                    }
                                }
                            }
                        }
                    } else {
                        DatePicker(
                            "",
                            selection: Binding(
                                get: { viewModel.selectedDate ?? .now },
                                set: { viewModel.selectedDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                        .labelsHidden()
                    }
                }

                // Storage location
                VStack(alignment: .leading, spacing: 4) {
                    Text(String(localized: "scan.storage"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    HStack(spacing: 8) {
                        ForEach(StorageLocation.allCases) { location in
                            FilterChipView(
                                title: location.displayName,
                                isSelected: viewModel.storageLocation == location
                            ) {
                                viewModel.storageLocation = location
                            }
                        }
                    }
                }

                // Quantity
                HStack {
                    Text(String(localized: "scan.quantity"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    HStack(spacing: 16) {
                        Button { if viewModel.quantity > 1 { viewModel.quantity -= 1 } } label: {
                            Image(systemName: "minus.circle")
                                .font(.title3)
                        }
                        .accessibilityLabel(String(localized: "accessibility.decrease_quantity"))
                        Text("\(viewModel.quantity)")
                            .font(.title3.bold())
                            .frame(minWidth: 30)
                        Button { if viewModel.quantity < 99 { viewModel.quantity += 1 } } label: {
                            Image(systemName: "plus.circle")
                                .font(.title3)
                        }
                        .accessibilityLabel(String(localized: "accessibility.increase_quantity"))
                    }
                }

                // Register button
                Button {
                    viewModel.registerItem(context: modelContext)
                } label: {
                    Text(String(localized: "scan.register"))
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(viewModel.canRegister ? Color.green : Color.gray)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!viewModel.canRegister)

                // Continuous scan toggle
                Toggle(String(localized: "scan.continuous"), isOn: $viewModel.continuousScanMode)
                    .tint(.green)
            }
            .padding()
        }
    }
}

#Preview {
    ScanView()
        .modelContainer(for: [FoodItem.self, BarcodeProduct.self, ConsumptionLog.self], inMemory: true)
}
