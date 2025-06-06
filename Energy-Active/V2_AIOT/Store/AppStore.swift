//
//  Store.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/2/27.
//

import SwiftUI

// ✅ 1. 創建全域狀態 Store
class AppStore: ObservableObject {
    @Published var showPopup: Bool = false // 提示窗顯示 開關
//    @Published var isAIControl: Bool = false // AI決策顯示 開關
    @Published var title: String = "執行AI決策"
    @Published var message: String  = "冷氣: 27度 \n除濕機: 開啟55%濕度 \n電風扇: 開啟"
    @Published var notificationsResult: String  = "冷氣: 27度 \n除濕機: 開啟55%濕度 \n電風扇: 開啟"
    
    @Published var userToken: String? {
        didSet {
            if let token = userToken {
                UserDefaults.standard.set(token, forKey: "access_token")
            } else {
                UserDefaults.standard.removeObject(forKey: "access_token")
            }
        }
    }
    
    init() {
        // 嘗試還原 UserDefaults 中的 token
        self.userToken = UserDefaults.standard.string(forKey: "access_token")
    }

}
