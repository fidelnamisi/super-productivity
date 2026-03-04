import { registerPlugin } from '@capacitor/core';

export interface WidgetDataPlugin {
  saveTasks(options: { tasks: string }): Promise<void>;
  ping(): Promise<{ status: string }>;
}

const WidgetData = registerPlugin<WidgetDataPlugin>('WidgetData');
export default WidgetData;
