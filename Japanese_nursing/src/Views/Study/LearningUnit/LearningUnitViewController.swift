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

/**
 * 学習画面VC
 */
class LearningUnitViewController: UIViewController {

    private lazy var viewModel: LearningUnitViewModel = LearningUnitViewModel()

    // MARK: - Outlets

    /// 閉じるボタン
    @IBOutlet weak var closeButton: UIButton!
    /// 「覚えた」ボタン（チェックマーク）
    @IBOutlet weak var memorizedButton: UIButton!
    /// 「覚えていない」ボタン（バツマーク）
    @IBOutlet weak var notMemorizedButton: UIButton!
    /// 進捗バー
    @IBOutlet weak var progressView: UIProgressView!

    // MARK: - Properties

    private let kolodaView = KolodaView()

    /// カードのサイズ
    private var cardFrame: CGRect {
        let width = (view.bounds.size.width) * 0.85
        let height = (view.bounds.size.height) * 0.5
        return CGRect(x: 0, y: 0, width: width, height: height)
    }

    private var items: [String] = ["りんご", "ごりら", "ラッパ", "パンダ", "だるま"]

    /// カードタップ
    private var cardTappedSubject: PublishSubject<Void> = PublishSubject<Void>()

    /// カードスワイプ中
    private var cardSwipingSubject: PublishSubject<Void> = PublishSubject<Void>()

    private var disposeBag = DisposeBag()

    private var unitMasterId: Int = 0

    private lazy var emptyView: EmptyView = {
        let v = R.nib.emptyView.firstView(owner: nil)!
        v.backgroundColor = .clear
        v.retryAction = { [weak self] in
            self?.fetch()
        }
        v.page = .learn
        v.status = .none
        view.addSubview(v)
        view.allSafePin(subView: v)
        return v
    }()

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
    }

    // MARK: - Functions

    private func subscribe() {
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
                    return .none
                }
            }
            .drive(onNext: {[weak self] in
                self?.emptyView.status = $0
            }).disposed(by: disposeBag)
    }

    private func fetch() {
        viewModel.fetch(authToken: ApplicationConfigData.authToken, unitMasterId: unitMasterId)
            .subscribe(
                onError: { [unowned self] in
                    log.error($0.descriptionOfType)
                    self.emptyView.status = .errorAndRetry($0.descriptionOfType)
                }).disposed(by: disposeBag)
    }

    /// 進捗バーを更新する
    private func updateProgressView(swipedCardIndex: Int) {
        /// カードの最大枚数
        let maxCardCount = Float(items.count)
        /// スワイプされたカードの枚数
        let swipedCardCount = Float(swipedCardIndex + 1)
        /// 進捗
        let progress = Float(swipedCardCount / maxCardCount)

        progressView.setProgress(progress, animated: true)
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
        // TODO: APIが追加されたら、スワイプの方向によって処理を変更する
//        switch direction {
//        case .right:
//        case .left:
//        default:
//            break
//        }
        updateProgressView(swipedCardIndex: index)

        // 最後のカードがスワイプされたらモーダルを表示する
        if index + 1 >= items.count {
            let appearance = SCLAlertView.SCLAppearance(
                kTitleFont: R.font.notoSansCJKjpSubBold(size: 16)!,
                kTextFont: R.font.notoSansCJKjpSubMedium(size: 12)!,
                showCloseButton: false, titleColor: R.color.textDarkGray()!
            )
            let alertView = SCLAlertView(appearance: appearance)
            alertView.addButton("もう一度学習する") { [weak self] in
                // カードをもう一度表示する
                self?.kolodaView.resetCurrentCardIndex()
                // プログレスバーを初期化する
                self?.progressView.setProgress(0, animated: true)
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
        return items.count
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

        // メインラベルを表示する
        let mainLabel = UILabel()
        mainLabel.text = items[index]
        mainLabel.font = R.font.notoSansCJKjpSubBold(size: 40)
        mainLabel.textColor = R.color.textGray()
        mainLabel.sizeToFit()
        mainLabel.center = CGPoint(x: view.bounds.size.width / 2, y: (view.bounds.size.height / 2) - 35)
        view.addSubview(mainLabel)

        // サブラベルを表示する
        let subLabel = UILabel()
        subLabel.text = items[index]
        subLabel.font = R.font.notoSansCJKjpSubMedium(size: 24)
        subLabel.textColor = R.color.textGray()
        subLabel.sizeToFit()
        subLabel.center = CGPoint(x: view.bounds.size.width / 2, y: (view.bounds.size.height / 2) + 35)
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

// MARK: - MakeInstance

extension LearningUnitViewController {

    static func makeInstance() -> UIViewController {
        guard let vc = R.storyboard.learningUnit.learningUnitViewController() else {
            assertionFailure("Can't make instance 'LearningUnitViewController'.")
            return UIViewController()
        }
        return vc
    }

    static func makeInstanceInNavigationController() -> UIViewController {
        return UINavigationController(rootViewController: makeInstance())
    }

}
