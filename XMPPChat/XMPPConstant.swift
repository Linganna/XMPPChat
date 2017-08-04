//
//  XMPPConstant.swift
//  XMPPChat
//
//  Created by LInganna on 02/08/17.
//  Copyright © 2017 LInganna. All rights reserved.
//

import Foundation


public enum XMPPConnectionStatus {
    case unknown
    case connecting
    case connected
    case disConnected
}

public enum MessageStatus: Int16{
    case Sending
    case Sent
    case Delivered
}
