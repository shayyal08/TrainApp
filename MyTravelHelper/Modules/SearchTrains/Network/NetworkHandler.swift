//
//  NetworkHandler.swift
//  MyTravelHelper
//
//  Created by Shilpa Hayyal on 14/05/21.
//  Copyright © 2021 Sample. All rights reserved.
//

import UIKit
import XMLParsing

enum TypeError:Error {
    case noData
    case networkError
    case noTrainsFound
} //need to add some more error cases

protocol HTTPClient {
    func execute(requestUrl: String, completion: @escaping (Result<Data, Error>) -> Void)
}

class NetworkHandler {
    
    var trainSearchCodes:(source:String,destination:String) = ("" , "")
    var interactor: NetworkToInteractorProtocol?
    
    func fetchAllStations(completion: @escaping(Result<Stations, TypeError>) -> Void) {
        self.execute(requestUrl: ALL_STATIONS_URL, completion: { (result) in
            switch(result) {
            case .success(let data):
                let allStations = self.parser(data: data, of: Stations.self)
                guard let stations = allStations else {completion(.failure(.noData))
                    return }
                completion(.success(stations))
            case .failure( _):
                completion(.failure(.networkError)) //send specific error
            }
    })
    }
    
    func fetchTrainsFromSource(sourceCode: String, destinationCode:String, completion: @escaping(Result<[StationTrain], TypeError>) -> Void) {
        
        let urlString = TRAIN_FROM_SOURCE_URL + sourceCode
        trainSearchCodes = (sourceCode,destinationCode)
        self.execute(requestUrl: urlString, completion: { (result) in
            switch(result) {
            case .success(let data):
                let stationData = self.parser(data: data, of: StationData.self)
                guard let stationsInfo = stationData else {completion(.failure(.noData))
                    return}
                if ( stationsInfo.trainsList.count > 0) {
                self.proceesTrainListforDestinationCheck(trainsList: stationsInfo.trainsList, completion: { (result) in
                    switch(result) {
                    
                    case .success(let trainList):
                        completion(.success(trainList))
                    case .failure(let error):
                        completion(.failure(error))
                    }
                })
                
                } else {
                    completion(.failure(.noData))
                }
            case .failure( _):
                completion(.failure(.networkError))
            }
    })
    }
    

    private func proceesTrainListforDestinationCheck(trainsList: [StationTrain],completion: @escaping(Result<[StationTrain], TypeError>) -> Void)  {
        var _trainsList = trainsList
        let today = Date()
        let group = DispatchGroup()
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let dateString = formatter.string(from: today)
        
        for index  in 0...trainsList.count-1 {
            group.enter()
            let urlString = TRAIN_FROM_DESTINATION_URL + "\(trainsList[index].trainCode)&TrainDate=\(dateString)"
            if Reach().isNetworkReachable() {
                self.execute(requestUrl: urlString,
                completion: {[weak self] (result) in
                    guard let self = self else {return}
                switch(result) {
                case .success(let data):
                    let trainMovements = self.parser(data: data, of: TrainMovementsData.self)
                    if let _movements = trainMovements?.trainMovements {
                        print(self.trainSearchCodes.source, self.trainSearchCodes.destination, _movements)
                        let sourceIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(self.trainSearchCodes.source) == .orderedSame})
                        let destinationIndex = _movements.firstIndex(where: {$0.locationCode.caseInsensitiveCompare(self.trainSearchCodes.destination) == .orderedSame})
                        let desiredStationMoment = _movements.filter{$0.locationCode.caseInsensitiveCompare(self.trainSearchCodes.destination) == .orderedSame}
                        let isDestinationAvailable = desiredStationMoment.count == 1

                        //shilpa: crash is fixed
                        if isDestinationAvailable, let sourceIndex = sourceIndex, let destinationIndex = destinationIndex, sourceIndex < destinationIndex {
                            print("trains found")

                            print(self.trainSearchCodes.source, self.trainSearchCodes.destination)

                            _trainsList[index].destinationDetails = desiredStationMoment.first
                        }
                    }
                case .failure( _):
                    completion(.failure(.networkError))
                    
                }
                    group.leave()
                })
            }
            else {
                completion(.failure(.noTrainsFound))
            }
        }

        group.notify(queue: DispatchQueue.main) {
            let sourceToDestinationTrains = _trainsList.filter{$0.destinationDetails != nil}
                completion(.success(sourceToDestinationTrains))
        }
    }
    
    func parser<T:Decodable>(data:Data, of type:T.Type) ->T? {
        let T =  try? XMLDecoder().decode(T.self, from: data)
        return T
    }
}

extension NetworkHandler:HTTPClient {
    func execute(requestUrl: String, completion: @escaping (Result<Data, Error>) -> Void) {
        
        let request = try URLRequest(url: URL(string: requestUrl)!)
        URLSession.shared.dataTask(with: request) { data, response, error in
                DispatchQueue.main.async {
                    if let data = data {
                        completion(.success(data))
                    } else {
                        completion(.failure(error!))
                    }
                }
            }.resume()
        }
    
}
