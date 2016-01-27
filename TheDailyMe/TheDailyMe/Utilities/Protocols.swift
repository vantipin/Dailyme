//
// Protocols.swift
//  PicPlay
//
//  Created by Aleksey Orlov on 6/15/15.
//  Copyright (c) 2015 Picsolve. All rights reserved.
//

import Foundation
import UIKit

public protocol NetworkDelegate: AnyObject
{
    var identifier: String { get }
    
    func requestProcessed(type:RequestType, identifier: String)
    func requestFailed(type:RequestType, identifier: String, httpCode: Int?, customCode:ErrorCode?)
    func requestProgress(type:RequestType, identifier: String, value: Float)
}

// Sharing Functionalities Delegates

protocol CustomShareProtocol {
    func showCustomShareView(interactionController: UIDocumentInteractionController)
}

protocol PickerViewProtocol {
    func selectRow(row : Int?)
    func closePickerView()
}
