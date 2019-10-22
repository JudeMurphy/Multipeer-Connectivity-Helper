//
//  MPC-Service-Helper
//
//  Created by Jude Murphy on 10/18/17.
//  Copyright © 2017 Spark Apps, LLC. All rights reserved.
//
//  -------------------------------------
//  Updated 10/21/19 - Swift 5 Conversion - Jude Murphy

import Foundation
import MultipeerConnectivity

// Delegate To Notify The UI About Service Events
protocol MPCServiceDelegate {
    func payloadReceived(manager: MPCService, payload: Data)
    func connectedDevicesStateChanged(manager : MPCService, connectedDevices: [String])
}

class MPCService : NSObject {
    let myPeerId = MCPeerID(displayName: (UIDevice.current.identifierForVendor?.uuidString)!)
    private var mpcAdvertiser : MCNearbyServiceAdvertiser
    private var mpcBrowser : MCNearbyServiceBrowser
    
    // Change This Based On The Session Needed
    let MPCServiceType = "example-mpc"
    
    var delegate: MPCServiceDelegate?
    
    lazy var session : MCSession = {
        let session = MCSession(peer: self.myPeerId, securityIdentity: nil, encryptionPreference: .none)
        session.delegate = self
        return session
    }()
    
    override init() {
        print("Initialized MPC Service")
        mpcAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: MPCServiceType)
        mpcBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: MPCServiceType)
        super.init()
        mpcAdvertiser.delegate = self
        mpcAdvertiser.startAdvertisingPeer()
        
        mpcBrowser.delegate = self
        mpcBrowser.startBrowsingForPeers()
    }
    
    init(serviceType: String) {
        mpcAdvertiser = MCNearbyServiceAdvertiser(peer: myPeerId, discoveryInfo: nil, serviceType: serviceType)
        mpcBrowser = MCNearbyServiceBrowser(peer: myPeerId, serviceType: serviceType)
        super.init()
        mpcAdvertiser.delegate = self
        mpcAdvertiser.startAdvertisingPeer()
        
        mpcBrowser.delegate = self
        mpcBrowser.startBrowsingForPeers()
    }
    
    deinit {
        mpcBrowser.stopBrowsingForPeers()
        mpcAdvertiser.stopAdvertisingPeer()
    }
    
    // Sends Data to Peers
    // If There Are Any Connected Peers, Send Information
    func sendPayload(payload : Data) {
        do { try self.session.send(payload, toPeers: session.connectedPeers, with: .reliable) }
            catch let error { NSLog("%@", "Error Sending State: \(error)") }
    }
}

// Advertiser Delegate Methods
extension MPCService : MCNearbyServiceAdvertiserDelegate {
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didNotStartAdvertisingPeer error: Error) {
        NSLog("%@", "didNotStartAdvertisingPeer: \(error)")
    }
    
    func advertiser(_ advertiser: MCNearbyServiceAdvertiser, didReceiveInvitationFromPeer peerID: MCPeerID, withContext context: Data?, invitationHandler: @escaping (Bool, MCSession?) -> Void) {
        NSLog("%@", "didReceiveInvitationFromPeer \(peerID)")
        invitationHandler(true, self.session)
    }
}

// Browser Delegate Methods
extension MPCService : MCNearbyServiceBrowserDelegate {
    func browser(_ browser: MCNearbyServiceBrowser, foundPeer peerID: MCPeerID, withDiscoveryInfo info: [String : String]?) {
        NSLog("%@", "didFoundPeers: \(peerID)")
        NSLog("%@", "didInvitePeers: \(peerID)")
        browser.invitePeer(peerID, to: self.session, withContext: nil, timeout: 500)
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, lostPeer peerID: MCPeerID) {
        NSLog("%@", "didLostPeer: \(peerID)")
    }
    
    func browser(_ browser: MCNearbyServiceBrowser, didNotStartBrowsingForPeers error: Error) {
        NSLog("%@", "didErrorStarting: \(error)")
    }
}

// MCSession Delegate Methods
extension MPCService : MCSessionDelegate {
    func session(_ session: MCSession, peer peerID: MCPeerID, didChange state: MCSessionState) {
        NSLog("%@", "peer \(peerID) didChangeState: \(state)")
        self.delegate?.connectedDevicesStateChanged(manager: self, connectedDevices: session.connectedPeers.map{$0.displayName})
    }
    
    func session(_ session: MCSession, didReceive data: Data, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceivedData: \(data)")
        self.delegate?.payloadReceived(manager: self, payload: data)
    }
    
    func session(_ session: MCSession, didReceive stream: InputStream, withName streamName: String, fromPeer peerID: MCPeerID) {
        NSLog("%@", "didReceiveStream")
    }
    
    func session(_ session: MCSession, didStartReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, with progress: Progress) {
        NSLog("%@", "didStartReceivingResourceWithName")
    }
    
    func session(_ session: MCSession, didFinishReceivingResourceWithName resourceName: String, fromPeer peerID: MCPeerID, at localURL: URL?, withError error: Error?) {
        NSLog("%@", "didFinishReceivingResourceWithName")
    }
}
