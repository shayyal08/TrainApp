//
//  SearchTrainInteractor.swift
//  MyTravelHelper
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import Foundation
import XMLParsing

class SearchTrainInteractor: PresenterToInteractorProtocol {
        
    //var _sourceStationCode = String()
    //var _destinationStationCode = String() //shilpa commented
    var presenter: InteractorToPresenterProtocol?
    let networkHandler = NetworkHandler()

    func fetchallStations() {
        if Reach().isNetworkReachable(){
            networkHandler.fetchAllStations() { (result) in
                switch(result) {
                    case .success(let station):
                        self.presenter!.stationListFetched(list: station.stationsList)
                    case .failure(let error):
                    self.presenter!.showErrorMessage(error: error)
                }
                    
            }
        } else {
            self.presenter!.showNoInterNetAvailabilityMessage()
        }
    }

    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
       // _sourceStationCode = sourceCode
        //_destinationStationCode = destinationCode //shilpa commented
        if Reach().isNetworkReachable(){
            networkHandler.fetchTrainsFromSource(sourceCode:sourceCode ,destinationCode:destinationCode, completion:  { (result) in
                switch(result) {
                    case .success(let trainsList):
                        if ( trainsList.count == 0) {
                            self.presenter!.showNoTrainAvailbilityFromSource()
                        } else {
                            self.presenter!.fetchedTrainsList(trainsList: trainsList)
                        }
                case .failure(let error):
                    self.presenter!.showErrorMessage(error: error)
                }
            })
        } else {
            self.presenter!.showNoInterNetAvailabilityMessage()
        }
    }
    
    //shilpa added
    func saveFavourites(names: [String]) {
            let favList = Set(names)
            UserDefaults.standard.set(Array(favList), forKey: USERDEFAULTS_FAV)
    }

    func getFavorites() -> [String] {
        let favoriteLists = UserDefaults.standard.stringArray(forKey: USERDEFAULTS_FAV)
        let favList  = favoriteLists ?? []
        return favList
    }
    
}
