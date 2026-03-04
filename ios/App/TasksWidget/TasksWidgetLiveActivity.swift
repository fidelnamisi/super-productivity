//
//  TasksWidgetLiveActivity.swift
//  TasksWidget
//
//  Created by Fidel Namisi on 2026/02/16.
//

import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct TasksWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

@available(iOS 16.1, *)
struct TasksWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TasksWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

@available(iOS 16.1, *)
extension TasksWidgetAttributes {
    fileprivate static var preview: TasksWidgetAttributes {
        TasksWidgetAttributes(name: "World")
    }
}

@available(iOS 16.1, *)
extension TasksWidgetAttributes.ContentState {
    fileprivate static var smiley: TasksWidgetAttributes.ContentState {
        TasksWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: TasksWidgetAttributes.ContentState {
         TasksWidgetAttributes.ContentState(emoji: "🤩")
     }
}

// Preview requires iOS 17.0+ for this builder, but the file is compiled for 15.0.
// Wrapping in availability check.
#if canImport(ActivityKit) && canImport(WidgetKit)
@available(iOS 17.0, *)
#Preview("Notification", as: .content, using: TasksWidgetAttributes.preview) {
   TasksWidgetLiveActivity()
} contentStates: {
    TasksWidgetAttributes.ContentState.smiley
    TasksWidgetAttributes.ContentState.starEyes
}
#endif
