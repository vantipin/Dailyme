//
// Enumerations.swift
//  PicPlay
//
//  Created by Aleksey Orlov on 6/16/15.
//  Copyright (c) 2015 Picsolve. All rights reserved.
//

import Foundation

public enum ErrorCode: String
{
    case Success = "success"
    case UnknownError = "unknown_error"
    case OfflineError = "offline_error"
    case ResponseApplyingError = "applying_error"
    case FrameworkError = "framework_error"
    case ResponseParsingError = "response_parsing_error"
    
}

public enum RequestType: Int
{
    case DownloadFile
    case TestEndpoint
}

enum AuthorizationType: Int
{
    case Login
    case Register
}