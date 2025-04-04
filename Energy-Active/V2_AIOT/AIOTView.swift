//
//  ContentView.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/14.
//

import SwiftUI

struct AIOTView: View {
    @EnvironmentObject var mqttManager: MQTTManager // 從環境取得 MQTTManager
    
//    @Binding var loginflag:Bool
    @Binding var robotIconDisplay:Bool // 機器人顯示控制
    @Binding var showAIOTFullScreen:Bool // 智慧控制全螢幕控制（默認：關閉）

    @State private var selectedTab = "" // 選擇設備控制
    @State private var status = false // 控制顯示標題名稱（內含 返回 icon）
    
    @AppStorage("isTempConnected") private var isTempConnected = true  // ✅ 溫濕度 記住連線狀態
    @AppStorage("isACConnected")   private var isACConnected = true    // ✅ 冷氣 記住連線狀態
    @AppStorage("isDFConnected")   private var isDFConnected = true    // ✅ 除濕機 記住連線狀態
    @AppStorage("isREMCConnected") private var isREMCConnected = true  // ✅ 遙控器 記住連線狀態
    @AppStorage("isESTConnected")  private var isESTConnected = true   // ✅ 插座 記住連線狀態
    
    // ✅ 根據 selectedTab 動態決定 `status`
    private func bindingForSelectedTab() -> Binding<Bool> {
        switch selectedTab {
            case "溫濕度":
                return $isTempConnected
            case "空調":
                return $isACConnected
            case "除濕機":
                return $isDFConnected
            case "遙控器":
                return $isREMCConnected
            case "插座":
                return $isESTConnected
            default:
                return .constant(false)
        }
    }
    
    var body: some View {
        VStack(spacing: 20) {
            if(selectedTab != "") {
                // ✅ 傳遞 selectedTab 和 status
                HeaderName(selectedTab: $selectedTab, status: bindingForSelectedTab(), showAIOTFullScreen: $showAIOTFullScreen)
            }
            // 測試使用，可去除
            // Text(mqttManager.loginResponse ?? "等待登入回應...")
            
            // 根據 selectedTab 顯示對應元件
            switch self.selectedTab {
                case "溫濕度":
                    Temperature(isConnected: $isTempConnected)
                case "空調":
                    AirConditioner(isConnected: $isACConnected)
                case "除濕機":
                    Dehumidifier(isConnected: $isDFConnected)
                case "遙控器":
                    RemoteControl(isConnected: $isREMCConnected)
                case "插座":
                    ElectricSocket()
                default:
                    Spacer()
                    Loading(text: "Loading..")
            }
            
            Spacer()
            
            // 底部導航欄
            NavigationBar(selectedTab: $selectedTab)
                .environmentObject(mqttManager) // 確保能讀取 availables
        }
        .padding()
        .background(Color.light_green.opacity(1))
        .onAppear {
            mqttManager.connectMQTT() // 當 isConnected 變為 true，啟動 MQTT

            print("進入 AIOT 頁面")
            // MARK: 機器人圖示為關閉
            self.robotIconDisplay = false
        }
        .onDisappear {
            mqttManager.disconnectMQTT() // 離開畫面 斷開 MQTT 連線
        }
        .onChange(of: mqttManager.isConnected) { newConnect in
            // 連線MQTT
            if newConnect {
                mqttManager.publishApplianceUserLogin(username: "user", password: "user+user")
                mqttManager.publishApplianceTelemetryCommand(subscribe: true)
            }
        }
    }
}
