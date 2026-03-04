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
    let hasDataFile: Bool
}

// MARK: - Shared Data Reader

private struct TaskDataReader {
    static let groupName = "group.com.fidelnamisi.superproductivity"
    
    struct ReadResult {
        let tasks: [WidgetTask]
        let hasDataFile: Bool
    }
    
    static func readTasks() -> ReadResult {
        // Try UserDefaults first (primary, fastest)
        if let userDefaults = UserDefaults(suiteName: groupName),
           let jsonString = userDefaults.string(forKey: "widgetTasks"),
           let data = jsonString.data(using: .utf8) {
            do {
                let tasks = try JSONDecoder().decode([WidgetTask].self, from: data)
                print("TasksWidget: Read \(tasks.count) tasks from UserDefaults.")
                return ReadResult(tasks: tasks, hasDataFile: true)
            } catch {
                print("TasksWidget: UserDefaults JSON decode failed: \(error)")
            }
        }
        
        // Fall back to file-based read
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupName) {
            let fileURL = containerURL.appendingPathComponent("tasks.json")
            if let data = try? Data(contentsOf: fileURL) {
                do {
                    let tasks = try JSONDecoder().decode([WidgetTask].self, from: data)
                    print("TasksWidget: Read \(tasks.count) tasks from file.")
                    return ReadResult(tasks: tasks, hasDataFile: true)
                } catch {
                    print("TasksWidget: File JSON decode failed: \(error)")
                }
            }
        }
        
        print("TasksWidget: No task data found in UserDefaults or file.")
        return ReadResult(tasks: [], hasDataFile: false)
    }
}

// MARK: - Timeline Provider

struct Provider: TimelineProvider {

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), tasks: [
            WidgetTask(id: "1", title: "Review PR #123", isDone: false),
            WidgetTask(id: "2", title: "Daily Sync", isDone: false),
            WidgetTask(id: "3", title: "Update Documentation", isDone: true)
        ], hasDataFile: true)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        // Read real data for the snapshot so the widget gallery shows actual tasks
        let result = TaskDataReader.readTasks()
        if result.hasDataFile {
            let entry = SimpleEntry(date: Date(), tasks: result.tasks, hasDataFile: true)
            completion(entry)
        } else {
            // Only use placeholder if no data exists yet
            let entry = SimpleEntry(date: Date(), tasks: [
                WidgetTask(id: "1", title: "Review PR #123", isDone: false),
                WidgetTask(id: "2", title: "Daily Sync", isDone: false),
            ], hasDataFile: true)
            completion(entry)
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> ()) {
        let result = TaskDataReader.readTasks()
        let entry = SimpleEntry(date: Date(), tasks: result.tasks, hasDataFile: result.hasDataFile)

        // Refresh every 15 minutes, or when the app pushes an update
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        
        completion(timeline)
    }
}

// MARK: - Helper Extensions

extension View {
    func widgetBackground(_ backgroundView: some View) -> some View {
        if #available(iOS 17.0, *) {
            return containerBackground(for: .widget) {
                backgroundView
            }
        } else {
            return background(backgroundView)
        }
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
            
            if !entry.hasDataFile {
                // No data has ever been written — the app hasn't synced yet
                Text("Open the app to load tasks")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if entry.tasks.isEmpty {
                // Data file exists but no incomplete tasks
                Text("All done for today!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else {
                let maxTasks = family == .systemSmall ? 3 : (family == .systemMedium ? 4 : 8)
                ForEach(entry.tasks.prefix(maxTasks)) { task in
                    HStack(alignment: .top) {
                        Image(systemName: task.isDone ? "checkmark.circle.fill" : "circle")
                            .foregroundColor(task.isDone ? .green : .gray)
                        Text(task.title)
                            .font(.subheadline)
                            .strikethrough(task.isDone)
                            .lineLimit(1)
                    }
                }
                if entry.tasks.count > maxTasks {
                    Text("+ \(entry.tasks.count - maxTasks) more")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            Spacer()
        }
        .padding()
        .widgetBackground(Color(UIColor.systemBackground))
    }
}

// MARK: - Widget Configuration

struct TasksWidget: Widget {
    let kind: String = "TasksWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            TasksWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Super Productivity Tasks")
        .description("View your tasks for today.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

// MARK: - Preview

struct TasksWidget_Previews: PreviewProvider {
    static var previews: some View {
        TasksWidgetEntryView(entry: SimpleEntry(date: Date(), tasks: [
            WidgetTask(id: "1", title: "Finish Report", isDone: false),
            WidgetTask(id: "2", title: "Email Client", isDone: false)
        ], hasDataFile: true))
        .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
