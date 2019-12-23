//
//  StoryboardHelper.swift
//  AuthenticiOS
//
//  Created by Greg Whatley on 10/27/19.
//  Copyright © 2019 Greg Whatley. All rights reserved.
//

import UIKit

class StoryboardHelper {
    static private let launchScreen = UIStoryboard(name: "LaunchScreen", bundle: Bundle.main)
    static private let main = UIStoryboard(name: "Main", bundle: Bundle.main)
    static private let watch = UIStoryboard(name: "Watch", bundle: Bundle.main)
    static private let events = UIStoryboard(name: "Events", bundle: Bundle.main)
    static private let more = UIStoryboard(name: "More", bundle: Bundle.main)
    static private let wallpapers = UIStoryboard(name: "Wallpapers", bundle: Bundle.main)
    static private let content = UIStoryboard(name: "Content", bundle: Bundle.main)
    
    static private func instantiateViewController(named id: String, from storyboard: UIStoryboard) -> UIViewController {
        return storyboard.instantiateViewController(withIdentifier: id)
    }
    
    static private func instantiateMainViewController(from storyboard: UIStoryboard) -> UIViewController {
        return storyboard.instantiateInitialViewController()!
    }
    
    static public func instantiateLaunchScreen() -> UIViewController {
        return instantiateMainViewController(from: launchScreen)
    }
    
    static public func instantiateWallpaperCollectionViewController() -> ACWallpaperCollectionViewController {
        let vc = instantiateViewController(named: "wallpapersCollectionViewController", from: wallpapers) as! ACWallpaperCollectionViewController
        vc.initialize()
        vc.tabBarItem.title = "WALLPAPERS"
        return vc
    }
    
    static public func instantiateEventCollectionViewController() -> ACEventCollectionViewController {
        let vc = instantiateViewController(named: "evroot", from: events) as! ACEventCollectionViewController
        vc.tabBarItem.title = "EVENTS"
        return vc
    }
    
    static public func instantiateWatchViewController(with appearance: ACAppearance) -> UINavigationController {
        let nav = instantiateViewController(named: "watch", from: watch) as! UINavigationController
        nav.tabBarItem.title = "WATCH"
        (nav.topViewController as! ACWatchViewController).initialize(liveDisabled: !appearance.livestream.enable)
        return nav
    }
    
    static public func instantiateVideosCollectionViewController() -> ACVideosCollectionViewController {
        return instantiateViewController(named: "watchVideos", from: watch) as! ACVideosCollectionViewController
    }
    
    static public func instantiateLivestreamViewController() -> ACLivestreamViewController {
        return instantiateViewController(named: "watchLive", from: watch) as! ACLivestreamViewController
    }
    
    static public func instantiateTabViewController(with tab: ACTab) -> ACTabViewController {
        let vc = instantiateViewController(named: "tab", from: content) as! ACTabViewController
        vc.tab = tab
        vc.tabBarItem.title = tab.title
        return vc
    }
    
    static public func instantiateEventViewController(with event: ACEvent) -> ACEventViewController {
        let vc = instantiateViewController(named: "event", from: events) as! ACEventViewController
        vc.event = event
        return vc
    }
    
    static public func instantiateVideoViewController(with provider: String, id: String) -> ACVideoViewController {
        let vc = instantiateViewController(named: "video", from: watch) as! ACVideoViewController
        vc.provider = provider
        vc.id = id
        return vc
    }
    
    static public func instantiateWallpaperPreviewViewController(with resource: ACImageResource) -> ACWallpaperPreviewViewController {
        let vc = instantiateViewController(named: "wallpaperPreview", from: wallpapers) as! ACWallpaperPreviewViewController
        vc.imageResource = resource
        return vc
    }
    
    static public func instantiateMoreTableViewController(with items: [ACTabBarItem], navigationController: UINavigationController) -> ACMoreTableViewController {
        let vc = instantiateViewController(named: "more", from: more) as! ACMoreTableViewController
        vc.items = items
        vc.nav = navigationController
        vc.tabBarItem.title = "MORE"
        return vc
    }
}
