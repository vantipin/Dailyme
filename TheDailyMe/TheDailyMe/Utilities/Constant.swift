//
// Constant.swift
//  PicPlay
//
//  Created by Anton on 6/19/15.
//  Copyright (c) 2015 Picsolve. All rights reserved.
//

import Foundation
import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex:Int) {
        self.init(red:(hex >> 16) & 0xff, green:(hex >> 8) & 0xff, blue:hex & 0xff)
    }
}

struct Constant {
    
    struct String {
        
        static let ApiKey = "API_KEY";
        static let UserEmailKey = "USER_EMAIl_KEY";
        static let Font = "Helvetica"
        static let FontBold = "Helvetica-Bold"
        
        struct Date {
            
            /// Default DateFormat (User in server side responses)
            static let FormatWithTimezone = "yyyy-MM-dd HH:mm:ss Z"
            static let Format = "yyyy-MM-dd"
            static let ShortFormat = "dd/MM/yyyy"
            static let HourMinutesFormat = "HH:mm"
        }
        
        struct Segue {
            static let menuSegueId = "menuSegueId"
            static let addNoteSegueId = "addNoteSegueId"
            static let diarySegueId = "DiarySegueId"
        }
        
        struct Server {
            static let apiServer = "http://thedailyme-dev.elasticbeanstalk.com/api"
        }
        
        struct Endpoint {
            
            //test
            static let testEndpoint = "api/doctorInfo"
            static let testEndpointPost = "api/getRecipesForUserNameAction"
            
            //User
            static let userCreate = "/user"//POST
            static let user = "/user/"//PUT/GET/DELETE
            static let userLogin = "/user/login" //POST
            
            //Records
            static let records = "/records"///user/{userId}/records //POST/GET
            static let recordsUpdate = "/records/"///user/{id}/records/{recordId} //PUT/GET/DELETE
            
            //Questions
            static let questionCreate = "/question" //CREATE
            static let question = "/question/" //UPDATE/DELETE/GET
            static let questionList = "/question/list" //Get many
        }
        
        struct Notification {
            
        }
    
    }

}

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
    
    //Questions
    case QuestionCreate
    case QuestionGet
    case QuestionUpdate
    case QuestionDelete
    case QuestionsGet
}

enum AuthorizationType: Int
{
    case Login
    case Register
}