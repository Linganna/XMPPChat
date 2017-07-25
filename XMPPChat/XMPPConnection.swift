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

    
    init(hostName: String, userJIDString: String, hostPort: UInt16 = 5222, password: String, delegate:XMPPDelegate) {
        
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
        super.init()
        self.xmppStream.addDelegate(self, delegateQueue: DispatchQueue.main)

    }
    
    func connect() {
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
        let message = "Yo!"
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
    
    public func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        self.xmppStream.send(XMPPPresence())
        print("Stream: Authenticated")
        self.xmppDelegate?.xmppConnectionState(status: true)
        goOnline()
    }
    
    
    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
        print("Did receive IQ")
        return false
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveMessage message: XMPPMessage!) {
        print("Did receive message \(message)")
        Messages.saveMessage(serverMsg: message, isOutGoing: false)
    }
    
    func xmppStream(sender: XMPPStream!, didSendMessage message: XMPPMessage!) {
        print("Did send message \(message)")
    }
    

}
