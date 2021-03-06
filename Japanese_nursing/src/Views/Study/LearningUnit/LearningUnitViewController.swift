//
//  LearningUnitViewController.swift
//  Japanese_nursing
//
//  Created by 吉澤優衣 on 2020/11/03.
//  Copyright © 2020 吉澤優衣. All rights reserved.
//

import UIKit
import Koloda
import RxSwift
import RxCocoa
import SCLAlertView
import PKHUD

/**
 * 学習画面VC
 */
class LearningUnitViewController: UIViewController, UIAdaptivePresentationControllerDelegate {

    private lazy var viewModel: LearningUnitViewModel = LearningUnitViewModel()

    // MARK: - Outlets

    /// 単元タイトル
    @IBOutlet weak var unitTitleLabel: UILabel!
    /// 設定ボタン
    @IBOutlet weak var settingButton: UIButton!
    /// 閉じるボタン
    @IBOutlet weak var closeButton: UIButton!
    /// 「覚えた」ボタン（チェックマーク）
    @IBOutlet weak var memorizedButton: UIButton!
    /// 「覚えていない」ボタン（バツマーク）
    @IBOutlet weak var notMemorizedButton: UIButton!
    /// 進捗バー
    @IBOutlet weak var progressView: UIProgressView!

    // MARK: - Properties

    // 触感フィードバック
    private let lightFeedBack: UIImpactFeedbackGenerator = {
        let generator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .light)
        generator.prepare()
        return generator
    }()

    private let kolodaView = KolodaView()

    private var unitTitle = ""

    /// カードのサイズ
    private var cardFrame: CGRect {
        let width = (view.bounds.size.width) * 0.85
        let height = (view.bounds.size.height) * 0.5
        return CGRect(x: 0, y: 0, width: width, height: height)
    }

    /// カードタップ
    private var cardTappedSubject: PublishSubject<Void> = PublishSubject<Void>()

    /// カードスワイプ中
    private var cardSwipingSubject: PublishSubject<Void> = PublishSubject<Void>()

    private var disposeBag = DisposeBag()

    private var unitMasterId: Int = 1

    private lazy var emptyView: EmptyView = {
        let v = R.nib.emptyView.firstView(owner: nil)!
        v.backgroundColor = R.color.study()
        v.retryAction = { [weak self] in
            self?.fetch()
        }
        v.page = .learn
        v.status = .none
        view.addSubview(v)
        view.allSafePin(subView: v, top: 45)
        return v
    }()

    enum DisplayCardType: Int {
        case all
        case remember
        case notRemember
    }

    enum SortOrderType: Int {
        case defaultOrder
        case random
    }

    private var displayCardType: DisplayCardType = DisplayCardType(rawValue: ApplicationConfigData.displayCardSetting)!
    private var sortOrderType: SortOrderType = SortOrderType(rawValue: ApplicationConfigData.cardSortOrderType)!

    private var words: [WordMastersDomainModel] = []

    // MARK: - LifeCycles

    override func viewDidLoad() {
        super.viewDidLoad()

        subscribe()
        fetch()

        kolodaView.dataSource = self
        kolodaView.delegate = self

        // 表示サイズや位置を調整して、viewに追加
        kolodaView.frame = cardFrame
        kolodaView.center = CGPoint(x: view.bounds.size.width / 2, y: (view.bounds.size.height / 2) - 50)
        self.view.addSubview(kolodaView)

        unitTitleLabel.text = unitTitle

    }

    // 遷移先の画面が閉じられた時に呼ばれる
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        if ApplicationConfigData.shouldUpdateCards {
            applySetting()
            ApplicationConfigData.shouldUpdateCards = false
        }
    }

    // MARK: - Functions

    private func subscribe() {
        // 設定ボタンタップ
        settingButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.lightFeedBack.impactOccurred()
            let vc = LearningSettingsViewController.makeInstance()
            vc.presentationController?.delegate = self
            self?.present(vc, animated: true)
        }).disposed(by: disposeBag)
        // 閉じるボタンタップ
        closeButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.dismiss(animated: true)
        }).disposed(by: disposeBag)

        // 覚えたボタンタップ
        memorizedButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.kolodaView.swipe(.right)
            self?.cardSwipingSubject.onNext(())
        }).disposed(by: disposeBag)

        // 覚えていないボタンタップ
        notMemorizedButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.kolodaView.swipe(.left)
            self?.cardSwipingSubject.onNext(())
        }).disposed(by: disposeBag)

        // loading
        viewModel.loadingDriver
            .map { isLoading in
                if isLoading {
                    return .loading
                } else {
                    switch self.emptyView.status {
                    case .showPage:
                        return .showPage
                    default:
                        return .none
                    }
                }
            }
            .drive(onNext: {[weak self] in
                self?.emptyView.status = $0
            }).disposed(by: disposeBag)
    }

    /// 表示する単語を取得
    private func fetch() {
        kolodaView.isHidden = true  // EmptyViewの上にかぶるのを防ぐ
        viewModel.fetch(authToken: ApplicationConfigData.authToken, unitMasterId: unitMasterId)
            .subscribe(
                onNext: { [unowned self] _ in
                    applySetting()
                },
                onError: { [unowned self] in
                    log.error($0.descriptionOfType)
                    self.emptyView.status = .errorAndRetry($0.descriptionOfType)
                }).disposed(by: disposeBag)
    }

    /// 進捗バーを更新する
    private func updateProgressView(swipedCardIndex: Int) {
        /// カードの最大枚数
        let maxCardCount = Float(words.count)
        /// スワイプされたカードの枚数
        let swipedCardCount = Float(swipedCardIndex + 1)
        /// 進捗
        let progress = Float(swipedCardCount / maxCardCount)

        progressView.setProgress(progress, animated: true)
    }

    /// 設定によってカードを表示する
    private func applySetting() {
        displayCardType = DisplayCardType(rawValue: ApplicationConfigData.displayCardSetting)!
        sortOrderType = SortOrderType(rawValue: ApplicationConfigData.cardSortOrderType)!

        switch displayCardType {
        case .all:
            words = viewModel.allWords
        case .remember:
            words = viewModel.rememberWords
        case .notRemember:
            words = viewModel.notRememberWords
        }

        switch sortOrderType {
        case .defaultOrder:
            break
        case .random:
            words = words.shuffled()
        }

        if words.isEmpty {
            self.emptyView.status = .showPage
        } else {
            self.emptyView.status = .none
            kolodaView.isHidden = false
        }

        kolodaView.reloadData()
        kolodaView.resetCurrentCardIndex()

        progressView.setProgress(0, animated: true)
    }

}

