//
//  UnitListViewController.swift
//  Japanese_nursing
//
//  Created by 吉澤優衣 on 2020/07/30.
//  Copyright © 2020 吉澤優衣. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import PKHUD
import RxDataSources

/**
 * 単元一覧画面VC
 */
class UnitListViewController: UIViewController, UIScrollViewDelegate {

    private lazy var viewModel: UnitListViewModel = UnitListViewModel()

    private lazy var dataSource: RxTableViewSectionedReloadDataSource<UnitListSectionDomainModel> = setupDataSource()

    @IBOutlet weak var tableView: UITableView!

    // MARK: - Properties

    private var disposeBag = DisposeBag()

    private lazy var emptyView: EmptyView = {
        let v = R.nib.emptyView.firstView(owner: nil)!
        v.backgroundColor = .clear
        v.retryAction = { [weak self] in
            self?.fetch(authToken: ApplicationConfigData.authToken)
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

        navigationController?.setNavigationBarHidden(true, animated: true)

        self.tableView.dataSource = nil
        self.tableView.delegate = nil
        self.tableView.rowHeight = 98

        // ユーザ未作成の場合はユーザ作成画面に遷移
        if ApplicationConfigData.authToken == "" {
            let vc = CreateUserViewController.makeInstance()
            present(vc, animated: false)
        }

        subscribe()
        fetch(authToken: ApplicationConfigData.authToken)

    }

}


// MARK: - Functions

extension UnitListViewController {

    private func subscribe() {

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

        // データソースと紐付ける
        viewModel.unitsObservable
            .bind(to: tableView.rx.items(dataSource: dataSource))
            .disposed(by: disposeBag)

        // セルタップ
        tableView.rx.itemSelected
            .subscribe(onNext: { [unowned self] indexPath in
                let vc = LearningUnitViewController.makeInstance()
                self.present(vc, animated: true)
            }).disposed(by: disposeBag)
    }


    private func fetch(authToken: String) {
        viewModel.fetch(authToken: authToken)
            .subscribe(
                onError: { [unowned self] in
                    log.error($0.descriptionOfType)
                    self.emptyView.status = .errorAndRetry($0.descriptionOfType)
                }).disposed(by: disposeBag)
    }

}

// MARK: - TableViewDataSource

extension UnitListViewController {

    private func setupDataSource() -> RxTableViewSectionedReloadDataSource<UnitListSectionDomainModel> {
        let dataSource = RxTableViewSectionedReloadDataSource<UnitListSectionDomainModel>(configureCell: { (_, tableView, indexPath, item) in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: R.reuseIdentifier.unitListCell.identifier, for: indexPath) as?
                    UnitListCell else {
                log.error("Can't cast R.reuseIdentifier.unitListCell to UnitLIstCell")
                return UITableViewCell()
            }

            cell.configure(item)

            return cell
        })
        return dataSource
    }

}

// MARK: - MakeInstance

extension UnitListViewController {

    static func makeInstance() -> UIViewController {
        guard let vc = R.storyboard.unitList.unitListViewController() else {
            assertionFailure("Can't make instance 'UnitListViewController'.")
            return UIViewController()
        }
        return vc
    }

}
