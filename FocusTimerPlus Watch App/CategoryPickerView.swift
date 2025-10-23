import SwiftUI

struct CategoryPickerView: View {
    @Binding var selectedCategory: FocusCategory
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        List {
            ForEach(FocusCategory.allCases) { cat in
                Button {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        selectedCategory = cat
                    }
                    WKInterfaceDevice.current().play(.click)
                    dismiss() // ← автоматический возврат на главный экран
                } label: {
                    HStack(spacing: 8) {
                        Text(cat.icon)
                            .font(.title2)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(cat.rawValue)
                                .font(.body.bold())
                            Text(cat.description)
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                        }
                        Spacer()
                        if cat == selectedCategory {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(cat.colorGradient.first!)
                        }
                    }
                    .padding(4)
                }
            }
        }
        .navigationTitle("Focus Type")
    }
}
