import { Injectable, inject } from '@angular/core';
import { Store } from '@ngrx/store';
import { selectTodayTaskIds } from '../../features/work-context/store/work-context.selectors';
import { selectTaskEntities } from '../../features/tasks/store/task.selectors';
import { combineLatest } from 'rxjs';
import { distinctUntilChanged, map } from 'rxjs/operators';
import WidgetData from './widget-data.plugin';
import { Task } from '../../features/tasks/task.model';
import { Capacitor } from '@capacitor/core';

interface WidgetTask {
  id: string;
  title: string;
  isDone: boolean;
}

@Injectable({
  providedIn: 'root',
})
export class WidgetSyncService {
  private _store = inject(Store);

  init(): void {
    console.log('WidgetSyncService: Initializing for platform:', Capacitor.getPlatform());
    if (Capacitor.getPlatform() !== 'ios' && Capacitor.getPlatform() !== 'web') {
      return;
    }

    // Test connectivity
    WidgetData.ping()
      .then((res) => console.log('WidgetSyncService: Native bridge check:', res))
      .catch((err) =>
        console.error('WidgetSyncService: Native bridge check FAILED:', err),
      );

    combineLatest([
      this._store.select(selectTodayTaskIds),
      this._store.select(selectTaskEntities),
    ])
      .pipe(
        map(([ids, entities]) => {
          return ids
            .map((id) => entities[id])
            .filter((task): task is Task => !!task && !task.isDone)
            .map((task) => ({
              id: task.id,
              title: task.title,
              isDone: task.isDone,
            }));
        }),
        distinctUntilChanged((a, b) => JSON.stringify(a) === JSON.stringify(b)),
      )
      .subscribe((tasks) => {
        console.log('WidgetSyncService: Syncing tasks to native:', tasks);
        this.updateWidgetData(tasks);
      });
  }

  private async updateWidgetData(tasks: WidgetTask[]): Promise<void> {
    try {
      await WidgetData.saveTasks({
        tasks: JSON.stringify(tasks),
      });
    } catch (e) {
      console.error('Failed to update widget data', e);
    }
  }
}
