//
//  RemoteControl.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/22.
//

import SwiftUI

struct RemoteControl: View {
    @Binding var isConnected: Bool  // [父層控制] 設備藍芽是否已連線
    //    @EnvironmentObject var mqttManager: MQTTManager // 取得 MQTTManager
    
    // MARK: - 自定義遙控器名稱功能 暫時 默認：完成，用久不關閉
    //    @AppStorage("editRemoteName") private var editRemoteName: String = ""   // ✅ 自定義設備名稱 記住連線狀態
    //    @AppStorage("hasControl") private var hasControl: Bool  = true         // ✅ 自定義遙控器開關 記住連線狀態
    //    @AppStorage("isPowerOn")  private var isPowerOn: Bool = true            // ✅ 設備控制， 默認：關閉
    
    @State var editRemoteName: String = "遙控器電源" // 自定義設備名稱
    @State var hasControl: Bool = true  // 自定義遙控器是否開始設定
    
    // MARK: - 以下正常使用
    @State private var isPowerOn: Bool = false               // 設備控制， 默認：關閉
    @State private var isRemoteType = ""                     // 設備名稱， 默認：空
    @State private var isRemoteConnected: Bool = false       // 自定義遙控器 是否開始設定
    @State private var isShowingNewDeviceView: Bool = false  // 是否要開始藍芽配對介面，默認：關閉
    @State private var selectedTab: String = "cool"          // 設備控制選項，默認冷氣
    @State private var fanSpeed: String = "auto"
    @State private var fanMode: [String] =  ["auto", "low", "medium", "high", "strong", "max"] // ["auto", "low", "medium", "high", "strong", "max"]
    @State private var temperature: Int = 0
    @State private var minTemp: Int = 16
    @State private var maxTemp: Int = 30
    
    // 首次進入畫面不觸法 onchange
    @State private var isPower = false // 開關
    @State private var isMode = false // 模式
    @State private var isFans = false // 風速
    @State private var isTemperature = false // 溫度
    
    // 控制提示
    @EnvironmentObject var appStore: AppStore  // 使用全域狀態
    
    let titleWidth = 8.0;
    let titleHeight = 20.0;
    
    // MARK: 取得 MQTT 家電數據，更新 UI
    private func updateRemoteControlData() {
        guard let remoteData = MQTTManagerMiddle.shared.appliances["remote"] else { return }
        
        // 解析 `cfg_power` -> String (開 / 關)
        if let power = remoteData["cfg_power"]?.value {
            isPowerOn = power == "on" ? true : false
        }
        
        // 解析 `cfg_mode` -> String
        // ("auto" -> 自動, "cool" -> 冷氣, "heat" -> 暖風, "dry" -> 除濕, "fan"-> 送風)
        if let mode = remoteData["cfg_mode"]?.value {
            selectedTab = mode
        }
        
        // 解析 `cfg_humidity` -> Int
        if let tempString = remoteData["cfg_temperature"]?.value, let tempInt = Int(tempString) {
            temperature = tempInt
        }
        
        // 解析 `op_water_full_alarm` -> String ("0" -> "正常", "1" -> "滿水")
        if let fanLevel = remoteData["cfg_fan_level"]?.value {
            fanSpeed = fanLevel
        }
    }
    
    // MARK: - POST API
    private func postSettingRemoteControl(mode: [String: Any]) {
        let paylod: [String: Any] = [
            "remote": mode
        ]
        //        mqttManager.publishSetDeviceControl(model: paylod)
        MQTTManagerMiddle.shared.setDeviceControl(model: paylod)
    }
    
