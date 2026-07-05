import SwiftUI
import UIKit

struct EeveeSettingsView: View {
    let navigationController: UINavigationController
    // ★テーマカラーを「Spotifyの緑」から「あなたオリジナルのネオンパープル」に書き換え！
    static let spotifyAccentColor = Color(hex: "#A020F0") 
    
    @State private var hasShownCommonIssuesTip = UserDefaults.hasShownCommonIssuesTip
    @State private var isClearingData = false
    
    private func pushSettingsController(with view: any View, title: String) {
        let viewController = EeveeSettingsViewController(
            navigationController.view.frame,
            settingsView: AnyView(view),
            navigationTitle: title
        )
        navigationController.pushViewController(viewController, animated: true)
    }
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        UIView.appearance().tintColor = UIColor(EeveeSettingsView.spotifyAccentColor)
        
        // ★UI全体の見た目を完全に漆黒のダークテーマに固定する設定
        UITableView.appearance().backgroundColor = UIColor.black
        UITableViewCell.appearance().backgroundColor = UIColor(white: 0.05, alpha: 1.0)
    }

    var body: some View {
        List {
            EeveeSettingsVersionView()
                .listRowBackground(Color.black)
            
            if !hasShownCommonIssuesTip {
                CommonIssuesTipView(
                    onDismiss: {
                        hasShownCommonIssuesTip = true
                        UserDefaults.hasShownCommonIssuesTip = true
                    }
                )
                .listRowBackground(Color(white: 0.05))
            }
            
            // ★パッチ設定のボタンをネオンピンク（#FF007F）に変更
            Button {
                pushSettingsController(
                    with: EeveePatchingSettingsView(),
                    title: "patching".localized
                )
            } label: {
                NavigationSectionView(
                    color: Color(hex: "#FF007F"),
                    title: "patching".localized,
                    imageSystemName: "bolt.heart.fill" // アイコンも可愛い稲妻ハートに
                )
            }
            .listRowBackground(Color(white: 0.05))
            
            // ★歌詞設定のボタンをディープパープル（.purple）に変更
            Button {
                pushSettingsController(
                    with: EeveeLyricsSettingsView(),
                    title: "lyrics".localized
                )
            } label: {
                NavigationSectionView(
                    color: .purple,
                    title: "lyrics".localized,
                    imageSystemName: "music.note.list" // アイコンを音符リストに
                )
            }
            .listRowBackground(Color(white: 0.05))
            
            // ★カスタム設定のボタンをゴールド（.yellow）に変更
            Button {
                pushSettingsController(
                    with: EeveeUISettingsView(),
                    title: "customization".localized
                )
            } label: {
                NavigationSectionView(
                    color: .yellow,
                    title: "customization".localized,
                    imageSystemName: "wand.and.stars" // アイコンを魔法の杖に
                )
            }
            .listRowBackground(Color(white: 0.05))
            
            // ★実験機能のボタンをミントグリーン（#00FA9A）に変更
            Button {
                pushSettingsController(
                    with: EeveeExperimentsSettingsView(),
                    title: "experiments".localized
                )
            } label: {
                NavigationSectionView(
                    color: Color(hex: "#00FA9A"),
                    title: "experiments".localized,
                    imageSystemName: "flame.fill" // アイコンを炎に
                )
            }
            .listRowBackground(Color(white: 0.05))
            
            // データ削除セクション
            Section(footer: Text("reset_data_description".localized).foregroundColor(.gray)) {
                Button {
                    isClearingData = true
                    
                    DispatchQueue.global(qos: .userInitiated).async {
                        OfflineHelper.resetData(clearCaches: true)
                        
                        DispatchQueue.main.async {
                            exitApplication()
                        }
                    }
                } label: {
                    if isClearingData {
                        ProgressView()
                    }
                    else {
                        Text("reset_data".localized)
                            .foregroundColor(.red) // 警告色は赤に強調
                    }
                }
            }
            .listRowBackground(Color(white: 0.05))
        }
        .listStyle(GroupedListStyle())
        .background(Color.black) // 背景を真っ黒に
        .scrollContentBackground(.hidden) // 背景透過
        
        .animation(.default, value: isClearingData)
        .animation(.default, value: hasShownCommonIssuesTip)
        
        .onAppear {
            WindowHelper.shared.overrideUserInterfaceStyle(.dark)
        }
    }
}
