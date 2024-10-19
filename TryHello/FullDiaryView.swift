//
//  FullDiaryView.swift
//  TryHello
//
//  Created by chika on 2024/10/19.
//

import SwiftUI

struct FullDiaryView: View {
    let diary: DiaryEntry
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // 顶部
                HStack {
                    Spacer()
                    Text("日记详情")
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
                
                // 日记基本信息
                HStack {
                    VStack(alignment: .leading) {
                        Text(diary.type)
                            .font(.headline)
                        Text(formattedDate(diary.date))
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    VStack(alignment: .trailing) {
                        Text("正念时长: \(String(format: "%.1f", diary.mindfulnessDuration))分钟")
                            .font(.subheadline)
                        Text("正念字数: \(diary.wordCount)个")
                            .font(.subheadline)
                    }
                }
                
                // 早安日记内容
                if diary.type == "早安日记" {
                    Text("昨晚睡眠感觉如何？")
                        .font(.headline)
                    Text("\(diary.questions["昨晚睡眠感觉如何？"] ?? "")")
                        .font(.body)
                    
                    Text("今天专注在什么事情上？")
                        .font(.headline)
                    Text("\(diary.questions["今天专注在什么事情上？"] ?? "")")
                        .font(.body)
                    
                    Text("关于以下事情，你有什么美好的回忆？")
                        .font(.headline)
                    Text("\(diary.questions["关于以下事情，你有什么美好的回忆？"] ?? "")")
                        .font(.body)
                    
                    Text("今天关于以下事情的计划是什么？")
                        .font(.headline)
                    Text("\(diary.questions["今天关于以下事情的计划是什么？"] ?? "")")
                        .font(.body)
                    
                    Text("如果今天收获满满，并有意外惊喜，你会有什么感受？")
                        .font(.headline)
                    Text("\(diary.questions["如果今天收获满满，并有意外惊喜，你会有什么感受？"] ?? "")")
                        .font(.body)
                }
                
                // 晚安日记内容
                if diary.type == "晚安日记" {
                    Text("今天感觉如何？")
                        .font(.headline)
                    HStack {
                        ForEach(0..<5) { index in
                            Image(systemName: index < diary.mood ? "star.fill" : "star")
                                .foregroundColor(.yellow)
                        }
                        Text("\(diary.mood)/5")
                    }
                    
                    Text("今天在什么事情上感觉不错？")
                        .font(.headline)
                    HStack {
                        ForEach(diary.events, id: \.self) { event in
                            Label(event, systemImage: iconForEvent(event))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(10)
                        }
                    }
                    
                    // 其他问题和回答
                    ForEach(Array(diary.questions.keys.sorted()), id: \.self) { question in
                        Text(question)
                            .font(.headline)
                        Text(diary.questions[question] ?? "")
                            .font(.body)
                    }
                }
            }
            .padding()
        }
        .navigationBarTitle("日记详情", displayMode: .inline)
    }
    
    func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd HH:mm"
        return formatter.string(from: date)
    }
    
    func iconForEvent(_ event: String) -> String {
        switch event {
        case "📖 学习": return "book.fill"
        case "💼 工作": return "briefcase.fill"
        case "❤️ 恋人": return "heart.fill"
        case "🍲 食物": return "fork.knife"
        case "🏃‍♂️ 运动": return "figure.walk"
        case "🎵 音乐": return "music.note"
        case "🎨 艺术": return "paintbrush"
        case "👫 社交": return "person.3.fill"
        case "🌳 自然": return "leaf.fill"
        case "📱 科技": return "iphone"
        case "💤 睡眠": return "bed.double.fill"
        case "🧘‍♀️ 冥想": return "person.fill"
        default: return "questionmark"
        }
    }
}

struct FullDiaryView_Previews: PreviewProvider {
    static var previews: some View {
        FullDiaryView(diary: DiaryEntry(date: Date(), type: "早安日记", mood: 4, events: ["📖 学习"], questions: ["昨晚睡眠感觉如何？": "3/5", "今天专注在什么事情上？": "📖 学习", "关于以下事情，你有什么美好的回忆？": "我很开心", "今天关于以下事情的计划是什么？": "继续学习", "如果今天收获满满，并有意外惊喜，你会有什么感受？": "很期待"], mindfulnessDuration: 0.0, wordCount: 50))
    }
}
