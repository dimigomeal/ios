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
                    if await EndpointHelper.addToken(tokenString) {
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
                _ = await EndpointHelper.removeToken(tokenToString(pushToken))
            }
        }
        
        liveActivity = false
    }
    
    static func reload() async {
        if let activity = check() {
            if let pushToken = activity.pushToken {
                if await EndpointHelper.removeToken(tokenToString(pushToken)) {
                    await remove()
                    _ = await start()
                }
            }
        } else {
            if(liveActivity) {
                _ = await start()
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
        return token.map {
            String(format: "%02x", $0)
        }.joined()
    }
}
