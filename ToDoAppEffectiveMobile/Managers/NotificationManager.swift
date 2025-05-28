//
//  NotificationManager.swift
//  ToDoAppEffectiveMobile
//
//  Created by Arman  Urstem on 28.05.2025.
//

import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()

    private init() {}

    func scheduleNotification(for task: Task, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = task.title ?? "Задача"
        content.body = task.taskDescription ?? ""
        content.sound = .default

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let request = UNNotificationRequest(identifier: "\(task.id)", content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Ошибка планирования уведомления: \(error.localizedDescription)")
            }
        }
    }

    /// Отменяет запланированное уведомление для задачи
    func cancelNotification(for task: Task) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: ["\(task.id)"])
    }
}
