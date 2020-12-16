//
//  MenuPresenter.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 15.11.2020.
//  Copyright © 2020 ExtendedTeam. All rights reserved.
//
import UIKit

class MenuPresenter: MenuPresenterProtocol {

    weak private var view: MenuViewProtocol?
    var interactor: MenuInteractorProtocol?
    private let router: MenuWireframeProtocol

    init(interface: MenuViewProtocol, interactor: MenuInteractorProtocol?, router: MenuWireframeProtocol) {
        self.view = interface
        self.interactor = interactor
        self.router = router
    }

}
