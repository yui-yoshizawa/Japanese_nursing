//
//  UnitListCell.swift
//  Japanese_nursing
//
//  Created by 吉澤優衣 on 2020/11/03.
//  Copyright © 2020 吉澤優衣. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift

class UnitListCell: UITableViewCell {

    // MARK: - Outlets

    /// 単元のタイトル
    @IBOutlet weak var unitTitleLabel: UILabel!
    /// 単元のサブタイトル
    @IBOutlet weak var unitSubTitleLabel: UILabel!
    /// 単語数
    @IBOutlet weak var wordsCountLabel: UILabel!
    /// チェックマーク率
    @IBOutlet weak var checkMarkPercentageLabel: UILabel!
    /// バッジ
    @IBOutlet weak var completeBadge: UIImageView!
    /// セルボタン（セルのタップだとセルが白くなる不具合がなぜか発生するため、応急処置）
    @IBOutlet weak var cellButton: UIButton!

    // MARK: - Properties

    /// セルタップ
    var cellTappedSubject: PublishSubject<Void> = PublishSubject<Void>()

    var disposeBag = DisposeBag()

    // MARK: - LifeCycles

    override func awakeFromNib() {
        super.awakeFromNib()
        subscribe()
        clearConfigure()
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        clearConfigure()
    }

    // MARK: - Functions

    func clearConfigure() {
        unitTitleLabel.text = nil
        wordsCountLabel.text = nil
        checkMarkPercentageLabel.text = nil
        completeBadge.isHidden = true
    }

    func subscribe() {
        // セルタップ
        cellButton.rx.tap.subscribe(onNext: { [weak self] in
            self?.cellTappedSubject.onNext(())
        }).disposed(by: disposeBag)
    }

}

extension UnitListCell {

    /**
     * セルの表示内容を設定
     * - parameters:
     *   - item: 設定に使うDomainModel
     */
    func configure(_ item: UnitListDomainModel) {
        unitTitleLabel.text = item.vietnamese
        unitSubTitleLabel.text = item.japanese
        wordsCountLabel.text = String(item.wordCount) + "words"

        var percentage = 0
        if item.wordCount == 0 {
            // 0で割るとエラーがでるので、念の為
            checkMarkPercentageLabel.text = "0%"
        } else {
            percentage = item.memorizedWordCount * 100 / item.wordCount
            checkMarkPercentageLabel.text = String(percentage) + "%"
        }

        if item.memorizedWordCount == item.wordCount && percentage == 100 {
            completeBadge.isHidden = false
        } else {
            completeBadge.isHidden = true
        }
    }

}
