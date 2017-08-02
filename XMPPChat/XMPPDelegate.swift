//
//  XMPPDelegate.swift
//  XMPPChat
//
//  Created by LInganna on 18/07/17.
//  Copyright © 2017 LInganna. All rights reserved.
//

import Foundation


public protocol XMPPDelegate{
    
    func xmppConnectionState(xmppConnectionStatue:XMPPConnectionStatus)
    
    func xmppDidReceiveMessage(message:String, to:String)
}
