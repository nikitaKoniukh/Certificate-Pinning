//
//  ViewController.swift
//  MSAppsWebView
//
//  Created by Nikita Koniukh on 25/05/2020.
//  Copyright © 2020 Nikita Koniukh. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, URLSessionDelegate {

    @IBOutlet var webView: WKWebView!

    let certificates: [Data] = {
        let url = Bundle.main.url(forResource: "msapps", withExtension: "cer")!
        let data = try! Data(contentsOf: url)
        return [data]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        let url = URL(string: "https://msapps.mobi")!
        let session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

            let task = session.dataTask(with: url) { data, response, error in
                if let error = error {
                    print(error)
                    return
                }
                print("Loaded!")
                if let data = data {
                    self.webView.load(data, mimeType: response?.mimeType ?? "", characterEncodingName: response?.textEncodingName ?? "", baseURL: url)
                }
            }
            task.resume()
        }


}

extension ViewController {
    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let trust = challenge.protectionSpace.serverTrust,
             SecTrustGetCertificateCount(trust) > 0 {
            if let certificate = SecTrustGetCertificateAtIndex(trust, 0) {
                let data = SecCertificateCopyData(certificate) as Data

                if certificates.contains(data) {
                    completionHandler(.useCredential, URLCredential(trust: trust))
                    return
                }
            }
        }
        completionHandler(.cancelAuthenticationChallenge, nil)
    }
}

