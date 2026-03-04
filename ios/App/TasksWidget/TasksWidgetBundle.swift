//
//  TasksWidgetBundle.swift
//  TasksWidget
//
//  Created by Fidel Namisi on 2026/02/16.
//

import WidgetKit
import SwiftUI

@main
struct TasksWidgetBundle: WidgetBundle {
    @WidgetBundleBuilder
    var body: some Widget {
        TasksWidget()
        if #available(iOS 16.1, *) {
            TasksWidgetLiveActivity()
        }
        if #available(iOS 18.0, *) {
            TasksWidgetControl()
        }
    }
}
