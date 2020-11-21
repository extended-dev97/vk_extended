//
//  AudioViewController.swift
//  vkExtended
//
//  Created Ярослав Стрельников on 15.11.2020.
//  Copyright © 2020 ___ORGANIZATIONNAME___. All rights reserved.
//
//  Template generated by Juanpe Catalán @JuanpeCMiOS
//

import UIKit
import Material
import MBProgressHUD
import MaterialComponents
import Material
import DRPLoadingSpinner

class AudioViewController: BaseViewController, AudioViewProtocol {

	var presenter: AudioPresenterProtocol?
    let mainTable = TableView(frame: .zero, style: .plain)
    private lazy var refreshControl = DRPRefreshControl()
    private lazy var searchController = SearchBarController()
    private lazy var footerView = FooterView(frame: CGRect(origin: .zero, size: .custom(screenWidth, 44)))

    private var audioViewModel = [AudioViewModel]()
    
    private var audioService: AudioService?

    deinit {
        removeNotificationsObserver()
    }
    
	override func viewDidLoad() {
        super.viewDidLoad()
        
        AudioRouter.initModule(self)
        footerView.footerTitle = nil
        presenter?.onStart()
        
        title = "Музыка"
        prepareTable()
        setupTable()
        
        let playButton = UIBarButtonItem(image: UIImage(named: "play_48")?.crop(toWidth: 24, toHeight: 24)?.withRenderingMode(.alwaysTemplate).tint(with: .systemBlue), style: .plain, target: self, action: nil)
        let moreButton = UIBarButtonItem(image: UIImage(named: "more_vertical_28")?.withRenderingMode(.alwaysTemplate).tint(with: .systemBlue), style: .plain, target: self, action: nil)
        let shuffleButton = UIBarButtonItem(image: UIImage(named: "shuffle_24")?.withRenderingMode(.alwaysTemplate).tint(with: .systemBlue), style: .plain, target: self, action: nil)
        setNavigationItems(rightNavigationItems: [moreButton, playButton, shuffleButton])
        
        addNotificationObserver(name: .onPlayerStateChanged, selector: #selector(reloaData))
    }

    // Подготовка таблицы
    func prepareTable() {
        view.addSubview(mainTable)
        mainTable.separatorStyle = .none
        mainTable.autoPinEdge(toSuperviewSafeArea: .top, withInset: 56)
        mainTable.autoPinEdge(.bottom, to: .bottom, of: view)
        mainTable.autoPinEdge(.trailing, to: .trailing, of: view)
        mainTable.autoPinEdge(.leading, to: .leading, of: view)
        mainTable.backgroundColor = .adaptableWhite
        mainTable.contentInsetAdjustmentBehavior = .never
        mainTable.contentInset.bottom = 52
    }
    
    // Настройка таблицы
    func setupTable() {
        mainTable.keyboardDismissMode = .onDrag
        mainTable.allowsMultipleSelection = false
        mainTable.allowsMultipleSelectionDuringEditing = true
        mainTable.separatorStyle = .none
        mainTable.delegate = self
        mainTable.dataSource = self
        mainTable.register(UINib(nibName: "AudioTableViewCell", bundle: nil), forCellReuseIdentifier: "AudioTableViewCell")
        refreshControl.add(to: mainTable, target: self, selector: #selector(reloadAudio))
        refreshControl.loadingSpinner.colorSequence = [.adaptableDarkGrayVK]
        refreshControl.loadingSpinner.lineWidth = 2.5
        refreshControl.loadingSpinner.rotationCycleDuration = 0.75
        mainTable.tableFooterView = footerView
        mainTable.tableHeaderView = searchController.searchBar
        setupSearchBar()
    }
    
    // Настройка поисковика
    func setupSearchBar() {
        searchController.searchBar.textField.backgroundColor = .adaptablePostColor
        searchController.searchBar.textField.textColor = .adaptableDarkGrayVK
        searchController.searchBar.textField.font = GoogleSansFont.medium(with: 18)
        searchController.searchBar.textField.setCorners(radius: 12)
        searchController.searchBar.placeholder = "Поиск музыки"
        searchController.searchBar.placeholderColor = .adaptableDarkGrayVK
        searchController.searchBar.placeholderFont = GoogleSansFont.medium(with: 18)
        searchController.searchBar.backgroundColor = .getThemeableColor(from: .white)
        searchController.searchBar.clearButton.setImage(UIImage(named: "clear_16")?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), for: .normal)
        searchController.searchBar.searchButton.setImage(UIImage(named: "search_outline_28")?.crop(toWidth: 22, toHeight: 36)?.withRenderingMode(.alwaysTemplate).tint(with: .adaptableDarkGrayVK), for: .normal)
    }
    
    // Показать музыку
    func presentAudio(audioViewModels: [AudioViewModel]) {
        audioViewModel = audioViewModels
        mainTable.reloadData()
        refreshControl.endRefreshing()
        let audiosCount = audioViewModels.count > 0 ? "\(audioViewModels.count) \(getStringByDeclension(number: audioViewModels.count, arrayWords: Localization.instance.audioCount))" : "Нет музыки"
        footerView.footerTitle = audiosCount
        AudioService.instance.items = audioViewModels.compactMap { AudioItem(highQualitySoundURL: URL(string: $0.url), itemId: $0.id, model: $0) }
    }
    
    // Событие
    func event(message: String, isError: Bool) {
        MBProgressHUD.hide(for: view, animated: false)
        let loadingNotification = MBProgressHUD.showAdded(to: self.view, animated: true)
        loadingNotification.mode = .customView
        loadingNotification.label.font = GoogleSansFont.semibold(with: 14)
        loadingNotification.label.textColor = .adaptableDarkGrayVK
        loadingNotification.label.text = message
        if isError {
            loadingNotification.customView = Self.errorIndicator
            Self.errorIndicator.play()
            loadingNotification.hide(animated: true, afterDelay: 3)
        } else {
            loadingNotification.customView = Self.doneIndicator
            Self.doneIndicator.play()
            loadingNotification.hide(animated: true, afterDelay: 1)
        }
        footerView.footerTitle = message
    }
    
    // При обновлении таблицы
    @objc func reloaData() {
        mainTable.reloadData()
    }
    
    // При обновлении страницы
    @objc func reloadAudio() {
        footerView.footerTitle = nil
        presenter?.onStart()
    }
}
extension AudioViewController: UITableViewDelegate, UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return audioViewModel.count
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "AudioTableViewCell", for: indexPath) as! AudioTableViewCell
        cell.selectionStyle = .none
        cell.setupCell(audioViewModel: audioViewModel[indexPath.row], state: getCellState(at: indexPath))
        return cell
    }
    
    func getCellState(at indexPath: IndexPath) -> AudioCellState {
        if AudioService.instance.player.currentItem?.itemId == audioViewModel[indexPath.row].id {
            switch AudioService.instance.player.state {
            case .buffering:
                return .playing
            case .playing:
                return .playing
            case .paused:
                return .paused
            case .stopped:
                return .notPlaying
            case .waitingForConnection:
                return .notPlaying
            case .failed(_):
                return .notPlaying
            }
        } else {
            return .notPlaying
        }
    }
    
//    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let header = TableHeader(frame: CGRect(origin: .zero, size: .custom(tableView.bounds.width, section == titles.count - 1 ? 1 : 36)))
//        header.headerTitle = titles[section].uppercased()
//        header.dividerVisibility = section == 0 ? .invisible : .visible
//        return header
//    }
//
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return .leastNormalMagnitude
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        if AudioService.instance.player.state == .playing && AudioService.instance.player.currentItem?.itemId == audioViewModel[indexPath.row].id {
            tabBarController?.openPopup(animated: true, completion: nil)
        } else if AudioService.instance.player.state == .paused && AudioService.instance.player.currentItem?.itemId == audioViewModel[indexPath.row].id {
            AudioService.instance.action(.resume)
        } else {
            AudioService.instance.action(.play, index: indexPath.row)
        }
        tableView.reloadRows(at: tableView.indexPathsForVisibleRows ?? [], with: .none)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}
