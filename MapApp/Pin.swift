//
//  Pin.swift
//  MapApp
//
//  Created by Yoshiaki Kato on 2018/10/28.
//  Copyright © 2018 Yoshiaki Kato. All rights reserved.
//

import UIKit
import MapKit

class Pin: NSObject, MKAnnotation {
    
    //位置情報
    var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D()
    
    //追加時の入力テキスト
    var title: String?
    
    // 位置情報とテキストを格納した状態のオブジェクトを返します
    init(geo:CLLocationCoordinate2D, text: String?){
        coordinate = geo
        title = text
    }
    
    // UserDefaultsから取り出した各値を変換したオブジェクトを返します
    init(dictionary: [String: Any]) {
        if let latitude = dictionary["latitude"] as? Double, let longitude = dictionary["longitude"] as? Double {
            coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        }
        
        if let tit = dictionary["title"] as? String {
            title = tit
        }
    }
    
    // 保持中の値をUserDefaultsに登録できるように変換
    func toDictionary() -> [String: Any] {
        
        //辞書型
        var dict: [String: Any] = [:]
        
        //緯度・経度
        dict["latitude"] = coordinate.latitude
        dict["longitude"] = coordinate.longitude
        
        //テキスト
        if let tit = title {
            dict["title"] = tit
        }
        
        return dict
    }
}
