import WidgetKit
import SwiftUI

// MARK: - Data Models

struct WidgetTask: Codable, Identifiable {
    let id: String
    let title: String
    let isDone: Bool
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let tasks: [WidgetTask]
}

// MARK: - Timeline Provider

struct Provider: TimelineProvider {
    // START: CHANGE THIS TO YOUR APP GROUP ID
    let groupName = "group.com.fidelnamisi.superproductivity"
    // END: CHANGE THIS TO YOUR APP GROUP ID

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), tasks: [
            WidgetTask(id: "1", title: "Review PR #123", isDone: false),
            WidgetTask(id: "2", title: "Daily Sync", isDone: false),
            WidgetTask(id: "3", title: "Update Documentation", isDone: true)
        ])
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), tasks: [
            WidgetTask(id: "1", title: "Review PR #123", isDone: false),
            WidgetTask(id: "2", title: "Daily Sync", isDone: false),
            WidgetTask(id: "3", title: "Update Documentation", isDone: true)
        ])
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        var tasks: [WidgetTask] = []
        
        if let userDefaults = UserDefaults(suiteName: groupName) {
            if let data = userDefaults.string(forKey: "widgetData")?.data(using: .utf8) {
                do {
                    tasks = try JSONDecoder().decode([WidgetTask].self, from: data)
                } catch {
                    print("Error decoding widget tasks: \(error)")
                }
            }
        }
        
        // Create an entry for right now
        let entry = SimpleEntry(date: Date(), tasks: tasks)

        // Refresh the timeline every 15 minutes roughly, or when app pushes update
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        
        completion(timeline)
    }
}

// MARK: - Views

struct TasksWidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.widgetFamily) var family

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text("Today")
                    .font(.headline)
                    .foregroundColor(.accentColor)
                Spacer()
                Image(systemName: "checklist")
                    .foregroundColor(.secondary)
            }
            .padding(.bottom, 4)
            
            if entry.tasks.isEmpty {
                Text("No tasks left for today!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                ForEach(entry.tasks.prefix(3)) { task in
                    HStack(alignment: .top) {
                        Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isDone ? .green : .gray)
                        Text(task.title)
                            .font(.subheadline)
                            .strikethrough(task.isDone)
                            .lineLimit(1)
                    }
                }
                if entry.tasks.count > 3 {
                    Text("+ \(entry.tasks.count - 3) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding()
    }
}

// MARK: - Widget Configuration

@main
struct TasksWidget: Widget {
    let kind: String = "TasksWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TasksWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Super Productivity Tasks")
        .description("View your tasks for today.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Preview

struct TasksWidget_Previews: PreviewProvider {
    static var previews: some View {
        TasksWidgetEntryView(entry: SimpleEntry(date: Date(), tasks: [
            WidgetTask(id: "1", title: "Finish Report", isDone: false),
            WidgetTask(id: "2", title: "Email Client", isDone: false)
        ]))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
