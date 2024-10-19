//
//  DiaryView.swift
//  TryHello
//
//  Created by chika on 2024/10/19.
//

import SwiftUI

struct DiaryEntry: Identifiable {
    let id = UUID()
    let date: Date
    let type: String
    let mood: Int
    let events: [String]
    let questions: [String: String]
    let mindfulnessDuration: Double
    let wordCount: Int
}

struct DiaryView: View {
    @Binding var diaryEntries: [DiaryEntry]
    @State private var selectedDiary: DiaryEntry?
    @State private var showingFullDiary = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(diaryEntries) { entry in
                        DiaryCard(entry: entry)
                            .onTapGesture {
                                selectedDiary = entry
                                showingFullDiary = true
                            }
                    }
                }
                .padding()
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    VStack {
                        Text(getCurrentDate())
                            .font(.caption)
                            .foregroundColor(.gray)
                        Text("日记")
                            .font(.headline)
                    }
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: {
                        // 搜索功能
                    }) {
                        Image(systemName: "magnifyingglass")
                    }
                }
            }
        }
        .sheet(isPresented: $showingFullDiary) {
            if let diary = selectedDiary {
                FullDiaryView(diary: diary)
            }
        }
    }
    
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: Date())
    }
}

struct DiaryCard: View {
    let entry: DiaryEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(entry.type)
                    .font(.headline)
                Spacer()
                Text(formattedDate(entry.date))
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text(randomAnswer)
                .font(.body)
                .lineLimit(3)
            
            HStack {
                ForEach(entry.events, id: \.self) { event in
                    Text(event)
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                }
            }
        }
        .padding()
        .frame(height: 150)
        .background(Color.white)
        .cornerRadius(10)
        .shadow(radius: 2)
    }
    
    var randomAnswer: String {
        entry.questions.values.randomElement() ?? "没有记录"
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
}



struct DiaryView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryView(diaryEntries: .constant([]))
    }
}
