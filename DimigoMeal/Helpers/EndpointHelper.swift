//
//  EndpointHelper.swift
//  DimigoMeal
//
//  Created by noViceMin on 2024-06-15.
//

import SwiftUI

struct EndpointHelper {
    @AppStorage("debug/enable") static private var debug = false
    @AppStorage("debug/endpoint") static private var endpoint = ""
    
    static private var baseEndpointComponents: URLComponents? {
        return URLComponents(string: debug && endpoint != "" ? endpoint : "https://api.디미고급식.com")
    }
    
    static func fetch(_ date: String) async -> [MealAPIResponse]? {
        var components = baseEndpointComponents
        components?.path = "/meal/week/\(date)"
        
        if let url = components?.url {
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            
            do {
                let (data, response) = try await URLSession.shared.data(for: request)
                
                if let response = response as? HTTPURLResponse {
                    if(response.statusCode == 200) {
                        do {
                            let meals = try JSONDecoder().decode([MealAPIResponse].self, from: data)
                            return meals
                        } catch {
                            print("Failed to decode JSON: \(error)")
                        }
                    } else {
                        print("Failed to fetch data: \(response.statusCode)")
                    }
                }
            } catch {
                print("Failed to fetch data: \(error.localizedDescription)")
            }
            
            print(url)
        }
        
        return nil
    }
    
    static func addToken(_ token: String) async -> Bool {
        var components = baseEndpointComponents
        components?.path = "/ios/activity/\(token)"
        
        if let url = components?.url {
            var request = URLRequest(url: url)
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
            
            print(url)
        }
        
        return false
    }
    
    static func removeToken(_ token: String) async -> Bool {
        var components = baseEndpointComponents
        components?.path = "/ios/activity/\(token)"
        
        if let url = components?.url {
            var request = URLRequest(url: url)
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
            
            print(url)
        }
        
        return false
    }
}
