//
//  LiveActivityHelper.swift
//  dimigomeal
//
//  Created by noViceMin on 2024-06-14.
//

import SwiftUI
import ActivityKit

struct LiveActivityHelper {
    @AppStorage("theme/activity") static private var activityTheme = ActivityTheme.dynamic
    @AppStorage("function/liveactivity") static private var liveActivity = false
    
    static private var baseEndpoint: URL {
        return URL(string: "https://api.디미고급식.com")!
    }
    
    static func start() async -> Bool {
        if let activity = check() {
            print("Live Activity already exists: \(tokenToString(activity.pushToken!))")
        } else {
            let current = MealHelper.current()
            let attributes = LiveActivityAttributes(theme: activityTheme)
            let state = LiveActivityAttributes.ContentState(type: current.type, menu: current.menu, date: current.date)
            
            do {
                let activity = try Activity.request(
                    attributes: attributes,
                    content: .init(state: state, staleDate: nil),
                    pushType: .token
                )
                
                for await token in activity.pushTokenUpdates {
                    let tokenString = tokenToString(token)
                    
                    print("New push token: \(tokenString)")
                    if await createToken(tokenString) {
                        liveActivity = true
                        return true
                    } else {
                        await remove()
                    }
                    
                    break
                }
            } catch {
                print("Failed to start Live Activity: \(error.localizedDescription)")
            }
        }
        
        return false
    }
    
    static func end() async {
        if let activity = check() {
            await remove()
            
            if let pushToken = activity.pushToken {
                _ = await deleteToken(tokenToString(pushToken))
            }
        }
    }
    
    static func reload() async {
        if let activity = check() {
            if let pushToken = activity.pushToken {
                if await deleteToken(tokenToString(pushToken)) {
                    await remove()
                    _ = await start()
                }
            }
        }
    }
    
    static private func check() -> Activity<LiveActivityAttributes>? {
        return Activity<LiveActivityAttributes>.activities.first ?? nil
    }
    
    static private func remove() async {
        if let activity = check() {
            await activity.end(activity.content, dismissalPolicy: .immediate)
            liveActivity = false
        }
    }
    
    static func tokenToString(_ token: Data) -> String {
        return token.reduce("") { $0 + String(format: "%02x", $1) }
    }
    
    static func createToken(_ token: String) async -> Bool {
        var request = URLRequest(url: baseEndpoint.appendingPathComponent("/ios/activity/\(token)"))
        request.httpMethod = "POST"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let response = response as? HTTPURLResponse {
                if(response.statusCode == 200) {
                    print("Push token sent: \(response.statusCode)")
                    return true
                } else {
                    print("Failed to send push token: \(response.statusCode)")
                }
            }
        } catch {
            print("Failed to send push token: \(error.localizedDescription)")
        }
        
        return false
    }
    
    static func deleteToken(_ token: String) async -> Bool {
        var request = URLRequest(url: baseEndpoint.appendingPathComponent("/ios/activity/\(token)"))
        request.httpMethod = "DELETE"

        do {
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let response = response as? HTTPURLResponse {
                if(response.statusCode == 200) {
                    print("Push token deleted: \(response.statusCode)")
                    return true
                } else {
                    print("Failed to delete push token: \(response.statusCode)")
                }
            }
        } catch {
            print("Failed to delete push token: \(error.localizedDescription)")
        }
        
        return false
    }
}
