//
//  SettingListViewController.swift
//  Japanese_nursing
//
//  Created by 吉澤優衣 on 2020/11/13.
//  Copyright © 2020 吉澤優衣. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

/**
 * 設定一覧VC
 */
class SettingListViewController: UIViewController {

    // MARK: - Outlets

    /// 閉じるボタン
    @IBOutlet private weak var closeButton: UIButton!

    /// ニックネームの変更
    @IBOutlet private weak var userNameSettingButton: UIButton!
    /// 目標学習数の変更
    @IBOutlet private weak var studyTargetSettingButton: UIButton!
    /// 目標テスト数の変更
    @IBOutlet private weak var testTargetSettingButton: UIButton!
    /// 利用規約
    @IBOutlet private weak var termOfServiceButton: UIButton!
    /// プライバシーポリシー
    @IBOutlet private weak var privacyPolicyButton: UIButton!

    // MARK: - Properties

    // 触感フィードバック
    private let lightFeedBack: UIImpactFeedbackGenerator = {
        let generator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        return generator
    }()

    private var disposeBag = DisposeBag()

    private var targetLearningCount = 0
    private var targetTestingCount = 0

    // MARK: - LifeCycles

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: true)
        subscribe()
    }

    // MARK: - Functions
    private func subscribe() {
        // 閉じるボタンタップ
        closeButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true)
        }).disposed(by: disposeBag)

        // ニックネームの変更タップ
        userNameSettingButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.lightFeedBack.impactOccurred()
            let vc = UserNameSettingViewController.makeInstance()
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)

        // 目標学習数タップ
        studyTargetSettingButton.rx.tap.subscribe(onNext: { [unowned self] in
            lightFeedBack.impactOccurred()
            let vc = TargetSettingViewController.makeInstance(targetType: .study, initialTargetCount: targetLearningCount)
            navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)

        // 目標テストタップ
        testTargetSettingButton.rx.tap.subscribe(onNext: { [unowned self] in
            lightFeedBack.impactOccurred()
            let vc = TargetSettingViewController.makeInstance(targetType: .test, initialTargetCount: targetTestingCount)
            navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)

        // 利用規約タップ
        termOfServiceButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.lightFeedBack.impactOccurred()
            let url = "https://yuipuccho.github.io/Japanese_nursing_terms_of_service/"
            let vc = WebViewController.makeInstance(url: url, titleText: "利用規約")
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)

        // プライバシーポリシータップ
        privacyPolicyButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.lightFeedBack.impactOccurred()
            let url = "https://yuipuccho.github.io/Japanese_nursing_privacy_policy/"
            let vc = WebViewController.makeInstance(url: url, titleText: "プライバシーポリシー")
            self?.navigationController?.pushViewController(vc, animated: true)
        }).disposed(by: disposeBag)
    }

}

// MARK: - MakeInstance

extension SettingListViewController {

    static func makeInstance(targetLearningCount: Int, targetTestingCount: Int) -> UIViewController {
        guard let vc = R.storyboard.settingListViewController.settingListViewController() else {
            assertionFailure("Can't make instance 'SettingListViewController'.")
            return UIViewController()
        }
        vc.targetLearningCount = targetLearningCount
        vc.targetTestingCount = targetTestingCount
        return vc
    }

    static func makeInstanceInNavigationController(targetLearningCount: Int, targetTestingCount: Int) -> UIViewController {
        return UINavigationController(rootViewController: makeInstance(targetLearningCount: targetLearningCount, targetTestingCount: targetTestingCount))
    }

}
