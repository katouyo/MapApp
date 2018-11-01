//
//  ViewController.swift
//  MapApp
//
//  Created by Yoshiaki Kato on 2018/10/28.
//  Copyright © 2018 Yoshiaki Kato. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, UISearchBarDelegate, CLLocationManagerDelegate, MKMapViewDelegate {
    
    @IBOutlet var mapView: MKMapView!
    @IBOutlet var testSearchBar: UISearchBar!
    
    // UserDefaultsの保存・読み込み時に使う名前
    let userDefName = "pins"
    // 位置情報
    var locationManager: CLLocationManager!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 保存されているピンを配置
        loadPins()
        // 位置情報
        setupLocationManager()
        // 検索
        setupSearchBarManager()
    }
    
    // 位置情報
    func setupLocationManager() {
        locationManager = CLLocationManager()
        //位置情報使用許可
        guard let locationManager = locationManager else { return }
        locationManager.requestWhenInUseAuthorization()
        
        let status = CLLocationManager.authorizationStatus()
        if status == .authorizedWhenInUse {
            //管理マネージャのデリゲート先:ViewControllerクラス
            locationManager.delegate = self
            //位置情報更新:10mごと
            locationManager.distanceFilter = 10
            //位置情報取得開始
            locationManager.startUpdatingLocation()
        }
        
    }
    
    //検索
    func setupSearchBarManager() {
        //デリゲート先を自分に設定する。
        testSearchBar.delegate = self
    }
    
    //位置情報を取得・更新するたびに呼ばれる
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.first
        let latitude = location?.coordinate.latitude
        let longitude = location?.coordinate.longitude
        
        //中心点
        let center: CLLocationCoordinate2D = CLLocationCoordinate2DMake(latitude!, longitude!)
        mapView.setCenter(center, animated: true)
        
        // 縮尺.
        // 表示領域.
        let mySpan: MKCoordinateSpan = MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        let myRegion: MKCoordinateRegion = MKCoordinateRegion(center: center, span: mySpan)
        // mapViewにregionを追加.
        mapView.setRegion(myRegion, animated:true)
        
        //mapView.userTrackingMode = MKUserTrackingMode.followWithHeading
 
        print("latitude: \(latitude!)\nlongitude: \(longitude!)")
        
    }
    
    // 既に保存されているピンを取得して配置
    func loadPins() {
        
        //<ピンの色の変更で使おうと思ってやめた>
        //デリゲート先を自分に設定する。
        //mapView.delegate = self
        
        if let savedPins = UserDefaults.standard.object(forKey: userDefName) as? [[String: Any]] {
            
            // 現在のピンを削除
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            //"pins"の数だけ繰り返し(配列)
            //pinInfo(辞書)
            for pinInfo in savedPins {
                
                //クラス呼び出し
                //PinクラスのインスタンスをnewPinに格納
                let newPin = Pin(dictionary: pinInfo)
                //pinを置く
                self.mapView.addAnnotation(newPin)
            }
            //繰り返し終了
        }
    }
    
    // ピンの保存
    func savePin(_ pin: Pin) {
        
        // 保存するピンをUserDefaults用に変換します。
        // [String: Any]型のdictionary
        // "title":(入力テキスト), "latitude":(緯度), "longitude":(経度)
        let pinInfo = pin.toDictionary()
        
        // すでにピン保存データがある場合、append
        if var savedPins = UserDefaults.standard.object(forKey: userDefName) as? [[String: Any]] {
            
            savedPins.append(pinInfo)
            UserDefaults.standard.set(savedPins, forKey: userDefName)
        
        // まだピン保存データがない場合、新しい配列
        } else {
            
            let newSavedPins: [[String: Any]] = [pinInfo]
            UserDefaults.standard.set(newSavedPins, forKey: userDefName)
        }
    }
    
    
    @IBAction func deleteButton(_ sender: Any) {
        // アラートの作成
        let alert = UIAlertController(title: "ピンの削除", message: "保存されているすべてのピンを削除します", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "削除", style: .default, handler: { (action: UIAlertAction) -> Void in
            // 削除ボタンのアクション
            // 現在のピンを削除
            self.mapView.removeAnnotations(self.mapView.annotations)
            // 保存されたピンを削除
            UserDefaults.standard.removeObject(forKey: self.userDefName)
        }))
        // アラートの表示
        present(alert, animated: true, completion: nil)
    }
    
    //ロングタップされたとき
    @IBAction func longTapMapView(_ sender: UILongPressGestureRecognizer) {
        
        // ロングタップ認識時以外では何もしない
        if sender.state != UIGestureRecognizer.State.began {
            
            return
        }
        
        // 位置情報を取得します。
        // 座標
        let point = sender.location(in: mapView)
        // 地図上の位置情報へ変換
        let geo = mapView.convert(point, toCoordinateFrom: mapView)
        
        // アラートの作成
        let alert = UIAlertController(title: "スポット登録", message: "この場所に残すメッセージを入力してください。", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "キャンセル", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "登録", style: .default, handler: { (action: UIAlertAction) -> Void in
            // 登録ボタンのアクション
            // alertで作成したtextFieldの内容
            let pin = Pin(geo: geo, text: alert.textFields?.first?.text)
            // ピンとして登録
            self.mapView.addAnnotation(pin)
            // ピンをuserDefaultsに保存
            self.savePin(pin)
        }))
        
        // ピンに登録するテキスト用の入力フィールドをアラートに追加します。
        alert.addTextField(configurationHandler: { (textField: UITextField) in
            textField.placeholder = "メッセージ"
            //textField.attributedPlaceholder = NSAttributedString(string: "メッセージ", attributes: [NSAttributedString.Key.foregroundColor : UIColor.red])

        })
        
        // アラートの表示
        present(alert, animated: true, completion: nil)
    }
    
    /*
     //<ピンの色の変更で使おうと思ってやめた>
    //viewForAnnotation デリゲートメソッドを実装します。
    //このメソッドはピンが画面に表示する直前に呼ばれ、今から表示するピンの属性や外観などを
    //MKPinAnnotationView オブジェクトを使って指定することができます。
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }
        
        let reuseId = "pin"
        var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView
        if pinView == nil {
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView?.animatesDrop = true
        }
        else {
            pinView?.annotation = annotation
        }
        //色の変更
        pinView?.pinTintColor = UIColor.purple
        return pinView
    }
     */
    
    //検索ボタン押下時の呼び出しメソッド
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        //キーボードを閉じる。
        testSearchBar.resignFirstResponder()
        
        //検索条件を作成する。
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = testSearchBar.text
        
        //検索範囲はマップビューと同じにする。
        request.region = mapView.region
        
        //ローカル検索を実行する。
        let localSearch:MKLocalSearch = MKLocalSearch(request: request)
        localSearch.start(completionHandler: {(result, error) in
            
            for placemark in (result?.mapItems)! {
                if(error == nil) {
                    
                    //検索された場所にピンを刺す。
                    let annotation = MKPointAnnotation()
                    annotation.coordinate = CLLocationCoordinate2DMake(placemark.placemark.coordinate.latitude, placemark.placemark.coordinate.longitude)
                    annotation.title = placemark.placemark.name
                    annotation.subtitle = placemark.placemark.title
                    self.mapView.addAnnotation(annotation)
                    
                } else {
                    //エラー
                    print(error!)
                }
            }
        })
        // アラートの作成
        let alert = UIAlertController(title: "検索が完了しました", message: "OKを押して続けてください", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

