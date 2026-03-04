# iOS Widget Setup Guide for Super Productivity

This guide will help you create a home screen widget for the Super Productivity iOS app.

## Prerequisites

- Xcode installed on your Mac.
- An Apple Developer account (or free account) for signing.

## Step 1: Open the Project in Xcode

1. Navigate to `ios/App` folder in Finder.
2. Double-click `App.xcworkspace` (NOT `.xcodeproj`) to open it in Xcode.

## Step 2: Enable App Groups for the Main App

App Groups allow the main app and the widget to share data.

1. **Open the Project Navigator**: Look at the leftmost sidebar in Xcode. If you don't see it, press `Command + 1`.
2. **Select the Project File**: At the very top of that sidebar, click on the item named `App` with a blue icon next to it.
3. **Open the Project Editor**: Clicking that file should open a large configuration panel in the center of the Xcode window.
4. **Locate the Targets List**: Look at the _left side_ of this central panel. You should see a list under the header **TARGETS**.
   - If you don't see this list, there might be a small icon in the top-left of the center panel to toggle the sidebar.
5. **Select the App Target**: In that TARGETS list, click on the one named **App** (it usually has a black icon).
6. **Go to Capabilities**: At the top of the center panel, click on the tab labeled **Signing & Capabilities**.
7. **Add Capability**: Click the `+ Capability` button (usually in the top-left corner of this tab).
8. **Select App Groups**: A window will pop up. Search for "App Groups" and double-click it.
9. **Configure the Group**:
   - In the "App Groups" section that appears in the list, click the `+` button at the bottom of that section.
   - Enter this exact group identifier: `group.com.fidelnamisi.superproductivity`
   - Click OK.
10. **Enable the Group**: Make sure the checkbox next to `group.com.fidelnamisi.superproductivity` is **checked** (blue checkmark).

## Step 3: Add Widget Extension Target

1. In Xcode, go to **File > New > Target...**.
2. Search for **Widget Extension** and select it. Click **Next**.
3. Name it: `TasksWidget`.
4. Ensure **"Include Configuration Intent"** is **UNCHECKED**.
5. Click **Finish**.
6. When asked to activate the scheme, click **Activate**.

## Step 4: Enable App Groups for the Widget

1. **Return to the Project Editor**: Just like in Step 2, make sure you have the blue **App** project selected in the left sidebar and the Project Editor open in the center.
2. **Select the Widget Target**: In the **TARGETS** list on the left side of the center panel, find the new target named **TasksWidget** (it should have a different icon, possibly a Lego block or similar). Click it.
3. **Go to Capabilities**: Click the **Signing & Capabilities** tab at the top.
4. **Add Capability**: Click the `+ Capability` button.
5. **Add App Groups**: Search for "App Groups" and double-click to add it.
6. **Enable the Group**: You should see the `group.com.fidelnamisi.superproductivity` identifier you created for the main app.
   - **Check the box** next to it.
   - **CRITICAL**: Do NOT create a new group. You MUST check the exact same group ID used in Step 2.

## Step 5: Implement the Widget Code

1. In the Project Navigator (left sidebar), find the `TasksWidget` folder.
2. Open the file named `TasksWidget.swift` (or similar).
3. **Delete ALL content** in this file.
4. Copy the entire content from the file `ios/TasksWidget_Template.swift` in your project folder (I created this for you).
5. Paste it into `TasksWidget.swift`.

**Important**: If you used a different App Group ID in Step 2, update the `groupName` variable in `TasksWidget.swift` (around line 20).

## Step 6: Verify Plugin Registration

The main app needs to send data to the widget. I have already added the necessary plugin files:

- `ios/App/App/WidgetDataPlugin.swift`
- `ios/App/App/WidgetDataPlugin.m`
- `src/app/core/widget/widget-sync.service.ts`

These files are already in place and hooked up. When you run the app, it will sync today's tasks to the widget.

## Step 7: Run and Test

1. Select the **App** scheme (top toolbar, near the Play button). Select your device (iPhone) or Simulator.
2. Click **Run** (Play button).
3. Once the app launches on your phone/simulator:
   - Add some tasks to "Today".
   - Go to Home Screen.
   - Long press -> `+` button -> Search "Super Productivity" (or just "App" if generic name).
   - Add the widget.
   - It should show your tasks!

## Troubleshooting

- **Widget is empty but app has tasks**:
  - Open the app again to trigger a sync.
  - Check if App Group ID matches in both targets and in code.
  - Check Xcode console logs for "WidgetDataPlugin" errors.
- **Build Errors**:
  - Ensure you opened `.xcworkspace`, not `.xcodeproj`.
  - Ensure the Deployment Target for the Widget Extension is set to iOS 17.0 (or matching your device).
