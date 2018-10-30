//
//  ViewController.swift
//  MapApp
//
//  Created by Yoshiaki Kato on 2018/10/28.
//  Copyright © 2018 Yoshiaki Kato. All rights reserved.
//

import UIKit
import MapKit

class ViewController: UIViewController {
    
    @IBOutlet var mapView: MKMapView!
    
    // UserDefaultsの保存・読み込み時に使う名前
    let userDefName = "pins"
    
    // ピンの保存
    func savePin(_ pin: Pin) {
        let userDefaults = UserDefaults.standard
        
        // 保存するピンをUserDefaults用に変換します。
        let pinInfo = pin.toDictionary()
        
        // すでにピン保存データがある場合、append
        if var savedPins = userDefaults.object(forKey: userDefName) as? [[String: Any]] {
            
            savedPins.append(pinInfo)
            userDefaults.set(savedPins, forKey: userDefName)
        
        // まだピン保存データがない場合、新しい配列
        } else {
            
            let newSavedPins: [[String: Any]] = [pinInfo]
            userDefaults.set(newSavedPins, forKey: userDefName)
        }
    }
    
    // 既に保存されているピンを取得
    func loadPins() {
        let userDefaults = UserDefaults.standard
        
        if let savedPins = userDefaults.object(forKey: userDefName) as? [[String: Any]] {
            
            // 現在のピンを削除
            self.mapView.removeAnnotations(self.mapView.annotations)
            
            for pinInfo in savedPins {
                let newPin = Pin(dictionary: pinInfo)
                self.mapView.addAnnotation(newPin)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 保存されているピンを配置
        loadPins()
    }

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
    
}

