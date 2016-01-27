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
    case ResponseParsingError = "parsing_error"
    case ResponseApplyingError = "applying_error"
    case OfflineError = "offline_error"
    case FrameworkError = "framework_error"
    case BadRequestError = "bad_request"
    case GenericError = "generic_error"
    case NoSuchParkError = "no_such_park"
    case NoSuchRideError = "no_such_ride"
    case NoSuchAssetError = "no_such_asset_error"
    case AssociationNotFoundError = "association_media_not_found_error"
    case RideAlreadyExistsError = "parkRideCode_already_exists"
    case InvalidRequestError = "invalid_request"
   
    //custom errors sent from Picsolve server
    case UserEmailTakenError = "user_email_taken_error"
    case UserEmailFormatError = "user_email_format_error"
    case UserPasswordFormatError = "user_password_format_error"
    case UserFirstNameEmptyError = "user_firstName_empty_error"
    case UserLastNameEmptyError = "user_lastName_empty_error"
    case UserNotFound = "user_not_found_error"
    case UserOldPasswordError = "user_old_password_incorrect_error"
    
    case LoginAnyFailedError = "login_any_failed_error"
    
    //redemptions
    case MediaInvalidRedemptionCodeError = "invalid_media_code_error"
    case MediaAlreadyAssociatedError = "association_already_exists_error"
    case MediaNotFoundError = "media_not_found_error"
    case ParkRideCodeError = "invalid_park_ride_code_error"
    
}

enum RedemptionType: Int
{
    case By12DigitsCode
    case ByQR
    case ByRide
}

public enum RequestType: Int
{
    case DownloadFile
    
    //user
    case PostUser
    case PostUserValidation
    case PutUser
    case PostForgotPassword
    case GetUser
    case GetUserGlobalAchievements
    case GetUserAchievementsForPark
    case GetUserDays
    case GetUserDay
    
    //achievements
    case GetGlobalAchievements
    case GetAchievementsForPark
    
    //auth
    case PostAuthLogin
    case PostAuthFacebook
    case PostAuthLogout
    
    //park
    case GetParks
    case GetPark
    case GetParkRides
    
    //assets
    case GetAssetsForPark
    
    //park media
    case GetParkmediaThumbnails
    case GetParkmedia
    
    //usermedia
    case PutUsermediaById
    case PutUsermediaByCode
}

enum SocialService: String
{
    case Facebook = "Facebook"
    case Twitter = "Twitter"
    case Instagram = "Instagram"
    case Pinterest = "Pinterest"
    case Weibo = "Weibo"
}

enum AuthorizationType: Int
{
    case Login
    case Register
}

public enum TextType: String
{
    case Privacy = "privacy"
    case Help = "help"
    case Terms = "terms"
}