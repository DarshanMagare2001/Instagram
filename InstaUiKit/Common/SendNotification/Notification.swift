//
//  Notification.swift
//  InstaUiKit
//
//  Created by IPS-161 on 21/11/23.
//

import Foundation

class PushNotification {
    static let shared = PushNotification()
    private init(){}
    
    func sendPushNotification(to fcmToken: String, title: String, body: String) {
        guard let url = URL(string: "https://fcm.googleapis.com/fcm/send") else {
            print("Invalid URL")
            return
        }

        let serverKey = "AAAAVisTDNY:APA91bHsr0doWbLx0HC9K1Wr54BEWtDdD8unOhppRrg8IONF3kl0OMr3zUjbv7MooIvkF630yP1A95QvEIXDhGF-5P3kb0Koh_FzjmVSKk7hok8yvHLUKwfbZpN1XxiFbRQnvpBgvKU1"
        let headers: [String: String] = [
            "Content-Type": "application/json",
            "Authorization": "key=\(serverKey)"
        ]

        let notification = [
            "title": title,
            "body": body
        ]

        let payload: [String: Any] = [
            "to": fcmToken,
            "notification": notification
        ]

        do {
            let jsonData = try JSONSerialization.data(withJSONObject: payload, options: [])
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.allHTTPHeaderFields = headers
            request.httpBody = jsonData

            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                if let error = error {
                    print("Error: \(error)")
                } else if let data = data {
                    if let httpResponse = response as? HTTPURLResponse {
                        if (200...299).contains(httpResponse.statusCode) {
                            print("Notification sent successfully.")
                        } else {
                            print("Failed to send notification. Status Code: \(httpResponse.statusCode)")
                        }
                    }
                    let responseString = String(data: data, encoding: .utf8)
                    print("Response data: \(responseString ?? "")")
                }
            }
            task.resume()
        } catch {
            print("Error serializing JSON: \(error)")
        }
    }
    
}
