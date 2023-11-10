//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/11/8.
//

import AsyncHTTPClient
import Foundation
import SwiftyJSON
import NIOPosix

public struct OpenWeatherAPIWrapper {
    
//    {
//      "coord": {
//        "lon": 10.99,
//        "lat": 44.34
//      },
//      "weather": [
//        {
//          "id": 501,
//          "main": "Rain",
//          "description": "moderate rain",
//          "icon": "10d"
//        }
//      ],
//      "base": "stations",
//      "main": {
//        "temp": 298.48,
//        "feels_like": 298.74,
//        "temp_min": 297.56,
//        "temp_max": 300.05,
//        "pressure": 1015,
//        "humidity": 64,
//        "sea_level": 1015,
//        "grnd_level": 933
//      },
//      "visibility": 10000,
//      "wind": {
//        "speed": 0.62,
//        "deg": 349,
//        "gust": 1.18
//      },
//      "rain": {
//        "1h": 3.16
//      },
//      "clouds": {
//        "all": 100
//      },
//      "dt": 1661870592,
//      "sys": {
//        "type": 2,
//        "id": 2075663,
//        "country": "IT",
//        "sunrise": 1661834187,
//        "sunset": 1661882248
//      },
//      "timezone": 7200,
//      "id": 3163858,
//      "name": "Zocca",
//      "cod": 200
//    }
    public init() {
        
    }
    func search(query: String, apiKey: String) async throws -> String? {
        let coord = query.split(separator: ":")
        if coord.count != 2 {
            return nil
        }
        let eventLoopGroup = ThreadManager.thread
        let httpClient = HTTPClient(eventLoopGroupProvider: .shared(eventLoopGroup))
        defer {
            // it's important to shutdown the httpClient after all requests are done, even if one failed. See: https://github.com/swift-server/async-http-client
            try? httpClient.syncShutdown()
        }
        
        let baseURL = "https://api.openweathermap.org/data/2.5/weather"
        var components = URLComponents(string: baseURL)!
        components.queryItems = [
            URLQueryItem(name: "lon", value: "\(coord[0])"),
            URLQueryItem(name: "lat", value: "\(coord[1])"),
            URLQueryItem(name: "appid", value: apiKey),
            URLQueryItem(name: "units", value: "metric"),
        ]
//        print(components.url!.absoluteString)
        var request = HTTPClientRequest(url: components.url!.absoluteString)
        request.method = .GET
        
        let response = try await httpClient.execute(request, timeout: .seconds(30))
        if response.status == .ok {
            let str = String(buffer: try await response.body.collect(upTo: 1024 * 1024))
//            print(str)
            let json = try JSON(data: str.data(using: .utf8)!)
            
            return """
            In \(json["coord"]["lon"].doubleValue):\(json["coord"]["lat"].doubleValue), the current weather is as follows:"
            \(json["weather"][0]["main"].stringValue)
            Detailed status:
            Wind speed: \(json["wind"]["speed"].doubleValue) m/s, direction: \(json["wind"]["deg"].doubleValue)°"
            Humidity: \(json["main"]["humidity"].doubleValue)%
            Temperature:
              - Current: \(json["main"]["temp"].doubleValue)°C
              - High: \(json["main"]["temp_max"].doubleValue)°C
              - Low: \(json["main"]["temp_min"].doubleValue)°C
              - Feels like: \(json["main"]["feels_like"].doubleValue)°C
            Rain: \(json["rain"]["1h"].doubleValue)%
            Cloud cover: \(json["clouds"]["all"].doubleValue)%
"""
        } else {
            // handle remote error
            print("http code is not 200.")
            return nil
        }
    }
}
