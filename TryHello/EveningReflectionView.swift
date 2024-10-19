//
//  NightWritingView.swift
//  TryHello
//
//  Created by chika on 2024/10/19.
//

import SwiftUI

struct EveningReflectionView: View {
    @Binding var isPresented: Bool
    @Binding var lastReflectionSummary: String
    var addDiaryEntry: (DiaryEntry) -> Void // 确保这里有这个参数
    @State private var currentStep = 1
    @State private var selectedMood = -1
    @State private var selectedEvents: Set<String> = []
    @State private var reflectionAnswer = ""
    @State private var rewardAnswer = ""
    @State private var futureVisionAnswer = ""
    
    let events = ["📖 学习", "💼 工作", "❤️ 恋人", "🍲 食物", "🏃‍♂️ 运动", "🎵 音乐", "🎨 艺术", "👫 社交", "🌳 自然", "📱 科技", "💤 睡眠", "🧘‍♀️ 冥想"]
    
    var body: some View {
        NavigationView {
            VStack {
                switch currentStep {
                case 1:
                    moodSelectionView
                case 2:
                    eventSelectionView
                case 3:
                    personalizedQuestionView
                case 4:
                    rewardQuestionView
                case 5:
                    futureVisionView
                default:
                    Text("完成")
                }
                
                Spacer()
                
                if currentStep < 5 {
                    Button(action: {
                        currentStep += 1
                    }) {
                        Text("下一步")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(10)
                    }
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
            .navigationBarTitle("晚安反思", displayMode: .inline)
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
    
    var moodSelectionView: some View {
        VStack(spacing: 20) {
            Text("今天感觉如何？")
                .font(.title2)
            
            HStack {
                ForEach(1..<6) { index in
                    Button(action: {
                        selectedMood = index
                    }) {
                        Image(systemName: index <= selectedMood ? "star.fill" : "star")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 50, height: 50)
                            .foregroundColor(.yellow)
                    }
                }
            }
            if selectedMood != -1 {
                Text("评分: \(selectedMood)/5")
                    .font(.headline)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }
    
    var eventSelectionView: some View {
        VStack(spacing: 20) {
            Text("今天在什么事情上感觉不错？")
                .font(.title2)
            
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
    
    var personalizedQuestionView: some View {
        VStack(spacing: 20) {
            Text("关于今天的这些事情，为什么让你觉得不错？")
                .font(.title2)
            
            TextEditor(text: $reflectionAnswer)
                .frame(height: 150)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
        .padding()
    }
    
    var rewardQuestionView: some View {
        VStack(spacing: 20) {
            Text("Cool！你会如何奖励自己？")
                .font(.title2)
            
            TextEditor(text: $rewardAnswer)
                .frame(height: 150)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
        .padding()
    }
    
    var futureVisionView: some View {
        VStack(spacing: 20) {
            Text("如果你可以看到未来，希望看到自己因为这些事情有什么变化？")
                .font(.title2)
            
            TextEditor(text: $futureVisionAnswer)
                .frame(height: 150)
                .padding()
                .background(Color.gray.opacity(0.1))
                .cornerRadius(10)
        }
        .padding()
    }
    
    private func saveReflection() {
        let wordCount = reflectionAnswer.count + rewardAnswer.count + futureVisionAnswer.count
        
        let newEntry = DiaryEntry(
            date: Date(),
            type: "晚安日记",
            mood: selectedMood,
            events: Array(selectedEvents),
            questions: [
                "关于今天的这些事情，为什么让你觉得不错？": reflectionAnswer,
                "Cool！你会如何奖励自己？": rewardAnswer,
                "如果你可以看到未来，希望看到自己因为这些事情有什么变化？": futureVisionAnswer
            ],
            mindfulnessDuration: 0.0,
            wordCount: wordCount
        )
        
        addDiaryEntry(newEntry) // 确保这里调用了 addDiaryEntry
        
        // 重置所有状态
        currentStep = 1
        selectedMood = -1
        selectedEvents.removeAll()
        reflectionAnswer = ""
        rewardAnswer = ""
        futureVisionAnswer = ""
        
        // 关闭反思视图
        isPresented = false
    }
}

struct EveningReflectionView_Previews: PreviewProvider {
    static var previews: some View {
        EveningReflectionView(isPresented: .constant(true), lastReflectionSummary: .constant(""), addDiaryEntry: { _ in })
    }
}
