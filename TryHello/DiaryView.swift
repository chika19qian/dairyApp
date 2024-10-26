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
    var type: String
    var mood: Int
    var events: [String]
    var questions: [String: String]
    let mindfulnessDuration: Double
    let wordCount: Int
    
    let isEvening: Bool? // 可选的布尔值
    
    // 自定义初始化器
    init(date: Date, type: String, mood: Int, events: [String], questions: [String: String], mindfulnessDuration: Double, wordCount: Int, isEvening: Bool?) {
        self.date = date
        self.type = type
        self.mood = mood
        self.events = events
        self.questions = questions
        self.mindfulnessDuration = mindfulnessDuration
        self.wordCount = wordCount
        self.isEvening = isEvening
    }
}


struct DiaryView: View {
    
    @Binding var diaryEntries: [DiaryEntry]
    @State private var selectedDiary: DiaryEntry?
    @State private var showingFullDiary = false
    @State private var showingEditDiary = false
    @State private var showingSearchView = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(diaryEntries) { entry in
                        DiaryCard(entry: entry, onEdit: {
                            selectedDiary = entry
                            showingEditDiary = true
                        })
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
                        showingSearchView = true
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
        .sheet(isPresented: $showingEditDiary) {
            if let index = diaryEntries.firstIndex(where: { $0.id == selectedDiary?.id }) {
                EditDiaryView(diary: binding(for: index), diaryEntries: $diaryEntries)
            }
        }
        .sheet(isPresented: $showingSearchView) {
            SearchView(diaryEntries: diaryEntries)
        }
    }
    
    func getCurrentDate() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM月dd日"
        return formatter.string(from: Date())
    }

    private func binding(for index: Int) -> Binding<DiaryEntry> {
        return Binding(
            get: { self.diaryEntries[index] },
            set: { self.diaryEntries[index] = $0 }
        )
    }
}

struct DiaryCard: View {
    let entry: DiaryEntry
    let onEdit: () -> Void
    
    // 使用 @State 属性包装器，但初始值为 nil
    @State private var selectedAnswer: String?
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text(entry.type)
                    .font(.headline)
                Spacer()
                Text(formattedDate(entry.date))
                    .font(.caption)
                    .foregroundColor(.gray)
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .foregroundColor(.blue)
                }
            }
            
            // 使用 ?? 运算符提供默认值
            Text(selectedAnswer ?? "没有记录")
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
        .onAppear {
            // 只在 selectedAnswer 为 nil 时选择随机答案
            if selectedAnswer == nil {
                selectRandomAnswer()
            }
        }
    }
    
    private func selectRandomAnswer() {
        // 只选择非空的文本答案，排除心情和事件
        let textAnswers = entry.questions.values.filter { !$0.isEmpty }
        selectedAnswer = textAnswers.randomElement() ?? "没有记录"
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
}

struct SearchBar: View {
    @Binding var text: String

    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
            TextField("搜索日记", text: $text)
                .textFieldStyle(RoundedBorderTextFieldStyle())
        }
        .padding(.horizontal)
    }
}

struct EditDiaryView: View {
    @Environment(\.presentationMode) var presentationMode
    @Binding var diary: DiaryEntry
    @Binding var diaryEntries: [DiaryEntry]
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("日记内容")) {
                    ForEach(Array(diary.questions.keys), id: \.self) { question in
                        VStack(alignment: .leading) {
                            Text(question)
                                .font(.headline)
                            TextEditor(text: Binding(
                                get: { self.diary.questions[question] ?? "" },
                                set: { self.diary.questions[question] = $0 }
                            ))
                            .frame(height: 100)
                        }
                    }
                }
                
                Section(header: Text("心情")) {
                    Picker("心情", selection: $diary.mood) {
                        ForEach(1...5, id: \.self) { mood in
                            Text("\(mood)").tag(mood)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }
                
                Section(header: Text("事件")) {
                    ForEach(diary.events.indices, id: \.self) { index in
                        TextField("事件 \(index + 1)", text: $diary.events[index])
                    }
                }
                
                Section {
                    Button("删除日记") {
                        if let index = diaryEntries.firstIndex(where: { $0.id == diary.id }) {
                            diaryEntries.remove(at: index)
                        }
                        presentationMode.wrappedValue.dismiss()
                    }
                    .foregroundColor(.red)
                }
            }
            .navigationBarTitle("编辑日记", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("保存") {
                    if let index = diaryEntries.firstIndex(where: { $0.id == diary.id }) {
                        diaryEntries[index] = diary
                    }
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
}

struct DiaryView_Previews: PreviewProvider {
    static var previews: some View {
        DiaryView(diaryEntries: .constant([]))
    }
}

// 新增的搜索视图
struct SearchView: View {
    @Environment(\.presentationMode) var presentationMode
    let diaryEntries: [DiaryEntry]
    @State private var searchText = ""
    @State private var isSearching = false
    
    var filteredEntries: [DiaryEntry] {
        if searchText.isEmpty {
            return []
        } else {
            return diaryEntries.filter { entry in
                entry.type.localizedCaseInsensitiveContains(searchText) ||
                entry.events.contains { $0.localizedCaseInsensitiveContains(searchText) } ||
                entry.questions.values.contains { $0.localizedCaseInsensitiveContains(searchText) }
            }
        }
    }

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    TextField("搜索日记", text: $searchText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .onSubmit {
                            performSearch()
                        }
                    
                    Button("搜索") {
                        performSearch()
                    }
                }
                .padding()
                
                if isSearching {
                    Text("正在搜索...")
                } else if !searchText.isEmpty && filteredEntries.isEmpty {
                    Text("没有找到相关日记")
                        .foregroundColor(.gray)
                        .padding()
                } else {
                    List(filteredEntries) { entry in
                        VStack(alignment: .leading) {
                            Text(entry.type)
                                .font(.headline)
                            Text(formattedDate(entry.date))
                                .font(.caption)
                        }
                    }
                }
                
                Spacer()
            }
            .navigationBarTitle("搜索", displayMode: .inline)
            .navigationBarItems(trailing: Button("完成") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
    
    private func performSearch() {
        isSearching = true
        // 模拟搜索过程
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            isSearching = false
        }
    }
    
    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: date)
    }
}
