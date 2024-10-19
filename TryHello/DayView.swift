 import SwiftUI

struct DateSelectionView: View { // 重命名为 DateSelectionView
    var date: Date
    var isSelected: Bool
    var isCompleted: Bool

    var body: some View {
        VStack {
            Text(dateFormatter.string(from: date))
                .font(.headline)
                .foregroundColor(isSelected ? .blue : .black)
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
        }
        .padding()
        .background(isSelected ? Color.blue.opacity(0.2) : Color.clear)
        .cornerRadius(10)
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd" // 只显示日期
        return formatter
    }
}