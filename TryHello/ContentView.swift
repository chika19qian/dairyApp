//
//  ContentView.swift
//  TryHello
//
//  Created by chika on 2024/10/19.
//
import SwiftUI

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var completedDays: Set<Date> = []
    @State private var showingEveningReflection = false
    @State private var showingMorningReflection = false
    @State private var diaryEntries: [DiaryEntry] = []
    @State private var lastReflectionSummary: String = ""
    @State private var selectedTab = 0 // 0 for 首页, 1 for 日记
    @State private var currentWeekStart: Date = Date() // 当前周的开始日期

    var body: some View {
        TabView(selection: $selectedTab) {
            homeView
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("首页")
                }
                .tag(0)
            
            DiaryView(diaryEntries: $diaryEntries)
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("日记")
                }
                .tag(1)
        }
    }
    
    var homeView: some View {
        VStack(spacing: 20) {
            // 顶部问候与日期选择
            VStack(alignment: .leading) {
                Text(greeting)
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                // 日期选择器
                VStack {
                    Text("本周")
                        .font(.headline)
                        .padding(.top)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack {
                            ForEach(0..<7) { index in
                                let date = Calendar.current.date(byAdding: .day, value: index, to: currentWeekStart)!
                                DayView(date: date, isSelected: Calendar.current.isDate(selectedDate, inSameDayAs: date), isCompleted: completedDays.contains { Calendar.current.isDate($0, inSameDayAs: date) })
                                    .onTapGesture {
                                        selectedDate = date
                                    }
                            }
                        }
                    }
                    
                    // 显示当前月份
                    Text(monthFormatter.string(from: currentWeekStart))
                        .font(.caption)
                        .foregroundColor(.gray)
                        .padding(.top, 5)
                }
            }
            .padding()
            
            // 中央卡片设计
            TabView {
                CardView(isEvening: false, showReflection: $showingMorningReflection)
                CardView(isEvening: true, showReflection: $showingEveningReflection)
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
            .frame(height: 300)
            .padding()
            
            .sheet(isPresented: $showingEveningReflection) {
                EveningReflectionView(isPresented: $showingEveningReflection, lastReflectionSummary: $lastReflectionSummary, addDiaryEntry: addDiaryEntry)
            }
            .sheet(isPresented: $showingMorningReflection) {
                MorningReflectionView(isPresented: $showingMorningReflection, addDiaryEntry: addDiaryEntry)
            }
            
            Spacer()
        }
    }
    
    func addDiaryEntry(_ entry: DiaryEntry) {
        diaryEntries.insert(entry, at: 0)
        if !completedDays.contains(entry.date) {
            completedDays.insert(entry.date)
        }
    }
    
    var greeting: String {
        let hour = Calendar.current.component(.hour, from: Date())
        switch hour {
        case 6..<12: return "早上好"
        case 12..<18: return "下午好"
        default: return "晚上好"
        }
    }
    
    func startOfWeek() -> Date {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        return calendar.date(byAdding: .day, value: 1 - weekday, to: today)!
    }
    
    private var monthFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM" // 显示月份
        return formatter
    }
}

struct DayView: View {
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

struct CardView: View {
    let isEvening: Bool
    @Binding var showReflection: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 20)
                .fill(isEvening ? Color.indigo : Color.orange)
            
            VStack {
                Image(systemName: isEvening ? "moon.stars.fill" : "sun.max.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 80, height: 80)
                    .foregroundColor(.white)
                
                Text(isEvening ? "晚安" : "早安")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text(isEvening ? "结束今天" : "开始新的一天")
                    .font(.headline)
                    .foregroundColor(.white.opacity(0.8))
                
                Button(action: {
                    showReflection = true
                }) {
                    Text("开始")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                }
                .padding(.top)
            }
            .padding()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
