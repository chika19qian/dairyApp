//
//  MorningReflectionView.swift
//  TryHello
//
//  Created by chika on 2024/10/19.
//
import SwiftUI

struct MorningReflectionView: View {
    @Binding var isPresented: Bool
    var addDiaryEntry: (DiaryEntry) -> Void
    
    @State private var currentStep = 1
    @State private var sleepQuality = -1
    @State private var selectedEvents: Set<String> = []
    @State private var learningReflection = ""
    @State private var learningPlan = ""
    @State private var positiveFeelings = ""
    
    let events = [
        "📖 学习", "💼 工作", "❤️ 恋人", "🍲 食物", "🏃‍♂️ 运动",
        "🎵 音乐", "🎨 艺术", "👫 社交", "🌳 自然", "📱 科技",
        "💤 睡眠", "🧘‍♀️ 冥想"
    ]
    
    var body: some View {
        NavigationView {
            VStack {
                switch currentStep {
                case 1:
                    sleepQualityView
                case 2:
                    focusEventView
                case 3:
                    learningReflectionView
                case 4:
                    learningPlanView
                case 5:
                    positiveFeelingsView
                default:
                    Text("完成")
                }
                
                Spacer()
                
                if currentStep < 5 {
                    Button(action: {
                        if currentStep == 1 && sleepQuality == -1 {
                            return
                        }
                        currentStep += 1
                    }) {
                        Text("下一步")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(currentStep == 1 && sleepQuality == -1 ? Color.gray : Color.blue)
                            .cornerRadius(10)
                    }
                    .disabled(currentStep == 1 && sleepQuality == -1)
                    .padding()
                } else {
                    Button(action: {
                        saveReflection()
                    }) {
                        Text("完成")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                }
            }
            .navigationBarTitle("早安反思", displayMode: .inline)
            .navigationBarItems(
                leading: Button(action: {
                    if currentStep > 1 {
                        currentStep -= 1
                    } else {
                        isPresented = false
                    }
                }) {
                    Image(systemName: "chevron.left")
                },
                trailing: Text("\(currentStep)/5")
            )
        }
    }
    
    var sleepQualityView: some View {
        VStack(spacing: 20) {
            Text("昨晚睡眠感觉如何？")
                .font(.title2)
            
            HStack {
                ForEach(1..<6) { index in
                    Button(action: {
                        sleepQuality = index
                    }) {
                        Image(systemName: index <= sleepQuality ? "moon.stars.fill" : "moon.stars")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.yellow)
                    }
                }
            }
            if sleepQuality != -1 {
                Text("睡眠评分: \(sleepQuality)/5")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
    
    var focusEventView: some View {
        VStack(spacing: 20) {
            Text("今天专注在什么事情上？")
                .font(.title2)
            
            Text("最多选择3个")
                .font(.caption)
                .foregroundColor(.gray)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 20) {
                ForEach(events, id: \.self) { event in
                    Button(action: {
                        if selectedEvents.contains(event) {
                            selectedEvents.remove(event)
                        } else if selectedEvents.count < 3 {
                            selectedEvents.insert(event)
                        }
                    }) {
                        Text(event)
                            .padding()
                            .background(selectedEvents.contains(event) ? Color.blue.opacity(0.2) : Color.gray.opacity(0.1))
                            .cornerRadius(10)
                    }
                    .disabled(!selectedEvents.contains(event) && selectedEvents.count >= 3)
                }
            }
        }
        .padding()
    }
    
    var learningReflectionView: some View {
        VStack(spacing: 20) {
            Text("关于以下事情，你有什么美好的回忆？")
                .font(.title2)
            
            HStack {
                ForEach(Array(selectedEvents), id: \.self) { event in
                    Text(event)
                        .font(.headline)
                }
            }
            
            TextEditor(text: $learningReflection)
                .frame(height: 150)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
        .padding()
    }
    
    var learningPlanView: some View {
        VStack(spacing: 20) {
            Text("今天关于以下事情的计划是什么？")
                .font(.title2)
            
            HStack {
                ForEach(Array(selectedEvents), id: \.self) { event in
                    Text(event)
                        .font(.headline)
                }
            }
            
            TextEditor(text: $learningPlan)
                .frame(height: 150)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
        .padding()
    }
    
    var positiveFeelingsView: some View {
        VStack(spacing: 20) {
            Text("如果今天收获满满，并有意外惊喜，你会有什么感受？")
                .font(.title2)
            
            TextEditor(text: $positiveFeelings)
                .frame(height: 150)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
        .padding()
    }
    
    private func saveReflection() {
        let wordCount = learningReflection.count + learningPlan.count + positiveFeelings.count
        
        let newEntry = DiaryEntry(
            date: Date(),
            type: "早安日记",
            mood: sleepQuality,
            events: Array(selectedEvents),
            questions: [
                "昨晚睡眠感觉如何？": "\(sleepQuality)/5",
                "今天专注在什么事情上？": Array(selectedEvents).joined(separator: ", "),
                "关于以下事情，你有什么美好的回忆？": learningReflection,
                "今天关于以下事情的计划是什么？": learningPlan,
                "如果今天收获满满，并有意外惊喜，你会有什么感受？": positiveFeelings
            ],
            mindfulnessDuration: 0.0,  // 这里可以添加计时功能
            wordCount: wordCount
        )
        
        addDiaryEntry(newEntry)
        
        // 重置所有状态
        currentStep = 1
        sleepQuality = -1
        selectedEvents.removeAll()
        learningReflection = ""
        learningPlan = ""
        positiveFeelings = ""
        
        // 关闭反思视图
        isPresented = false
    }
}

struct MorningReflectionView_Previews: PreviewProvider {
    static var previews: some View {
        MorningReflectionView(isPresented: .constant(true), addDiaryEntry: { _ in })
    }
}