//
//  TabPageViewController+Bulletins.swift
//  Tabman-Example
//
//  Created by Merrick Sapsford on 21/07/2018.
//  Copyright © 2019 UI At Six. All rights reserved.
//

import UIKit
import BLTNBoard
import Pageboy

extension TabPageViewController {
    
    // MARK: Keys
    
    private struct Keys {
        static let hasShownIntroBulletin = "hasShownIntroBulletin"
    }
    
    // MARK: Managers
    
    func makeIntroBulletinManager() -> BLTNItemManager? {
        let hasShownIntro = UserDefaults.standard.bool(forKey: Keys.hasShownIntroBulletin)
        guard !hasShownIntro else {
            return nil
        }
        
        UserDefaults.standard.set(true, forKey: Keys.hasShownIntroBulletin)
        
        let root = SettingsBulletinDataSource.makeIntroPage()
        
        let tintColor = gradient?.activeColors?.last
        root.appearance = SettingsBulletinDataSource.makePageboyAppearance(tintColor: tintColor)
        
        return BLTNItemManager(rootItem: root)
    }
    
    func makeSettingsBulletinManager() -> BLTNItemManager {
        let root = SettingsBulletinDataSource.makeSettingsPage(for: self,
                                                               barDataSource: self)
        root.delegate = self
        
        let tintColor = gradient?.activeColors?.last
        root.appearance = SettingsBulletinDataSource.makePageboyAppearance(tintColor: tintColor)
        
        return BLTNItemManager(rootItem: root)
    }
}

extension TabPageViewController: SettingsBulletinPageDelegate {
    
    func settingsBulletin(_ bulletin: SettingsBulletinPage, requiresPageInsertionAt index: PageIndex) {
        viewControllers.insert(makeChildViewController(), at: index)
        insertPage(at: index, then: .scrollToUpdate)
    }
    
    func settingsBulletin(_ bulletin: SettingsBulletinPage, requiresPageDeletionAt index: PageIndex) {
        viewControllers.remove(at: index)
        deletePage(at: index, then: .doNothing)
    }
}
