//
//  LiveActivityHelper.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-14.
//

import SwiftUI
import ActivityKit
import CoreData

struct LiveActivityHelper {
    @AppStorage("theme/activity") static private var activityTheme = WidgetTheme.dynamic
    @AppStorage("function/liveactivity") static private var liveActivity = false
    @AppStorage("loading/liveactivity") static private var loadingLiveActivity = false
    @AppStorage("token/liveactivity") static private var tokenLiveActivity = ""
    
    static func enable() async {
        print("enable start")
        loadingLiveActivity = true
        let token = await getToken()
        
        liveActivity = true
        loadingLiveActivity = false
        print("enable end")
    }
    
    static func disable() async {
        print("disable start")
        loadingLiveActivity = true
        
        //
        
        liveActivity = false
        loadingLiveActivity = false
        print("disable end")
    }
    
    static private func getToken() async -> String {
        if tokenLiveActivity == "" {
            for await token in Activity<LiveActivityAttributes>.pushToStartTokenUpdates {
                tokenLiveActivity = tokenToString(token)
                print("New Token: \(tokenLiveActivity)")
                
                return tokenLiveActivity
            }
        }
        
        print("Existing Token: \(tokenLiveActivity)")
        return tokenLiveActivity
    }
    
    static func start(_ viewContext: NSManagedObjectContext) async -> Bool {
        loadingLiveActivity = true
        
        if let activity = check() {
            print("Live Activity already exists: \(tokenToString(activity.pushToken!))")
        } else {
            let current = MealHelper.current(viewContext)
            let attributes = LiveActivityAttributes(theme: activityTheme)
            let state = LiveActivityAttributes.ContentState(type: current.target.type, menu: current.menu, date: current.date)
            
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
                        
                        loadingLiveActivity = false
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
        
        loadingLiveActivity = false
        return false
    }
    
    static func end() async {
        loadingLiveActivity = true
        
        if let activity = check() {
            await remove()
            
            if let pushToken = activity.pushToken {
                _ = await EndpointHelper.removeToken(tokenToString(pushToken))
            }
        }
        
        loadingLiveActivity = false
        liveActivity = false
    }
    
    static func reload(_ viewContext: NSManagedObjectContext) async {
        loadingLiveActivity = true
        
        if let activity = check() {
            if let pushToken = activity.pushToken {
                if await EndpointHelper.removeToken(tokenToString(pushToken)) {
                    await remove()
                    _ = await start(viewContext)
                }
            }
        } else {
            if(liveActivity) {
                _ = await start(viewContext)
            }
        }
        
        loadingLiveActivity = false
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
