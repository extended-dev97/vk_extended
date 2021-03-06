//
//  AudioProtocols.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 15.11.2020.
//  Copyright © 2020 ___ORGANIZATIONNAME___. All rights reserved.
//
//  Template generated by Juanpe Catalán @JuanpeCMiOS
//

import Foundation

//MARK: Wireframe -
protocol AudioWireframeProtocol: class {

}
//MARK: Presenter -
protocol AudioPresenterProtocol: class {
    func onStart()
    func onEvent(message: String, isError: Bool)
    func onPresentAudio(audioViewModels: [AudioViewModel])
}

//MARK: Interactor -
protocol AudioInteractorProtocol: class {
  var presenter: AudioPresenterProtocol?  { get set }
    func getAudio()
}

//MARK: View -
protocol AudioViewProtocol: class {
  var presenter: AudioPresenterProtocol?  { get set }
    func event(message: String, isError: Bool)
    func presentAudio(audioViewModels: [AudioViewModel])
}
