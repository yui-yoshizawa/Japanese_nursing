//
//  WebViewController.swift
//  Japanese_nursing
//
//  Created by 吉澤優衣 on 2020/11/20.
//  Copyright © 2020 吉澤優衣. All rights reserved.
//

import RxSwift
import UIKit
import WebKit

class WebViewController: UIViewController {

    // MARK: - Outlets

    @IBOutlet weak var webView: WKWebView!

    // MARK: - Properties

    var url: String = ""
    var titleText: String = ""
    var progressView = UIProgressView()

    // MARK: - LifeCycles

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationController?.navigationBar.tintColor = R.color.textBlue()
        navigationItem.title = titleText

        if let url = NSURL(string: url) {
            let request = NSURLRequest(url: url as URL)
            webView.load(request as URLRequest)
        }

        // インジケータとプログレスバーのKVO
        webView.addObserver(self, forKeyPath: "loading", options: .new, context: nil)
        webView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil)

        // プログレスバー
        progressView = UIProgressView(frame: CGRect(x: 0, y: navigationController!.navigationBar.frame.size.height - 2, width: view.frame.size.width, height: 10))
        progressView.progressViewStyle = .bar
        progressView.progressTintColor = R.color.textBlue()
        navigationController?.navigationBar.addSubview(progressView)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        progressView.setProgress(0.0, animated: false)
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey: Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "estimatedProgress"{
            progressView.setProgress(Float(webView.estimatedProgress), animated: true)
        } else if keyPath == "loading"{
            if webView.isLoading {
                progressView.setProgress(0.1, animated: true)
            } else {
                progressView.setProgress(0.0, animated: false)
            }
        }
    }
    
}

// MARK: - MakeInstance

extension WebViewController {

    static func makeInstance(url: String, titleText: String) -> UIViewController {
        guard let vc = R.storyboard.webView.webViewController() else {
            assertionFailure("Can't make instance 'WebViewController'.")
            return UIViewController()
        }
        vc.url = url
        vc.titleText = titleText
        return vc
    }

}
