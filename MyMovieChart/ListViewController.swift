//
//  ListViewController.swift
//  MyMovieChart
//
//  Created by 윤재웅 on 2020/10/23.
//

import UIKit


class ListViewController: UITableViewController{
    
    // 리팩토링
    // 수동 데이터
//    var dataset = [
//        ("다크나이트", "영웅물에 철학에 음악까지 더해져 예술이 되다.", "2008-09-04", 8.95, "darknight.jpg"),
//        ("호우시절", "때를 알고 내리는 좋은 비", "2009-10-08", 7.31,"rain.jpg"),
//        ("말할 수 없는 비밀", "여기서 너까지 다섯 걸음", "2015-05-07", 9.19, "secret.jpg")
//    ]
    var page = 1
    lazy var list: [MovieVO] = []
    @IBAction func more(_ sender: Any) {
        page += 1
        callMovieAPI()
        tableView.reloadData()
    }
    @IBOutlet weak var moreBtn: UIButton!
    
    override func viewDidLoad() {
        callMovieAPI()
    }
    
    func getThumbnailImage(_ index: Int) -> UIImage {
        // 인자값으로 받은 인덱스를 기반으로 해당하는 배열 데이터를 읽어옴
        let mvo = list[index]
        
        // 메모이제이션 : 저장된 이미지가 있으면 그것을 반환하고, 없을 경우 내려받아 저장한 후 반환
        if let savedImage = mvo.thumbnailImage {
            return savedImage
        } else {
            let url: URL! = URL(string: mvo.thumbnail!)
            let imageData = try! Data(contentsOf: url)
            mvo.thumbnailImage = UIImage(data: imageData) // UIImage를 MovieVO 객체에 우선 저장
            
            return mvo.thumbnailImage!
        }
    }
    
    func callMovieAPI() {
        // URL 객체 생성
        let url = "http://swiftapi.rubypaper.co.kr:2029/hoppin/movies?version=1&page=\(page)&count=10&genreId=&order=releasedateasc"
        
        let apiURI:URL! = URL(string: url)
        
        // REST API 호출
        let apidata = try! Data(contentsOf: apiURI)
        
        // 데이터 전송 결과를 로그로 출력(없어도 돼)
        let log = NSString(data: apidata, encoding: String.Encoding.utf8.rawValue) ?? ""
        NSLog("API Result=\( log )")
        
        // JSON 객체를 파싱하여 NSDictionary 객체로 받음
        do {
            let apiDictionary = try JSONSerialization.jsonObject(with: apidata, options: []) as! NSDictionary
            
            let hoppin = apiDictionary["hoppin"] as! NSDictionary
            let movies = hoppin["movies"] as! NSDictionary
            let movie = movies["movie"] as! NSArray
            
            // Iterator 처리로 API 데이터를 MovieVo 객체에 저장
            for rows in movie {
                // 순회 상수를 NSDictionary 타입으로 캐스팅
                let r = rows as! NSDictionary
                
                // 테이블 뷰 리스트를 구성할 데이터 형식
                let mvo = MovieVO()
                
                // movie 배열의 각 뎅이터를 mvo 상수의 속성에 대입
                mvo.title = r["title"] as? String
                mvo.description = r["genreNames"] as? String
                mvo.thumbnail = r["thumbnailImage"] as? String
                mvo.detail = r["linkUrl"] as? String
                mvo.rating = ((r["ratingAverage"] as! NSString).doubleValue)
                
                let url: URL! = URL(string: mvo.thumbnail!)
                let imageData = try! Data(contentsOf: url)
                mvo.thumbnailImage = UIImage(data: imageData)
                
                // list 배열에 추가
                list.append(mvo)
                
                // 전체 데이터 카운트를 얻는다.
                let totalCount = (hoppin["totalCount"] as? NSString)!.integerValue
                
                // totalCount가 읽어온 데이터 크기와 같거나 클 경우 더보기 버튼을 막는다.
                if list.count == totalCount {
                    moreBtn.isHidden = true
                }
            }
            
        }catch{ }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return list.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let rows = list[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListCell") as! MovieCell
        
        cell.title?.text = rows.title
        cell.desc?.text = rows.description
        cell.opendate?.text = rows.opendate
        cell.rating?.text = "\(rows.rating!)"
        // 로컬 파일 이용
        //cell.thumbnail.image = UIImage(named: rows.thumbnail!)
//
//        // 섬네일 경로를 인자값으로 하는 URL 객체 생성
//        let url:URL! = URL(string: rows.thumbnail!)
//
//        // 이미지를 읽어와 Data 객체에 저장
//        let imageData = try! Data(contentsOf: url)
        
        // UIImage 객체를 생성하여 아울렛 변수의 image 속성에 대입
        DispatchQueue.main.async(execute: {
            cell.thumbnail.image = self.getThumbnailImage(indexPath.row)
        })
        // cell.thumbnail.image = rows.thumbnailImage
        
   
        
        return cell
    }

}

// MARK: - 화면 전환 시 값을 넘겨주기 위한 세그웨이 관련 처리
extension ListViewController {
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // 실행된 세그웨이의 식별자가 "segue_detail" 이라면
        if segue.identifier == "segue_detail" {
            let path = tableView.indexPath(for: sender as! MovieCell)
            
            // 행 정보를 통해 선택된 영화 데이터를 찾은 다음, 목적지 뷰 컨트롤러의 mvo 변수에 대입한다.
            let detailVC = segue.destination as? DetailViewController
            detailVC?.mvo = list[path!.row]
        }
    }
    
    
}