    var body: some View {
        ZStack {
            VStack {
                if (isConnected) {
                    // ✅ 設備連結完成
                    VStack(alignment: .leading, spacing: 20) {
                        // 自定義遙控器名稱
                        RemoteHeader(
                            hasControl: $hasControl,
                            editRemoteName: $editRemoteName,
                            isRemoteConnected: $isRemoteConnected,
                            isPowerOn: $isPowerOn // 開關
                        )
                        // 🔥 監聽 isPowerOn 的變化
                        .onChange(of: isPowerOn) { newVal in
                            if isPower {
//                                print("開關設定: \(newVal)")
                                let paylodModel: [String: Any] = ["cfg_power": newVal ? "on" : "off"]
                                postSettingRemoteControl(mode: paylodModel)
                            } else {
                                isPower = true
                            }
                            
                        }
                        // ✅ 設備已連線
                        if (hasControl) {
                            // 模式
                            VStack(alignment: .leading, spacing: 9) {
                                HStack {
                                    // tag
                                    RoundedRectangle(cornerRadius: 4)
                                        .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                                    Text("模式")
                                }
                                RemoteControlTag(selectedTab: $selectedTab)
                                // 🔥 監聽 selectedTab 的變化
                                    .onChange(of: selectedTab) { newVal in
                                        if (isMode) {
//                                            print("模式設定: \(newVal)")
                                            let paylodModel: [String: Any] = ["cfg_mode": newVal]
                                            postSettingRemoteControl(mode: paylodModel)
                                        } else {
                                            isMode = true
                                        }
                                    }
                            }
                            
                            // 電源開啟狀態
                            if (true) {
                                /// 風量
                                VStack(alignment: .leading, spacing: 9) {
                                    HStack {
                                        // tag
                                        RoundedRectangle(cornerRadius: 4)
                                            .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                                        Text("風速")
                                    }
                                    //                                    FanSpeedSlider(fanSpeed: $fanSpeed) /// 風量控制
                                    WindSpeedView(selectedSpeed: $fanSpeed, fanMode: $fanMode) // 風速控制
                                    // 🔥 監聽 fanSpeed 的變化
                                        .onChange(of: fanSpeed) {newVal in
                                            if isFans {
//                                                print("風速設定: \(newVal)")
                                                let paylodModel: [String: Any] = ["cfg_fan_level": newVal]
                                                postSettingRemoteControl(mode: paylodModel)
                                            } else {
                                                isFans = true
                                            }
                                        }
                                }
                                
                                /// 溫度
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        // tag
                                        RoundedRectangle(cornerRadius: 4)
                                            .frame(width: titleWidth, height: titleHeight) // 控制長方形的高度，寬度根據內容自動調整
                                        Text("溫度")
                                    }
                                    GradientProgress(
                                        currentTemperature: $temperature, // now temp
                                        minTemperature: $minTemp, // min temp
                                        maxTemperature: $maxTemp  // max temp
                                    ) // 溫度控制視圖
                                    //🔥 監聽 temperature 的變化
                                    .onChange(of: temperature) { newVal in
                                        if isTemperature {
//                                            print("溫度設定: \(newVal)")
                                            let paylodModel: [String: Any] = ["cfg_temperature": String(newVal)]
                                            postSettingRemoteControl(mode: paylodModel)
                                        } else {
                                            isTemperature = true
                                        }
                                    }
                                }
                            } else {
                                /// 請開始電源（電源未開啟）
                                VStack {
                                    Spacer()
                                    Image("open-power")
                                    Text("請先開啟電源")
                                        .font(.body)
                                        .multilineTextAlignment(.center)
                                    Spacer()
                                }
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                            }
                            
                        } else {
                            /// 請先新增遙控器
                            VStack {
                                Spacer()
                                Image("open-power-hint")
                                Text("請先新增遙控器")
                                    .font(.body)
                                    .multilineTextAlignment(.center)
                                Spacer()
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                    }
                    .fullScreenCover(isPresented: $isRemoteConnected) {
                        // 遙控器 自定義 (只有 遙控器 才有此功能)
                        AddCustomRemoteListView(isRemoteConnected: $isRemoteConnected, isRemoteType: $isRemoteType, editRemoteName: $editRemoteName)
                            .transition(.move(edge: .trailing))  // 讓畫面從右進來
                            .background(Color.white.opacity(1))
                            .foregroundColor(Color.heavy_gray)
                        
                    }
                } else {
                    /// ✅ 設備已斷線
                    AddDeviceView(isShowingNewDeviceView: $isShowingNewDeviceView, selectedTab: $selectedTab, isConnected: $isConnected)
                }
            }
            // AI決策啟動 視窗
            //            .fullScreenCover(isPresented: $showPopup) {
            //                CustomPopupView(isPresented: $showPopup)
            //            }
            // 👉 這裡放自訂彈窗，只在 showPopup == true 時顯示
        }
        .onAppear {
            updateRemoteControlData() // 畫面載入時初始化數據
        }
        .onChange(of: MQTTManagerMiddle.shared.appliances["remote"]) { _ in
            updateRemoteControlData()
        }
    }
}

//#Preview {
//    RemoteControl(isConnected: .constant(false))
//}
