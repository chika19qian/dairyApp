//
//  ContentView.swift
//  TryHello
//
//  Created by chika on 2024/10/19.
//
import SwiftUI

// ToDoItem 结构体

struct ToDoItem: Identifiable {
    let id = UUID()
    var task: String
    var isCompleted: Bool = false
    var dueDate: Date?
}

struct ContentView: View {
    @State private var selectedDate = Date()
    @State private var completedDays: Set<Date> = []
    @State private var showingEveningReflection = false
    @State private var showingMorningReflection = false
    @State private var diaryEntries: [DiaryEntry] = []
    @State private var lastReflectionSummary: String = ""
    @State private var selectedTab = 0 // 0 for 首页, 1 for 日记
    @State private var currentWeekStart: Date = Date() // 当前周的开始日期
    @State private var currentMonth: String = "" // 当前月份
    @State private var completedToday = false
    @State private var completedMorning = false
    @State private var completedEvening = false
    @State private var toDoItems: [ToDoItem] = [] // To-Do list items
    @State private var newTaskText: String = "" // New task input text
    @State private var showingAddTask: Bool = false // 控制添加任务的sheet
    @State private var newTaskDueDate: Date?
    @State private var sortByDueDate: Bool = false

    var body: some View {
        TabView(selection: $selectedTab) {
            ScrollView {
                homeView
            }
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
        .onAppear {
            updateCurrentMonth() // 确保在视图出现时更新当前月份
            resetDailyStatus()   // 每次页面出现时重置当天的状态
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
                WeekView(currentWeekStart: $currentWeekStart, completedDays: completedDays, selectedDate: $selectedDate, currentMonth: $currentMonth)
            }
            .padding()
            
            // 中央卡片设计
            TabView {
                CardView(isEvening: false, showReflection: $showingMorningReflection, completed: $completedMorning)
                CardView(isEvening: true, showReflection: $showingEveningReflection, completed: $completedEvening)
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
            
            // 添加 To-Do 事项区域
            ToDoListView(toDoItems: $toDoItems, showingAddTask: $showingAddTask, newTaskText: $newTaskText, newTaskDueDate: $newTaskDueDate, sortByDueDate: $sortByDueDate)
            
            Spacer()
        }
        .sheet(isPresented: $showingAddTask) {
            AddTaskView(newTaskText: $newTaskText, newTaskDueDate: $newTaskDueDate, toDoItems: $toDoItems, isPresented: $showingAddTask)
        }
    }
    
    func addDiaryEntry(_ entry: DiaryEntry) {
        diaryEntries.insert(entry, at: 0)
        if !completedDays.contains(entry.date) {
            completedDays.insert(entry.date)
        }
        
        if entry.isEvening ?? false {
            completedEvening = true
        } else {
            completedMorning = true
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
    
    func updateCurrentMonth() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy" // 获取当前月份
        currentMonth = formatter.string(from: currentWeekStart)
    }
    
    func resetDailyStatus() {
            let calendar = Calendar.current
            let today = calendar.startOfDay(for: Date())
            
            if let lastCompletionDate = UserDefaults.standard.object(forKey: "LastCompletionDate") as? Date,
               !calendar.isDate(lastCompletionDate, inSameDayAs: today) {
                completedMorning = false
                completedEvening = false
            }

            UserDefaults.standard.set(today, forKey: "LastCompletionDate")
        }
}

struct WeekView: View {
    @Binding var currentWeekStart: Date
    var completedDays: Set<Date>
    @Binding var selectedDate: Date
    @Binding var currentMonth: String
    
    func updateCurrentMonth() {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy" // 获取当前月份
        currentMonth = formatter.string(from: currentWeekStart)
    }

    var body: some View {
        VStack {
            // 当前月份提示
            Text(currentMonth)
                .font(.headline)
                .padding(.bottom, 5)
            
            // 周几
            HStack {
                ForEach(0..<7) { index in
                    Text(weekdays[index])
                        .font(.caption)
                        .foregroundColor(.gray)
                        .frame(maxWidth: .infinity)
                        .multilineTextAlignment(.center)
                }
            }
            
            // 日期
            HStack {
                ForEach(0..<7) { index in
                    let date = Calendar.current.date(byAdding: .day, value: index, to: currentWeekStart)!
                    VStack {
                        ZStack {
                            if completedDays.contains(date) {
                                Text("✔️")
                                    .foregroundColor(.green)
                                    .font(.headline)
                            } else {
                                // 日期数字
                                Text("\(Calendar.current.component(.day, from: date))")
                                    .font(.headline)
                                    .foregroundColor(date == Date() ? .blue : .gray)
                                    .padding(.bottom, 2)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        selectedDate = date
                    }
                }
            }

        }
        .gesture(DragGesture()
            .onEnded { value in
                if value.translation.width < 0 {
                    // 向左滑动，切换到下一周
                    currentWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: 1, to: currentWeekStart)!
                    updateCurrentMonth()
                } else if value.translation.width > 0 {
                    // 向右滑动，切换到上一周
                    currentWeekStart = Calendar.current.date(byAdding: .weekOfYear, value: -1, to: currentWeekStart)!
                    updateCurrentMonth()
                }
            }
        )
    }
    
    var weekdays: [String] {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "zh_CN")
        formatter.dateFormat = "E" // 获取周几的简写
        return (1...7).map { index in
            let date = Calendar.current.date(byAdding: .day, value: index, to: currentWeekStart)!
            return formatter.string(from: date)
        }
    }
    
    func startOfWeek() -> Date {
        var calendar = Calendar.current
        calendar.firstWeekday = 2  // 将一周的第一天设置为周一
        let today = calendar.startOfDay(for: Date())
        let weekday = calendar.component(.weekday, from: today)
        
        // 计算从当前 weekday 到周一的天数差
        let daysToSubtract = (weekday + 7 - calendar.firstWeekday) % 7
        
        return calendar.date(byAdding: .day, value: -daysToSubtract, to: today)!
    }
}

struct CardView: View {
    let isEvening: Bool
    @Binding var showReflection: Bool
    @Binding var completed: Bool // 用于表示早安或晚安是否完成

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
                
                if completed {
                    Text("已记录")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(10)
                } else {
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
            }
            .padding()
        }
    }
}

