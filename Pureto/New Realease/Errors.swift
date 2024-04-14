//
//  SwiftUIView.swift
//  Pureto
//
//  Created by Pureto on 22/9/23.
//

import SwiftUI
import Foundation

public enum YourTubeKitError: String, Error {
    case videoUnavailable
    case videoAgeRestricted
    case liveStreamError
    case extractError
}

extension YourTubeKitError: LocalizedError {
    
    public var errorDescription: String? {
        switch self {
        case .videoUnavailable:
            return NSLocalizedString("Video unavailable", comment: "")
            
        case .videoAgeRestricted:
            return NSLocalizedString("Video age restricted", comment: "")
            
        case .liveStreamError:
            return NSLocalizedString("Can't extract video from livestream", comment: "")
        default: return nil
        }
    }
    
}
