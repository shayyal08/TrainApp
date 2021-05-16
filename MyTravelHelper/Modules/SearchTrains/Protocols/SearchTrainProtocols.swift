//
//  SearchTrainProtocols.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import UIKit

protocol ViewToPresenterProtocol: class{
    var view: PresenterToViewProtocol? {get set}
    var interactor: PresenterToInteractorProtocol? {get set}
    var router: PresenterToRouterProtocol? {get set}
    func fetchallStations()
    func searchTapped(source:String,destination:String)
    
    func saveFavourites(names:[String])
    func getFavorites() ->[String]
}

protocol PresenterToViewProtocol: class{
    func saveFetchedStations(stations:[Station]?)
    func showInvalidSourceOrDestinationAlert()
    func updateLatestTrainList(trainsList: [StationTrain])
    func showNoTrainsFoundAlert()
    func showNoTrainAvailbilityFromSource()
    func showNoInterNetAvailabilityMessage()
    func showErrorMessage(error:TypeError)
}

protocol PresenterToRouterProtocol: class {
    static func createModule()-> SearchTrainViewController
}

protocol PresenterToInteractorProtocol: class {
    var presenter:InteractorToPresenterProtocol? {get set}
    func fetchallStations()
    func fetchTrainsFromSource(sourceCode:String,destinationCode:String)
    func saveFavourites(names:[String])
    func getFavorites() ->[String]
}

protocol InteractorToPresenterProtocol: class {
    func stationListFetched(list:[Station])
    func fetchedTrainsList(trainsList:[StationTrain]?)
    func showNoTrainAvailbilityFromSource()
    func showNoInterNetAvailabilityMessage()
    func showErrorMessage(error:TypeError)
}

protocol NetworkToInteractorProtocol: class {
    func stationListFetched(list:[Station])
    func fetchedTrainsList(trainsList:[StationTrain]?)
    func showNoTrainAvailbilityFromSource()
    func showNoInterNetAvailabilityMessage()
    func showErrorMessage(error:TypeError)
}