struct ToDoListView: View {
    @Binding var toDoItems: [ToDoItem]
    @Binding var showingAddTask: Bool
    @Binding var newTaskText: String
    @Binding var newTaskDueDate: Date?
    @Binding var sortByDueDate: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Text("To-Do 事项")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(Color(white: 0.3))
                Spacer()
                Button(action: { sortByDueDate.toggle() }) {
                    Image(systemName: "arrow.up.arrow.down")
                        .font(.title2)
                        .foregroundColor(Color(white: 0.3))
                }
                Button(action: { showingAddTask = true }) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .foregroundColor(Color(white: 0.3))
                }
            }
            
            LazyVStack(alignment: .leading, spacing: 12) { // 增加间距
                ForEach(sortedItems.filter { !$0.isCompleted }) { item in
                    ToDoItemRow(item: binding(for: item))
                }
                
                if !sortedItems.filter({ $0.isCompleted }).isEmpty {
                    Text("已完成")
                        .font(.headline)
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                    
                    ForEach(sortedItems.filter { $0.isCompleted }) { item in
                        ToDoItemRow(item: binding(for: item))
                    }
                }
            }
            
            Button(action: {
                toDoItems.removeAll { $0.isCompleted }
            }) {
                Text("清除已完成")
                    .font(.headline)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .disabled(toDoItems.filter { $0.isCompleted }.isEmpty)
        }
        .padding()
        .background(Color.yellow.opacity(0.1))
        .cornerRadius(16)
        .padding()
    }
    
    private var sortedItems: [ToDoItem] {
        if sortByDueDate {
            return toDoItems.sorted { (item1, item2) -> Bool in
                switch (item1.dueDate, item2.dueDate) {
                case (.some(let date1), .some(let date2)):
                    return date1 < date2
                case (.some, .none):
                    return true
                case (.none, .some):
                    return false
                case (.none, .none):
                    return false
                }
            }
        } else {
            return toDoItems
        }
    }
    
    private func binding(for item: ToDoItem) -> Binding<ToDoItem> {
        guard let index = toDoItems.firstIndex(where: { $0.id == item.id }) else {
            fatalError("Can't find todo item in array")
        }
        return $toDoItems[index]
    }
}

struct ToDoItemRow: View {
    @Binding var item: ToDoItem
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.task)
                    .font(.system(size: 18)) // 增大字体
                    .strikethrough(item.isCompleted)
                    .foregroundColor(item.isCompleted ? .gray : Color(white: 0.3))
            }
            Spacer()
            if let dueDate = item.dueDate {
                Text(formatDate(dueDate))
                    .font(.caption)
                    .foregroundColor(.gray)
                    .padding(.trailing, 8) // 在日期和复选框之间添加一些间距
            }
            Image(systemName: item.isCompleted ? "checkmark.square.fill" : "square")
                .font(.title3)
                .foregroundColor(item.isCompleted ? .green : Color(white: 0.3))
                .onTapGesture {
                    item.isCompleted.toggle()
                }
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd"
        return formatter.string(from: date)
    }
}

struct AddTaskView: View {
    @Binding var newTaskText: String
    @Binding var newTaskDueDate: Date?
    @Binding var toDoItems: [ToDoItem]
    @Binding var isPresented: Bool
    
    var body: some View {
        NavigationView {
            Form {
                TextField("新任务", text: $newTaskText)
                DatePicker("截止日期", selection: Binding(
                    get: { self.newTaskDueDate ?? Date() },
                    set: { self.newTaskDueDate = $0 }
                ), displayedComponents: .date)
            }
            .navigationBarTitle("添加新任务", displayMode: .inline)
            .navigationBarItems(
                leading: Button("取消") { isPresented = false },
                trailing: Button("添加") {
                    if !newTaskText.isEmpty {
                        toDoItems.append(ToDoItem(task: newTaskText, dueDate: newTaskDueDate))
                        newTaskText = ""
                        newTaskDueDate = nil
                        isPresented = false
                    }
                }
            )
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
