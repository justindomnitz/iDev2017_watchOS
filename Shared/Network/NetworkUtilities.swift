//
//  NetworkUtilities.swift
//  iDev2017_watchOS WatchKit Extension
//
//  Created by Justin Domnitz on 7/11/17.
//  Copyright © 2017 Lowyoyo, LLC. All rights reserved.
//

import Foundation
#if os(iOS)
    import SystemConfiguration
#elseif os(watchOS)
    // Exclude SystemConfiguration framework
#endif

public class NetworkUtilities: NSObject, URLSessionTaskDelegate, URLSessionDataDelegate {
    
    let openSSLPublicKeyLength = 767
    let openSSLPublicKeyPrefix = "30 82 01 0A 02 82 01 01 00 "
    
    // MARK: Client app networking functions
    
#if os(iOS)
    @objc public static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
        zeroAddress.sin_family = sa_family_t(AF_INET)
        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }
        var flags = SCNetworkReachabilityFlags()
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) {
            return false
        }
        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
        return (isReachable && !needsConnection)
    }
#endif
    
    // MARK: Public Key Pinning Functions
    
    func sendRequest(_ request:URLRequest, completion: @escaping (_ json: AnyObject?, _ data: Data?, _ response: HTTPURLResponse?, _ error: NSError?) -> Void) {
        
        let sessionConfig = URLSessionConfiguration.ephemeral
        let session = Foundation.URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
        let _ = session.dataTask(with: request, completionHandler:{  (responseData, responseCode, error) -> Void in
            
            // to do
            
        })
        .resume()
    }
    
    func sendBackgroundRequest(_ request: URLRequest) {
        let sessionConfig = URLSessionConfiguration.background(withIdentifier: UUID().uuidString)
        let session = URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
        let _ = session.dataTask(with: request).resume()
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        print("NetworkingController - \(#function)")
        
        //to do
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        print("NetworkingController - \(#function)")
     
        //to do
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition,
        URLCredential?) -> Void) {
        
        // SSL Pinning - START
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust {
            if let serverTrust = challenge.protectionSpace.serverTrust {
                SecTrustEvaluate(serverTrust, nil)
                
                //to do
                
            }
        }
        // SSL Pinning - END
        
        let credential = URLCredentialStorage.shared.defaultCredential(for: challenge.protectionSpace)
        var disposition = Foundation.URLSession.AuthChallengeDisposition.rejectProtectionSpace;
        if challenge.previousFailureCount == 0 {
            disposition = Foundation.URLSession.AuthChallengeDisposition.useCredential;
        }
        completionHandler(disposition, credential);
    }
    
    //MARK: - Public Key Pinning Helper Functions
    
    private func showAlertControllerForGracefulExit(_ remoteVersionOfServerCertificateSummary:String) {
        
        // to do
        
    }
    
    private func publicKeyFromCertificate(_ certificateX509:UnsafeMutablePointer<X509>) -> String {
        var publicKey = ""
        
        let publicKeyASN1 = X509_get0_pubkey_bitstr(certificateX509) //ASN1_BIT_STRING
        if publicKeyASN1 != nil {
            for i:Int32 in 0...(publicKeyASN1?.pointee.length)! {
                publicKey += NSString.localizedStringWithFormat("%02x ", (publicKeyASN1?.pointee.data[Int(i)])!) as String
            }
        }
        
        //Make the string all upper case.
        publicKey = publicKey.uppercased()
        //Remove the openSSL public key prefix.
        publicKey = publicKey.replacingOccurrences(of: openSSLPublicKeyPrefix, with: "")
        //Remove the openSSL public key suffix.
        if publicKey.count > openSSLPublicKeyLength {
            publicKey = String(publicKey[publicKey.startIndex..<publicKey.index(publicKey.startIndex, offsetBy: Int(openSSLPublicKeyLength))])
        }
        return publicKey
    }
    
}
