//
//  BTWebViewController.swift
//  Shas Illuminated
//
//  Created by Binyamin Trachtman on 26/11/2019.
//  Copyright © 2019 Binyamin Trachtman. All rights reserved.
//

import UIKit
import WebKit

public class BTWebViewController: UIViewController, WKNavigationDelegate, WKUIDelegate
{

    @IBOutlet weak var webView:WKWebView?
    
    @IBOutlet public weak var loadingView:UIView?
    @IBOutlet public weak var loadingGifImageview:UIImageView?
    @IBOutlet public weak var loadingImageBackGroundView:UIView?
    @IBOutlet public weak var errorMessageLabel:UILabel?
    @IBOutlet public weak var titleLabel:UILabel?
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        self.webView?.navigationDelegate = self
        self.webView?.uiDelegate = self
        
        self.loadingImageBackGroundView?.backgroundColor = UIColor.white
        self.loadingImageBackGroundView?.layer.borderColor = UIColor.init(HexColor: "2A5F87").cgColor
        self.loadingImageBackGroundView?.layer.borderWidth = 1.0
        self.loadingImageBackGroundView?.layer.cornerRadius = 3.0
    }

    @IBAction func backButtonClicked(_ sender: AnyObject) {
        
        if webView?.canGoBack ?? false {
            webView?.goBack()
        }
        else {
            if self.navigationController != nil
            {
                self.navigationController?.popViewController(animated: true)
            }
            else{
                self.dismiss(animated: true, completion:nil)
            }
        }
    }

    
    public func loadUrl(_ urlString : String, title:String?)
    {
        if let url = URL(string: urlString)
        {
            self.webView?.load(URLRequest(url: url))
        }
        
        self.titleLabel?.text = title
    }
    
    func showLoadingView()
    {
        self.loadingView?.isHidden = false
        self.errorMessageLabel?.isHidden = true
        self.loadingView?.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        self.loadingGifImageview?.image = UIImage.gifWithName("Spinner")
    }
    
    func hideLoadingView()
    {
        self.loadingView?.isHidden = true
        self.loadingGifImageview?.image = nil
    }
    
    //MARK Web view delegate methods
    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        self.showLoadingView()
        
    }
    
    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!)
    {
        self.hideLoadingView()
        
        self.webView?.isHidden = false
        
        //self.delegate?.webView!(webView, didFinish: navigation)
    }

}
