//
//  DetailViewController.swift
//  MyMovieChart
//
//  Created by 윤재웅 on 2020/10/27.
//

import UIKit
import WebKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var wv: WKWebView!
    @IBOutlet weak var spinner: UIActivityIndicatorView!
    var mvo: MovieVO! // 목록 화면에서 전달하는 영화 정보를 받을 변수
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSLog("linkurl = \(mvo.detail!), title = \(mvo.title!)")
        
        self.wv.navigationDelegate = self
        
        // 네비게이션 바의 타이틀에 영화명을 출력한다.
        let navibar = self.navigationItem
        navibar.title = self.mvo.title
        
        // URLRequest 인스턴스를 생성한다.
        let url = URL(string: (self.mvo.detail)!)
        let req = URLRequest(url: url!)
        
        // loadRequest 메소드를 호출하면서 req를 인자값으로 전달한다
        self.wv.load(req)
    }
    
}

// MARK: - WKNavigationDelegate 프로토콜 구현
extension DetailViewController: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        spinner.startAnimating() // 인디케이터 뷰의 에니메이션을 실행
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating() // 인디케이터 뷰의 에니메이션을 중단
    }
    
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating() // 인디케이터 뷰의 에니메이션 중지
        
        alert("상세 페이지를 읽어오지 못했습니다."){
            // 버튼 클릭 시, 이전 화면으로 되돌려 보냄
            _ = self.navigationController?.popViewController(animated: true)
        }
        
        // 오류시 경고창
//        let alert = UIAlertController(title: "오류", message: "상세페이지를 읽어오지 못했습니다.", preferredStyle: .alert)
//        let cancelAction = UIAlertAction(title: "확인", style: .cancel) { (_) in
//            // 이전 화면으로 돌려보냄
//            _ = self.navigationController?.popViewController(animated: true)
//        }
//        alert.addAction(cancelAction)
//        self.present(alert, animated: false, completion: nil)
    
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        spinner.stopAnimating()
        alert("상세 페이지를 읽어오지 못했습니다."){
            _ = self.navigationController?.popViewController(animated: true)
        }
    }
}

// 오류시 경고창 간결하게 !
// MARK: - 심플한 경고창 함수 정의용 익스텐션
extension UIViewController {
    func alert(_ message:String, onClick: (() -> Void)? = nil) {
        let controller = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        controller.addAction(UIAlertAction(title: "OK", style: .cancel) { (_) in
            onClick?()
        })
        DispatchQueue.main.async {
            self.present(controller, animated: false, completion: nil)
        }
    }
}
