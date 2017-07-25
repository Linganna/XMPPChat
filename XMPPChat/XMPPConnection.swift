//
//  XMPPConnection.swift
//  XMPPChat
//
//  Created by LInganna on 18/07/17.
//  Copyright © 2017 LInganna. All rights reserved.
//

import Foundation
import XMPPFramework

open class XMPPConnection:NSObject{
    var xmppStream: XMPPStream
    
    let hostName: String
    let userJID: XMPPJID
    let hostPort: UInt16
    let password: String
    
    var xmppDelegate:XMPPDelegate?
    
    
    public init(hostName: String, userJIDString: String, hostPort: UInt16 = 5222, password: String, delegate:XMPPDelegate) {
        
        self.hostName = hostName
        self.hostPort = hostPort
        self.password = password
        
        let userJID = XMPPJID(string: userJIDString)
        
        self.xmppStream = XMPPStream()
        self.xmppStream.hostName = hostName
        self.xmppStream.hostPort = hostPort
        self.userJID = userJID!
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        self.xmppDelegate = delegate
        self.xmppStream.myJID = self.userJID
        super.init()
        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)
        DDLog.add(DDTTYLogger.sharedInstance)
        
    }
    
    public func connect() {
        if !self.xmppStream.isDisconnected() {
            return
        }
        
        try! self.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
    }
    
    public func disconnect(){
        goOffline()
        self.xmppStream.disconnect()
        
    }
    
    public func goOnline() {
        let presence = XMPPPresence()
        self.xmppStream.send(presence)
        //
    }
    
    public func goOffline() {
        let presence = XMPPPresence(type: "unavailable")
        self.xmppStream.send(presence)
    }
    
    
    public func sendMessage(message:String, to:String) {
        let senderJID = XMPPJID(string: to)
        let msg = XMPPMessage(type: "chat", to: senderJID)
        
        msg?.addBody(message)
        self.xmppStream.send(msg)
        
        
    }
    
}


extension XMPPConnection: XMPPStreamDelegate {
    
    public func xmppStreamDidConnect(_ stream: XMPPStream!) {
        print("Stream: Connected")
        try! stream.authenticate(withPassword: self.password)
    }
    public func xmppStreamDidDisconnect(_ sender: XMPPStream!, withError error: Error!) {
        print("Stream: DisCOnnected")
        
    }
    
    public func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        print("Stream: Authenticated")
        goOnline()
        self.xmppDelegate?.xmppConnectionState(status: true)
        
    }
    
    
    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
        print("Did receive IQ")
        return false
    }
    
    public func xmppStream(_ sender: XMPPStream!, didSend message: XMPPMessage!) {
        print("Did send message \(message)")
        Messages.saveMessage(serverMsg: message, isOutGoing: true)
    }
    
    
    public func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage!) {
        print("Did receive message \(message)")
        Messages.saveMessage(serverMsg: message, isOutGoing: false)
        
    }
    
    
}

