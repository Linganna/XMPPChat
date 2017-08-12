//
//  XMPPConnection.swift
//  XMPPChat
//
//  Created by LInganna on 18/07/17.
//  Copyright © 2017 LInganna. All rights reserved.
//

import Foundation
import XMPPFramework

open class XMPPConnection:NSObject {
    var xmppStream: XMPPStream
    
    let hostName: String
    let userJID: XMPPJID
    let hostPort: UInt16
    let password: String
    
    var xmppDelegate:XMPPDelegate?
    let completionBlockQueue =  DispatchQueue(label: "xmppCompletionBlock")
    var reConnect:XMPPReconnect?
    
    public init(hostName: String, userJIDString: String, hostPort: UInt16 = 5222, password: String, delegate:XMPPDelegate) {
        
        self.hostName = hostName
        self.hostPort = hostPort
        self.password = password
        
        let userJID = XMPPJID(string: userJIDString)
        
        self.xmppStream = XMPPStream()
        self.xmppStream.hostName = hostName
        self.xmppStream.hostPort = hostPort
        self.userJID = userJID!
        self.xmppDelegate = delegate
        
        self.xmppStream.startTLSPolicy = XMPPStreamStartTLSPolicy.allowed
        self.xmppStream.myJID = self.userJID
        super.init()
        self.xmppStream.addDelegate(self, delegateQueue: completionBlockQueue)
        DDLog.add(DDTTYLogger.sharedInstance)
        
    }
    
    fileprivate func initializeReconnectXMPP() {
        self.reConnect = XMPPReconnect()
        self.reConnect?.activate(self.xmppStream)
        self.reConnect?.addDelegate(self, delegateQueue: completionBlockQueue)
    }
    
    
    public func connect() {
        if !self.xmppStream.isDisconnected() {
            return
        }
        try! self.xmppStream.connect(withTimeout: XMPPStreamTimeoutNone)
    }
    public func setManualReconnection(){
        self.reConnect = XMPPReconnect()
        self.reConnect?.activate(self.xmppStream)
        self.reConnect?.manualStart()
        self.reConnect?.addDelegate(self, delegateQueue: completionBlockQueue)
    }
    public func disconnect(){
        goOffline()
        self.xmppStream.disconnect()
        self.reConnect?.stop()
    }
    public func logOut() {
        self.disconnect()
        CoreDataManger.shared.clearData()
    }
    
    
    public func goOnline() {
        let presence = XMPPPresence()
        self.xmppStream.send(presence)
    }
    
    public func goOffline() {
        let presence = XMPPPresence(type: "unavailable")
        self.xmppStream.send(presence)
    }
    
    
    
    public func sendMessage(message:String, to:String) {
        
        DispatchQueue.global().async {
            let senderJID = XMPPJID(string: to)
            let msg = XMPPMessage(type: "chat", to: senderJID)
            msg?.addBody(message)
            msg?.addAttribute(withName: "id", stringValue: self.xmppStream.generateUUID())
            Messages.saveMessage(serverMsg: msg!, isOutGoing: true)
            self.xmppStream.send(msg)
        }
        
    }
    
    public func forwardMessage(forwardingMessage:String, to:String, originalMsgTofeild:String?, originalMssgFromFeild:String?) {
        
        DispatchQueue.global().async {
            let senderJID = XMPPJID(string: to)
            let msg = XMPPMessage(type: "chat", to: senderJID)
            msg?.addBody(forwardingMessage)
            msg?.addAttribute(withName: "id", stringValue: self.xmppStream.generateUUID())
            
            
            let forwarded = XMLElement(name: "forwarded")
            forwarded.setXmlns("urn:xmpp:forward:0")
            
            let delay = XMLElement(name:"delay" , xmlns: "urn:xmpp:delay")
            
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            delay?.addAttribute(withName: "stamp", stringValue:formatter.string(from: NSDate() as Date) )
            
            forwarded.addChild(delay!)
            
            let senderJID2 = XMPPJID(string: originalMsgTofeild)
            let msg2 = XMPPMessage(type: "chat", to: senderJID2)
            msg2?.addAttribute(withName: "from", stringValue: originalMssgFromFeild!)
            msg2?.addBody(forwardingMessage)
            msg2?.addAttribute(withName: "id", stringValue: self.xmppStream.generateUUID())
             msg2?.setXmlns((msg?.xmlns())!)

            
            forwarded.addChild(msg2!)
            
            msg?.addChild(forwarded)

            Messages.saveMessage(serverMsg: msg!, isOutGoing: true)
            self.xmppStream.send(msg)
        }

    }
    
