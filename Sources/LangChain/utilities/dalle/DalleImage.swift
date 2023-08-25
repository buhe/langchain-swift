//
//  File.swift
//  
//
//  Created by 顾艳华 on 2023/8/25.
//

import Foundation
import OpenAIKit

public struct DalleImage {
}

extension DalleImage: Decodable {}

extension DalleImage {
    public enum Size: String {
        case twoFiftySix = "256x256"
        case fiveTwelve = "512x512"
        case tenTwentyFour = "1024x1024"
    }
}

extension DalleImage.Size: Codable {}

func dalleTo(size: DalleImage.Size) -> Image.Size {
    switch size {
    case .fiveTwelve:
        return Image.Size.fiveTwelve
    case .tenTwentyFour:
        return Image.Size.tenTwentyFour
    case .twoFiftySix:
        return Image.Size.twoFiftySix
    }
}
