//
//  SearchTrainPresenterTests.swift
//  MyTravelHelperTests
//
//  Created by Satish on 11/03/19.
//  Copyright © 2019 Sample. All rights reserved.
//

import XCTest
@testable import MyTravelHelper

class SearchTrainPresenterTests: XCTestCase {
    var presenter: SearchTrainPresenter!
    var view:SearchTrainMockView?
    var interactor = SearchTrainInteractorMock()
    var expectation: XCTestExpectation?

    override func setUp() {
      presenter = SearchTrainPresenter()
        view = SearchTrainMockView(testCase: self)
        presenter.view = view
        presenter.interactor = interactor
        interactor.presenter = presenter
    }

    func testfetchallStations() throws {
        
        view?.expectFetchAllStations()

        presenter.fetchallStations()
        waitForExpectations(timeout: 5)

        let result = try XCTUnwrap(view?.stationList)
        
        XCTAssertTrue(result.count > 0)
        XCTAssertTrue(view?.isSaveFetchedStatinsCalled == true)
    }
    
    func testFetchTrainsFromSource() {
        
    }

    override func tearDown() {
        presenter = nil
    }
}


class SearchTrainMockView:PresenterToViewProtocol {
    
    var isSaveFetchedStatinsCalled = false
    var stationList:[Station]?
    private var expectation: XCTestExpectation?
    private let testCase: XCTestCase

    init(testCase: XCTestCase) {
        self.testCase = testCase
    }
    
    func expectFetchAllStations() {
        expectation = testCase.expectation(description: "FetchAllStations")
    }
    
    func saveFetchedStations(stations: [Station]?) {
        if expectation != nil {
            isSaveFetchedStatinsCalled = true
            stationList = stations
        }
        
        expectation?.fulfill()
        expectation = nil
    }

    func showInvalidSourceOrDestinationAlert() {

    }
    
    func updateLatestTrainList(trainsList: [StationTrain]) {

    }
    
    func showNoTrainsFoundAlert() {

    }
    
    func showNoTrainAvailbilityFromSource() {

    }
    
    func showNoInterNetAvailabilityMessage() {
        
    }
    
    func showErrorMessage(error: TypeError) {
        
    }
    
    func showErrorMessage(error: Error) {
        expectation?.fulfill()
        expectation = nil
    }
}

class SearchTrainInteractorMock:PresenterToInteractorProtocol {
   
    var presenter: InteractorToPresenterProtocol?

    func fetchallStations() {
       
        NetworkHandler().fetchAllStations { (result) in
            switch(result) {
                case .success(let station):
                    self.presenter!.stationListFetched(list: station.stationsList)
                case .failure(let error):
                self.presenter!.showErrorMessage(error: error)
            }
        }
    }

    func fetchTrainsFromSource(sourceCode: String, destinationCode: String) {
    }
    
    func saveFavourites(names: [String]) {
    }
    
    func getFavorites() -> [String] {
        return (["Mock"])
    }
    
}

