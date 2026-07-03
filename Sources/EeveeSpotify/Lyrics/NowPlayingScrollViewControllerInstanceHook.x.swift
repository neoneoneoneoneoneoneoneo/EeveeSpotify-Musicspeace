import Orion
import UIKit

// 他のフック用変数
var statefulPlayer: StatefulPlayerImplementation?
var backgroundViewModel: SPTNowPlayingBackgroundViewModel?
var scrollDataSource: NowPlayingScrollDataSourceImplementation?
var nowPlayingScrollViewController: NowPlayingScrollViewController?
var npvScrollViewController: NPVScrollViewController?

// 🚀 純正の検索セッションを保持するためのグローバル変数
@objc public class MSPSearchBridge: NSObject {
    @objc public static var sharedSearchSession: AnyObject? = nil
}

// 既存のフック群
class LegacyNowPlayingPlatformSwiftServiceImplementationHook: ClassHook<NSObject> {
    typealias Group = IOS14PremiumPatchingGroup
    static let targetName = "NowPlaying_PlatformImpl.NowPlayingPlatformSwiftServiceImplementation"
    func provideStatefulPlayer() -> StatefulPlayerImplementation {
        statefulPlayer = orig.provideStatefulPlayer()
        return statefulPlayer!
    }
}

class NowPlayingPlatformSwiftServiceImplementationHook: ClassHook<NSObject> {
    typealias Group = NonIOS14PremiumPatchingGroup
    static let targetName = "NowPlaying_PlatformImpl.NowPlayingPlatformSwiftServiceImplementation"
    func provideStatefulPlayerWithFeatureIdentifier(_ identifier: NSString) -> StatefulPlayerImplementation {
        statefulPlayer = orig.provideStatefulPlayerWithFeatureIdentifier(identifier)
        return statefulPlayer!
    }
}

// 🚀 検索の内部サービスをフックして、セッションを横取りする
class SearchServiceHook: ClassHook<NSObject> {
    static let targetName = "Search_SearchServiceImpl.SearchServiceImplementation"
    
    // 検索セッションを提供する純正メソッドをフック
    func provideSearchSession() -> AnyObject {
        let session = orig.provideSearchSession()
        MSPSearchBridge.sharedSearchSession = session // 横取りしてキープ！
        return session
    }
}

class NowPlayingScrollPrivateServiceImplementationHook: ClassHook<NSObject> {
    typealias Group = BaseLyricsGroup
    static let targetName = "NowPlaying_ScrollImpl.NowPlayingScrollPrivateServiceImplementation"
    
    func provideScrollViewControllerWithDependencies(_ dependencies: NSObject) -> UIViewController {
        let scrollViewController = orig.provideScrollViewControllerWithDependencies(dependencies)
        
        if NSStringFromClass(type(of: scrollViewController)) ~= "NowPlayingScrollViewController" {
            nowPlayingScrollViewController = Dynamic.convert(scrollViewController, to: NowPlayingScrollViewController.self)
        } else {
            scrollDataSource = Ivars<NowPlayingScrollDataSourceImplementation>(target).$__lazy_storage_$_scrollDataSource
            npvScrollViewController = Dynamic.convert(scrollViewController, to: NPVScrollViewController.self)
        }
        
        backgroundViewModel = Ivars<SPTNowPlayingBackgroundViewModel>(dependencies).backgroundViewModel
        
        // 🚀 カスタムUIへのすり替え
        DispatchQueue.main.async {
            for subview in scrollViewController.view.subviews {
                subview.isHidden = true
            }
            
            if let customClass = NSClassFromString("MyMainContainerViewController") as? UIViewController.Type {
                let customUI = customClass.init()
                customUI.view.frame = scrollViewController.view.bounds
                customUI.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
                
                scrollViewController.addChild(customUI)
                scrollViewController.view.addSubview(customUI.view)
                customUI.didMove(toParent: scrollViewController)
                
                scrollViewController.view.backgroundColor = .black
            }
        }
        
        return scrollViewController
    }
}
