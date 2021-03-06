//
//  StudyTargetSettingViewController.swift
//  Japanese_nursing
//
//  Created by 吉澤優衣 on 2020/11/19.
//  Copyright © 2020 吉澤優衣. All rights reserved.
//

import UIKit
import Charts
import RxCocoa
import RxSwift
import PKHUD
import SCLAlertView

/**
 * 目標の設定画面VC
 */
class TargetSettingViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    private lazy var viewModel: TargetSettingViewModel = TargetSettingViewModel()

    // MARK: - Outlets

    /// トップ背景画像
    @IBOutlet weak var topImageView: UIImageView!
    /// タイトルラベル
    @IBOutlet private weak var titleLabel: UILabel!
    /// 円形進捗バー
    @IBOutlet private weak var pieChartView: PieChartView!
    /// 目標タイプアイコン
    @IBOutlet private weak var targetIconImageView: UIImageView!
    /// 目標タイプラベル
    @IBOutlet private weak var targetTypeLabel: UILabel!
    /// 目標タイプピッカーラベル
    @IBOutlet private weak var targetTypePickerLabel: UILabel!
    /// 目標数ラベル
    @IBOutlet private weak var targetNumberLabel: UILabel!
    /// 目標数ピッカー
    @IBOutlet private weak var pickerView: UIPickerView!
    /// キャンセルボタン
    @IBOutlet private weak var cancelButton: UIButton!
    /// 保存ボタン
    @IBOutlet private weak var saveButton: UIButton!

    // MARK: - Properties

    // 触感フィードバック
    private let notificationFeedBack: UINotificationFeedbackGenerator = {
        let generator: UINotificationFeedbackGenerator = UINotificationFeedbackGenerator()
        generator.prepare()
        return generator
    }()

    private var disposeBag = DisposeBag()

    /// 初期目標値
    var initialTargetCount: Int = 30

    /// ピッカーで選択した目標値
    var selectedTargetNumber: Int = 30

    /// ピッカーで表示するデータリスト
    private var pickerDataList: [Int] {
        var list: [Int] = []
        var num = 0
        while num < 2000 {
            num += 10
            list.append(num)
        }
        return list
    }

    /// 目標タイプ区別用Enum
    enum TargetTypeEnum {
        /// 学習
        case study
        /// テスト
        case test

        /// タイトル
        var title: String {
            get {
                switch self {
                case .study:
                    return "目標学習数の設定"
                case .test:
                    return "目標テスト数の設定"
                }
            }
        }
        /// 目標文字列
        var targetString: String {
            get {
                switch self {
                case .study:
                    return "LEARN"
                case .test:
                    return "TEST"
                }
            }
        }
        /// アイコン
        var icon: UIImage {
            get {
                switch self {
                case .study:
                    return R.image.mypage_study()!
                case .test:
                    return R.image.mypage_test()!
                }
            }
        }

        /// トップ画像
        var topImage: UIImage {
            get {
                switch self {
                case .study:
                    return R.image.round_green()!
                case .test :
                    return R.image.round_blue()!
                }
            }
        }

        /// 円形進捗バーの色
        var pieChartColor: UIColor {
            get {
                switch self {
                case .study:
                    return R.color.studyWeakDark()!
                case .test:
                    return R.color.testWeakDark()!
                }
            }
        }

        /// ボタンの色
        var buttonColor: UIColor {
            get {
                switch self {
                case .study:
                    return R.color.study()!
                case .test:
                    return R.color.test()!
                }
            }
        }
    }

    var targetType: TargetTypeEnum = .study

    // MARK: - LifeCycles
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupPieChartView(pieChartView: pieChartView, type: targetType)
        subscribe()

        // Delegate設定
        pickerView.delegate = self
        pickerView.dataSource = self

        setupUI(type: targetType)
    }

}

// MARK: - Functions

extension TargetSettingViewController {

    private func subscribe() {
        // キャンセルボタンタップ
        cancelButton.rx.tap.subscribe(onNext: { [weak self] in
            if let nc = self?.navigationController {
                nc.popViewController(animated: true)
            } else {
                self?.dismiss(animated: true)
            }
        }).disposed(by: disposeBag)

        // 保存ボタンタップ
        saveButton.rx.tap.subscribe(onNext: { [unowned self] in
            if targetType == .study {
                fetch(targetLearningCount: selectedTargetNumber, targetTestingCount: nil)
            } else {
                fetch(targetLearningCount: nil, targetTestingCount: selectedTargetNumber)
            }
        }).disposed(by: disposeBag)
    }

    /// ピッカーの初期値を設定する
    private func setupInitialPickerView() {
        let index = pickerDataList.firstIndex(of: initialTargetCount) ?? 0
        pickerView.selectRow(index, inComponent: 0, animated: false)
    }