    func sendPendingMessage() {
        if let moc =  CoreDataManger.shared.backgroundMoc{
            moc.performAndWait {
                let msgs = Messages.fetchOutGoingPendingMessages(inMoc: moc)
                if msgs.count > 0 {
                    for msg in msgs {
                        let senderJID = XMPPJID(string: msg.to)
                        let xmppMsg = XMPPMessage(type: "chat", to: senderJID)
                        xmppMsg?.addBody(msg.body)
                        xmppMsg?.addAttribute(withName: "id", stringValue: msg.id!)
                        self.xmppStream.send(xmppMsg)
                    }
                }
            }
        }
    }
    
    
    public func xmppConnectionStatus() -> XMPPStreamState {
        return self.xmppStream.state
    }
    
    public func isConnected() -> Bool {
        return self.xmppStream.isConnected()
    }
    
    public func isConnecting() -> Bool {
        return self.xmppStream.isConnecting()
    }
    
}


extension XMPPConnection: XMPPStreamDelegate,XMPPReconnectDelegate {
    
    public func xmppStreamDidConnect(_ stream: XMPPStream!) {
        NSLog("XMPP: Connected")
        self.xmppDelegate?.xmppConnectionState(xmppConnectionStatue: .connecting)
        try! stream.authenticate(withPassword: self.password)
        guard let _ = self.reConnect else {
            self.initializeReconnectXMPP()
            return
        }
    }
    public func xmppStreamDidDisconnect(_ sender: XMPPStream!, withError error: Error!) {
        NSLog("XMPP: DisConnected error:\(error)")
        goOffline()
        self.xmppDelegate?.xmppConnectionState(xmppConnectionStatue: .disConnected)
        
    }
    
    public func xmppStreamDidAuthenticate(_ sender: XMPPStream!) {
        print("XMPP: Authenticated")
        goOnline()
        self.xmppDelegate?.xmppConnectionState(xmppConnectionStatue: .connected)
        
        self.sendPendingMessage()
    }
    
    func xmppStream(sender: XMPPStream!, didReceiveIQ iq: XMPPIQ!) -> Bool {
        print("XMPP receive IQ - Query")
        return false
    }
    
    public func xmppStream(_ sender: XMPPStream!, didSend message: XMPPMessage!) {
        print("XMPP send message \(message)")
        Messages.updateMessage(satue: .Sent, for: message.elementID())
    }
    
    public func xmppStream(_ sender: XMPPStream!, didReceive message: XMPPMessage!) {
        print("XMPP receive message \(message)")
        Messages.saveMessage(serverMsg: message, isOutGoing: false)
        self.xmppDelegate?.xmppDidReceiveMessage(message: message.body(), to: message.toStr())
    }
    
    
    public func xmppReconnect(_ sender: XMPPReconnect!, shouldAttemptAutoReconnect connectionFlags: SCNetworkConnectionFlags) -> Bool {
        return true
    }
    
    public func xmppReconnect(_ sender: XMPPReconnect!, didDetectAccidentalDisconnect connectionFlags: SCNetworkConnectionFlags) {
        NSLog("didDetectAccidentalDisconnect: \(connectionFlags)")
    }
}

