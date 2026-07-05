import SwiftUI
import UIKit

struct EeveeSettingsView: View {
    let navigationController: UINavigationController
    // ★テーマカラーを「ネオンパープル」に指定
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
                .listRowBackground(Color(white: 0.1))
            }
            
            // ★パッチ設定（ネオンピンク）
            Button {
                pushSettingsController(
                    with: EeveePatchingSettingsView(),
                    title: "patching".localized
                )
            } label: {
                NavigationSectionView(
                    color: Color(hex: "#FF007F"),
                    title: "patching".localized,
                    imageSystemName: "bolt.heart.fill"
                )
            }
            .listRowBackground(Color(white: 0.1))
            
            // ★歌詞設定（ディープパープル）
            Button {
                pushSettingsController(
                    with: EeveeLyricsSettingsView(),
                    title: "lyrics".localized
                )
            } label: {
                NavigationSectionView(
                    color: .purple,
                    title: "lyrics".localized,
                    imageSystemName: "music.note.list"
                )
            }
            .listRowBackground(Color(white: 0.1))
            
            // ★カスタム設定（ゴールド）
            Button {
                pushSettingsController(
                    with: EeveeUISettingsView(),
                    title: "customization".localized
                )
            } label: {
                NavigationSectionView(
                    color: .yellow,
                    title: "customization".localized,
                    imageSystemName: "wand.and.stars"
                )
            }
            .listRowBackground(Color(white: 0.1))
            
            // ★実験機能（ミントグリーン）
            Button {
                pushSettingsController(
                    with: EeveeExperimentsSettingsView(),
                    title: "experiments".localized
                )
            } label: {
                NavigationSectionView(
                    color: Color(hex: "#00FA9A"),
                    title: "experiments".localized,
                    imageSystemName: "flame.fill"
                )
            }
            .listRowBackground(Color(white: 0.1))
            
            // データ削除
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
                            .foregroundColor(.red)
                    }
                }
            }
            .listRowBackground(Color(white: 0.1))
        }
        .listStyle(GroupedListStyle())
        .background(Color.black)
        
        .animation(.default, value: isClearingData)
        .animation(.default, value: hasShownCommonIssuesTip)
        
        .onAppear {
            WindowHelper.shared.overrideUserInterfaceStyle(.dark)
        }
    }
}
