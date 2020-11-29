//
//  UnitListViewModel.swift
//  Japanese_nursing
//
//  Created by 吉澤優衣 on 2020/11/29.
//  Copyright © 2020 吉澤優衣. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift

/**
 * 単元一覧のViewModel
 */
class UnitListViewModel {

    // MARK: - Properties

    private let loadingRelay: BehaviorRelay<Bool> = BehaviorRelay(value: false)

    private let unitsRelay: BehaviorRelay<[UnitListSectionDomainModel]> = BehaviorRelay(value: [])

    var loadingDriver: Driver<Bool> {
        return loadingRelay.asDriver()
    }

    var unitsObservable: Observable<[UnitListSectionDomainModel]> {
        unitsRelay.asObservable()
    }

    var isLoading: Bool {
        loadingRelay.value
    }

    var units: [UnitListDomainModel] = []

    // MARK: - Functions

    func fetch(authToken: String) -> Observable<[UnitListDomainModel]> {

        return GetUnitMastersModel().getUnitMasters(authToken: authToken)
            .map { units in
                return units.unit_masters.map(UnitListDomainModel.init)
            }
            .do(onNext: { [weak self] in
                guard let _self = self else {
                    return
                }
                _self.units.append(contentsOf: $0)
                let sections = UnitListSectionDomainModel(items: _self.units)
                _self.unitsRelay.accept([sections])
            })
    }

}
