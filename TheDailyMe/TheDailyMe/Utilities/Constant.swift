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
    
    struct Color {
        /// Default Color (Background)
        static let Blue = UIColor(hex: 0x25A3EB)
        
        /// Dark Blue Color (Enter Code Button Border)
        static let BlueDark = UIColor(hex: 0x137DBA)
        
        /// Light Blue Color (TextFields Background)
        static let BlueLight = UIColor(hex: 0x7CC8F3)
        
        /// Font Color (Don't use black color)
        static let FontDark = UIColor(hex: 0x1E2326)
        
        static let Green = UIColor(hex: 0x88D243)
        
        /// Orange Color (Badges)
        static let Orange = UIColor(hex: 0xF35C34)
        
        /// Light Gray Color (Border in Gray Buttons)
        static let DarkGray = UIColor(hex: 0x666666)
        
        /// Gray Color (Font Color in Gray Buttons)
        static let Gray = UIColor(hex: 0x999999)
        
        static let LightGray = UIColor(hex: 0xCCCCCC)
        
        static let SuperLightGray = UIColor(hex: 0xEEEEEE)
        
    }
    
    struct Font {
        /**
        Default Font - Regular
        
        - parameter fontSize:
        
        - returns: UIFont
        */
        static func Regular(fontSize: CGFloat) -> UIFont {
            return UIFont(name: "ProximaNovaSoft-Regular", size: fontSize)!
        }
        
        /**
        Default Font - Medium
        
        - parameter fontSize:
        
        - returns: UIFont
        */
        static func Medium(fontSize: CGFloat) -> UIFont {
            return UIFont(name: "ProximaNovaSoft-Medium", size: fontSize)!
        }
        
        /**
        Default Font - Bold
        
        - parameter fontSize:
        
        - returns: UIFont
        */
        static func Bold(fontSize: CGFloat) -> UIFont {
            return UIFont(name: "ProximaNovaSoft-Bold", size: fontSize)!
        }
    }
    
    struct Numeric {
        /// Default iOS Offset
        static let Offset: CGFloat = 8.0
        
        /// Corner Radius
        static let CornerRadius: CGFloat = 5.0
        
        /// Border Width
        static let BorderWidth: CGFloat = 3.0
        
        static let FieldOffset: CGFloat = 15.0
    }
    
    struct String {
        
        struct Achievement {
            
            static let WaterBaby = "water_baby"
            
            static let RideName = "ride_"
        }
        
        struct Date {
            
            /// Default DateFormat (User in server side responses)
            static let FormatWithTimezone = "yyyy-MM-dd HH:mm:ss Z"
            static let Format = "yyyy-MM-dd"
            static let ShortFormat = "dd/MM/yyyy"
            static let HourMinutesFormat = "HH:mm"
        }
        
        struct User {
            
            static let Picture = "PPUserPicture"
            
            static let Email = "PPUserEmail"
            
            static let Password = "PPUserPassword"
            
            static let CurrentPark = "PPUserCurrentPark"
        }
        
        struct Segue {
            
            static let Location = "PPLocationViewControllerSegueID"
            
            static let Confirmation = "PPConfirmationViewControllerSegueID"
            
            static let Albums = "PPAlbumsViewControllerSegueID"
            
            static let Album = "PPAlbumViewControllerSegueID"
            
            static let Profile = "PPProfileShow"
            
            static let ChangePassword = "PPChangePasswordShow"
            
            static let Help = "PPHelpShow"
            
            static let Privacy = "PPPrivacyShow"
            
            static let Terms = "PPTermsShow"
            
            static let ChoosePhoto = "PPChoosePhotoSegueID"
            
            static let ConfirmPhoto = "PPConfirmPhotoSegueID"
            
            static let Achievement = "PPAchievementViewControllerSegueID"
            
            static let Photo = "PPPhotoViewControllerSegueID"
            
            static let PurchasePhoto = "PPPurchaseViewControllerSegueID"
        }
        
        struct Notification {
            
            static let UserDidAuthorized = "PPUserDidAuthorized"
            static let UserDidUnauthorized = "PPUserDidUnauthorized"
            static let UserAuthorizationError = "PPUserAuthorizationError"
        }
        
    }
    
    struct Time {
        static let PickerAnimation = 0.25
    }

}