//
//  FanSpeedSlider.swift
//  Sttptech_energy
//
//  Created by 莊杰翰 on 2025/1/21.
//

import SwiftUI
struct WindSpeedView: View {
    @Binding var selectedSpeed: String // 🔥 預設選擇 "低"，使用 @Binding 讓 `selectedSpeed` 可與外部變數同步
    
    // 風速選項
    let windSpeeds = ["auto", "low", "medium", "high", "strong", "max"]
    let colors: [Color] = [Color.fan_purple, Color.fan_blue, Color.fan_cyan, Color.fan_teal, Color.fan_yellow, Color.fan_orange]
    @State private var rotationAngle: Double = 0 // 🔥 控制旋轉角度
    @State private var animationSpeed: Double = 2.0 // 🔥 控制旋轉速度
    @State private var isAnimating = false
    
    /// **模式轉換函式**
    private func verifyMode(_ mode: String) -> String {
        switch mode {
        case "auto": return "自動"
        case "low": return "低"
        case "medium": return "中"
        case "high": return "高"
        case "strong": return "強"
        case "max": return "最強"
        default: return "無法辨識模式"
        }
    }
    
    /// 取得對應的 SF Symbols 圖示
    private func getTabIcon(for tab: String) -> String {
        switch tab {
        case "auto": return "fan" // fan.badge.automatic
        case "low": return "fan"
        case "medium": return "fan"
        case "high": return "fan"
        case "strong": return "fan"
        case "max": return "fan"
        default: return ""
        }
    }
    
    /// **根據風速設定不同的動畫速度**
    private func getSpeed(for speed: String) -> Double {
        switch speed {
        case "auto": return 2.2  // 自動：普通速度
        case "low": return 1.8   // 低速：最慢
        case "medium": return 1.5 // 中速
        case "high": return 1.0  // 高速
        case "strong": return 0.7 // 強風
        case "max": return 0.5   // 最強：最快
        default: return 2.0
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            // 風速選項
            HStack(spacing: 4) {
                ForEach(Array(windSpeeds.enumerated()), id: \.element) { index, speed in
                    ZStack {
                        // 葉子圖示 (僅在選中時顯示)
                        if selectedSpeed == speed {
                            Image("leaves") // 確保 "leaves.png" 已加入 Assets
                                .resizable()
                                .frame(width: 40 , height: 40)
                                .offset(x: 05, y: -50) // 調整葉子位置
                                .shadow(color: Color.black.opacity(0.3), radius: 5, x: 2, y: 2) // ✅ 添加陰影
                                .zIndex(1) // 🔥 強制提升 Image 層級
                        }
                        
                        VStack() {
                            // 風速按鈕
                            Text(verifyMode(speed))
                                .font(.system(size: 16, weight: .medium))
                            
                            let isSelected = selectedSpeed == speed
                            
                            Image(systemName: getTabIcon(for: speed))
                                .font(.system(size: 24))
                                .frame(width: 30, height: 30, alignment: .center)
                                .rotationEffect(.degrees(isSelected && isAnimating ? 360 : 0))
                                .animation(
                                    isSelected ? .linear(duration: getSpeed(for: selectedSpeed)).repeatForever(autoreverses: false) : .default,
                                    value: isAnimating
                                )
                                .onAppear {
                                    if isSelected { isAnimating = true }
                                }
                                .onTapGesture {
                                    selectedSpeed = speed
                                    isAnimating = false // 先停止動畫
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.01) {
                                        isAnimating = true // 重新啟動動畫
                                    }
                                }
                            
//                            if selectedSpeed == speed {
//                                Image(systemName: getTabIcon(for: speed))
//                                    .font(.system(size: 24))
//                                    .frame(width: 30, height: 30, alignment: .center)
//                                    .opacity(1.0) // 透明度1
//                                    // iOS8+
//                                //    .symbolEffect(.rotate.clockwise.byLayer, options: .repeat(.continuous))
//                                //    .animation(.easeInOut(duration: getSpeed(for: selectedSpeed)), value: selectedSpeed)
//                                    .rotationEffect(.degrees(isAnimating ? 360 : 0))
//                                    .animation(
//                                        .linear(duration: getSpeed(for: selectedSpeed)).repeatForever(autoreverses: false),
//                                        value: isAnimating
//                                    )
//                                    .onAppear { isAnimating = true }
//                            } else {
//                                Image(systemName: getTabIcon(for: speed))
//                                    .font(.system(size: 24))
//                                    .frame(width: 30, height: 30, alignment: .center)
//                                    .opacity(0.5) // 透明度0.5
//                            }
                            
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: 60, minHeight: 90)
                        .background(colors[index])
                        .cornerRadius(10)
                        .shadow(color: selectedSpeed == speed ? .gray.opacity(0.6) : .clear, radius: 5, x: 0, y: 0)
                        .onTapGesture {
                            withAnimation {
                                selectedSpeed = speed
                                triggerHapticFeedback() // 觸發震動
                            }
                        }
                    }
                }
            }
            .padding(.top, 10)
        }
        //        .padding()
        //        .background(Color(red: 0.9, green: 0.95, blue: 0.94)) // 背景色
    }
}