// MARK: - KolodaViewDelegate

extension LearningUnitViewController: KolodaViewDelegate {

    /// カードがタップされた際に呼ばれるメソッド
    func koloda(_ koloda: KolodaView, didSelectCardAt index: Int) {
        cardTappedSubject.onNext(())
    }

    /// カードのスワイプ中に呼ばれるメソッド
    func koloda(_ koloda: KolodaView, shouldDragCardAt index: Int) -> Bool {
        cardSwipingSubject.onNext(())
        return true
    }

    /// カードがスワイプされたら呼ばれるメソッド
    func koloda(_ koloda: KolodaView, didSwipeCardAt index: Int, in direction: SwipeResultDirection) {
        switch direction {
        case .right:
            ApplicationConfigData.rememberIdsArray.append(String(words[index].id))
        case .left:
            ApplicationConfigData.notRememberIdsArray.append(String(words[index].id))
        default:
            break
        }
        updateProgressView(swipedCardIndex: index)

        // 最後のカードがスワイプされたらモーダルを表示する
        if index + 1 >= words.count {
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: R.font.notoSansCJKjpSubBold(size: 16)!,
                kTextFont: R.font.notoSansCJKjpSubMedium(size: 12)!,
                showCloseButton: false, titleColor: R.color.textDarkGray()!
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("もう一度学習する") { [weak self] in
                self?.applySetting()
            }
            alertView.addButton("終了する") { [weak self] in
                self?.dismiss(animated: true)
            }

            alertView.showTitle("学習が終了しました！",
                                subTitle: "もう一度学習しますか？",
                                timeout: nil,
                                completeText: "",
                                style: .success,
                                colorStyle: 0x88DCB9,
                                colorTextButton: nil,
                                circleIconImage: nil,
                                animationStyle: .bottomToTop)
        }
    }

    func koloda(_ koloda: KolodaView, viewForCardOverlayAt index: Int) -> OverlayView? {
        return R.nib.overlayView(owner: self)
    }

}