    /// 目標タイプによってUIを設定する
    private func setupUI(type: TargetTypeEnum) {
        setupInitialPickerView()
        targetNumberLabel.text = String(initialTargetCount)
        topImageView.image = type.topImage
        titleLabel.text = type.title
        targetTypeLabel.text = type.targetString
        targetTypePickerLabel.text = type.targetString
        targetIconImageView.image = type.icon
        cancelButton.setTitleColor(type.buttonColor, for: .normal)
        saveButton.backgroundColor = type.buttonColor
    }

    private func fetch(targetLearningCount: Int?, targetTestingCount: Int?) {
        HUD.show(.progress)
        viewModel.fetch(authToken: ApplicationConfigData.authToken, targetLearningCount: targetLearningCount, targetTestingCount: targetTestingCount)
            .subscribe(
                onNext: { [unowned self] in
                    notificationFeedBack.notificationOccurred(.success)
                    HUD.flash(.label("保存しました！"), delay: 0.5) {_ in
                        if let nc = self.navigationController {
                            nc.popViewController(animated: true)
                        } else {
                            self.dismiss(animated: true)
                        }
                    }
                },
                onError: { [weak self] in
                    HUD.hide()

                    // エラーアラートを表示
                    let appearance = SCLAlertView.SCLAppearance(
                        kTitleFont: R.font.notoSansCJKjpSubBold(size: 16)!,
                        kTextFont: R.font.notoSansCJKjpSubMedium(size: 12)!
                    )
                    let alertView = SCLAlertView(appearance: appearance)
                    alertView.addButton("リトライ") { [weak self] in
                        self?.fetch(targetLearningCount: targetLearningCount, targetTestingCount: targetTestingCount)
                    }

                    alertView.showTitle("Error",
                                        subTitle: $0.descriptionOfType,
                                        timeout: nil,
                                        completeText: "閉じる",
                                        style: .error,
                                        colorStyle: 0x8EB2F5,
                                        colorTextButton: nil,
                                        circleIconImage: nil,
                                        animationStyle: .bottomToTop)

                }).disposed(by: disposeBag)
    }

}

extension TargetSettingViewController {

    // UIPickerViewの列の数
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    // UIPickerViewの行数、リストの数
    func pickerView(_ pickerView: UIPickerView,
                    numberOfRowsInComponent component: Int) -> Int {
        return pickerDataList.count
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

            // 表示するラベルを生成する
            let label = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 50))
            label.textAlignment = .center
            label.text = String(pickerDataList[row])
            label.font = R.font.notoSansCJKjpSubBold(size: 20)!
            label.textColor = R.color.planeTextDark()
            return label
        }

    // UIPickerViewのRowが選択された時の挙動
    func pickerView(_ pickerView: UIPickerView,
                    didSelectRow row: Int,
                    inComponent component: Int) {

        selectedTargetNumber = pickerDataList[row]
        // ラベルに選択された値を反映する
        targetNumberLabel.text = String(selectedTargetNumber)
    }

}

extension TargetSettingViewController {

    /// 円形進捗バーの表示設定 
    private func setupPieChartView(pieChartView: PieChartView, type: TargetTypeEnum) {
        // グラフに表示するデータ
        let dataEntries = [
            PieChartDataEntry(value: Double(100))
        ]

        // データをセットする
        let dataSet = PieChartDataSet(entries: dataEntries)
        dataSet.setColors(type.pieChartColor)  // グラフの色
        dataSet.drawValuesEnabled = false  // グラフ上のデータ値を非表示にする
        pieChartView.data = PieChartData(dataSet: dataSet)

        pieChartView.holeRadiusPercent = 0.88  // 中心の穴の大きさ
        pieChartView.holeColor = UIColor.clear  // 中心の穴の色

        pieChartView.highlightPerTapEnabled = false  // グラフがタップされたときのハイライトを無効化
        pieChartView.chartDescription?.enabled = false  // グラフの説明を非表示
        pieChartView.drawEntryLabelsEnabled = false  // グラフ上のデータラベルを非表示
        pieChartView.legend.enabled = false  // グラフの注釈を非表示
        pieChartView.rotationEnabled = false // グラフが動くのを無効化

        view.addSubview(pieChartView)
    }

}

extension TargetSettingViewController {

    override func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        super.dismiss(animated: flag, completion: completion)
        guard let presentationController = presentationController else {
            return
        }
        presentationController.delegate?.presentationControllerDidDismiss?(presentationController)
    }
    
}

// MARK: - MakeInstance

extension TargetSettingViewController {

    static func makeInstance(targetType: TargetTypeEnum, initialTargetCount: Int) -> UIViewController {
        guard let vc = R.storyboard.targetSettingViewController.targetSettingViewController() else {
            assertionFailure("Can't make instance 'TargetSettingViewController'.")
            return UIViewController()
        }
        vc.targetType = targetType
        vc.initialTargetCount = initialTargetCount
        return vc
    }

    static func makeInstanceInNavigationController(targetType: TargetTypeEnum, initialTargetCount: Int) -> UIViewController {
        let vc = makeInstance(targetType: targetType, initialTargetCount: initialTargetCount)
        return UINavigationController(rootViewController: vc)
    }

}
