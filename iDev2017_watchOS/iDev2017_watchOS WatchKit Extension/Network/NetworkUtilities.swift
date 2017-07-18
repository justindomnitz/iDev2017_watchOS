//
//  NetworkUtilities.swift
//  iDev2017_watchOS WatchKit Extension
//
//  Created by Justin Domnitz on 7/11/17.
//  Copyright © 2017 Lowyoyo, LLC. All rights reserved.
//

import Foundation

public class NetworkUtilities: NSObject, URLSessionTaskDelegate {
    
    let openSSLPublicKeyLength = 767
    let openSSLPublicKeyPrefix = "30 82 01 0A 02 82 01 01 00 "
    
    // MARK: Public Key Pinning Functions
    
    open func downloadTask(with: URL) {
        //to do
    }
    
    open func sendRequest(_ request:URLRequest, completion: @escaping (_ json: AnyObject?, _ data: Data?, _ response: HTTPURLResponse?, _ error: NSError?) -> Void) {
        
        let sessionConfig = URLSessionConfiguration.ephemeral
        let session = Foundation.URLSession(configuration: sessionConfig, delegate: self, delegateQueue: OperationQueue.main)
        let _ = session.dataTask(with: request, completionHandler:{  (responseData, responseCode, error) -> Void in
            
            // to do
            
        })
        .resume()
    }
    
    open func urlSession(_ session: URLSession, task: URLSessionTask, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition,
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
        if publicKey.characters.count > openSSLPublicKeyLength {
            publicKey = publicKey.substring(to: publicKey.characters.index(publicKey.startIndex, offsetBy: Int(openSSLPublicKeyLength)))
        }
        return publicKey
    }
    
}