// MARK: - KolodaViewDataSource

extension LearningUnitViewController: KolodaViewDataSource {

    /// カードの枚数を返す
    func kolodaNumberOfCards(_ koloda: KolodaView) -> Int {
        return words.count
    }

    /// カードのViewを返す
    func koloda(_ koloda: KolodaView, viewForCardAt index: Int) -> UIView {

        // CardのベースとなるView
        let view = UIView()
        view.frame = cardFrame
        view.layer.backgroundColor = UIColor.white.cgColor
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 1.5)
        view.layer.cornerRadius = 10

        // ラベルのwidth
        let width = view.bounds.size.width - 20

        // ふりがなラベルを表示する
        let furiganaLabel = UILabel()
        furiganaLabel.text = words[index].furigana
        furiganaLabel.font = R.font.notoSansCJKjpSubBold(size: 14)
        furiganaLabel.textColor = R.color.textGray()
        furiganaLabel.bounds.size = CGSize(width: width, height: 20)  // サイズ指定
        furiganaLabel.center = CGPoint(x: view.bounds.size.width / 2, y: (view.bounds.size.height / 2) - 73)  // 位置調整
        furiganaLabel.textAlignment = NSTextAlignment.center  // 中央寄せ
        // minimumFontScale を指定
        furiganaLabel.adjustsFontSizeToFitWidth = true
        furiganaLabel.minimumScaleFactor = 0.3
        view.addSubview(furiganaLabel)

        // メインラベルを表示する
        let mainLabel = UILabel()
        mainLabel.text = words[index].japanese
        mainLabel.font = R.font.notoSansCJKjpSubBold(size: 40)
        mainLabel.textColor = R.color.textGray()
        mainLabel.bounds.size = CGSize(width: width, height: 46)  // サイズ指定
        mainLabel.center = CGPoint(x: view.bounds.size.width / 2, y: (view.bounds.size.height / 2) - 35)  // 位置調整
        mainLabel.textAlignment = NSTextAlignment.center  // 中央寄せ
        // minimumFontScale を指定
        mainLabel.adjustsFontSizeToFitWidth = true
        mainLabel.minimumScaleFactor = 0.3
        view.addSubview(mainLabel)

        // サブラベルを表示する
        let subLabel = UILabel()
        subLabel.text = words[index].vietnamese
        subLabel.font = R.font.notoSansCJKjpSubMedium(size: 24)
        subLabel.textColor = R.color.textGray()

        subLabel.bounds.size = CGSize(width: width, height: 36)  // サイズ指定(「g」などあるため、heightは多めにとる)
        subLabel.center = CGPoint(x: view.bounds.size.width / 2, y: (view.bounds.size.height / 2) + 35)  // 位置調整
        subLabel.textAlignment = NSTextAlignment.center  // 中央寄せ
        // minimumFontScale を指定
        subLabel.adjustsFontSizeToFitWidth = true
        subLabel.minimumScaleFactor = 0.3
        view.addSubview(subLabel)

        // サブラベルは最初は非表示
        subLabel.isHidden = true

        // カードがタップされた場合はサブラベルを表示する
        cardTappedSubject.subscribe(onNext: { _ in
            subLabel.isHidden = false
        }).disposed(by: disposeBag)

        // カードがスワイプされはじめたらサブラベルを非表示にする（次のカードのサブラベルが見えてしまう可能性があるため）
        cardSwipingSubject.subscribe(onNext: { _ in
            subLabel.isHidden = true
        }).disposed(by: disposeBag)

        return view
    }

}

extension LearningUnitViewController {

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else {
            return
        }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }

}

// MARK: - MakeInstance

extension LearningUnitViewController {

    static func makeInstance(unitMasterId: Int, unitTitle: String) -> UIViewController {
        guard let vc = R.storyboard.learningUnit.learningUnitViewController() else {
            assertionFailure("Can't make instance 'LearningUnitViewController'.")
            return UIViewController()
        }
        vc.unitMasterId = unitMasterId
        vc.unitTitle = unitTitle
        return vc
    }

    static func makeInstanceInNavigationController(unitMasterId: Int, unitTitle: String) -> UIViewController {
        return UINavigationController(rootViewController: makeInstance(unitMasterId: unitMasterId, unitTitle: unitTitle))
    }

}
