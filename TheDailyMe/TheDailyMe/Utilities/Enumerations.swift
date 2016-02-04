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
    
    //test
    case TestEndpoint
    
    //User
    case UserCreate
    case UserGet
    case UserDelete
    case UserUpdate
    case UserLogin
    
    //Records
    case RecordCreate
    case RecordGet
    case RecordUpdate
    case RecordDelete
}

enum AuthorizationType: Int
{
    case Login
    case Register
}