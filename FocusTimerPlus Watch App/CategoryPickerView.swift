//
//  CategoryPickerView.swift
//  FocusTimerPlus Watch App
//
//  Created by Irina Saf on 2025-10-22.
//

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
                    HStack {
                        Text(cat.icon)
                            .font(.title3)
                        Text(cat.rawValue)
                            .font(.body)
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


#Preview {
    @State var previewCategory: FocusCategory = .work
    return CategoryPickerView(selectedCategory: $previewCategory)
}
