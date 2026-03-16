//
//  DoctorDetailViewModelTests.swift
//  DoctorsListTests
//
//  Created by Carlos Vazquez on 15/03/26.
//

import XCTest
@testable import DoctorsList

@MainActor
final class DoctorDetailViewModelTests: XCTestCase {
    
    var sut: DoctorDetailViewModel!
    var mockDoctorService: MockDoctorService!
    var mockLocationService: MockLocationService!
    
    override func setUp() {
        super.setUp()
        mockDoctorService = MockDoctorService()
        mockLocationService = MockLocationService()
    }
    
    override func tearDown() {
        sut = nil
        mockDoctorService = nil
        mockLocationService = nil
        super.tearDown()
    }
    
    // MARK: - Initialization Tests
    
    func testInitWithDoctorId() {
        sut = DoctorDetailViewModel(doctorId: 1, doctorService: mockDoctorService, locationService: mockLocationService)
        
        XCTAssertNil(sut.doctor, "Doctor should be nil when initialized with ID only")
        XCTAssertFalse(sut.isLoading, "Should not be loading initially")
        XCTAssertNil(sut.error, "Error should be nil initially")
        XCTAssertFalse(sut.hasError, "hasError should be false initially")
    }
    
    func testInitWithDoctor() {
        let doctor = Doctor.mockDoctors[0]
        sut = DoctorDetailViewModel(doctor: doctor, doctorService: mockDoctorService, locationService: mockLocationService)
        
        XCTAssertNotNil(sut.doctor, "Doctor should not be nil when initialized with doctor object")
        XCTAssertEqual(sut.doctor, doctor, "Doctor should match the provided doctor")
        XCTAssertFalse(sut.isLoading, "Should not be loading initially")
        XCTAssertNil(sut.error, "Error should be nil initially")
        XCTAssertFalse(sut.hasError, "hasError should be false initially")
    }
    
    // MARK: - Load Doctor Detail Success Tests
    
    func testLoadDoctorDetailSuccess() async {
        let expectedDoctor = Doctor.mockDoctors[0]
        mockDoctorService.mockDoctors = [expectedDoctor]
        mockDoctorService.shouldThrowError = false
        
        sut = DoctorDetailViewModel(doctorId: expectedDoctor.id, doctorService: mockDoctorService, locationService: mockLocationService)
        
        XCTAssertNil(sut.doctor, "Doctor should be nil initially")
        XCTAssertFalse(sut.isLoading, "Should not be loading initially")
        XCTAssertNil(sut.error, "Error should be nil initially")
        
        await sut.loadDoctorDetail()
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after successful load")
        XCTAssertNotNil(sut.doctor, "Doctor should not be nil after successful load")
        XCTAssertEqual(sut.doctor, expectedDoctor, "Doctor should match expected data")
        XCTAssertNil(sut.error, "Error should be nil after successful load")
        XCTAssertFalse(sut.hasError, "hasError should be false after successful load")
        XCTAssertEqual(mockDoctorService.fetchDoctorDetailCallCount, 1, "fetchDoctorDetail should be called once")
    }
    
    func testLoadDoctorDetailSuccess_VerifyStateTransitions() async {
        let expectedDoctor = Doctor.mockDoctors[0]
        mockDoctorService.mockDoctors = [expectedDoctor]
        mockDoctorService.shouldThrowError = false
        
        sut = DoctorDetailViewModel(doctorId: expectedDoctor.id, doctorService: mockDoctorService, locationService: mockLocationService)
        
        var loadingStates: [Bool] = []
        var doctorStates: [Doctor?] = []
        var errorStates: [NetworkError?] = []
        
        loadingStates.append(sut.isLoading)
        doctorStates.append(sut.doctor)
        errorStates.append(sut.error)
        
        let expectation = XCTestExpectation(description: "Load doctor detail completes")
        
        Task {
            await sut.loadDoctorDetail()
            
            loadingStates.append(sut.isLoading)
            doctorStates.append(sut.doctor)
            errorStates.append(sut.error)
            
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(loadingStates, [false, false], "Loading state transitions should be correct")
        XCTAssertNil(doctorStates[0], "Doctor should be nil initially")
        XCTAssertNotNil(doctorStates[1], "Doctor should not be nil after load")
        XCTAssertTrue(errorStates.allSatisfy { $0 == nil }, "Error should remain nil throughout")
    }
    
    func testLoadDoctorDetailSkipsWhenDoctorAlreadyPresent() async {
        let doctor = Doctor.mockDoctors[0]
        sut = DoctorDetailViewModel(doctor: doctor, doctorService: mockDoctorService, locationService: mockLocationService)
        
        XCTAssertNotNil(sut.doctor, "Doctor should be present initially")
        
        await sut.loadDoctorDetail()
        
        XCTAssertEqual(mockDoctorService.fetchDoctorDetailCallCount, 0, "Should not call fetchDoctorDetail when doctor already present")
        XCTAssertEqual(sut.doctor, doctor, "Doctor should remain unchanged")
        XCTAssertFalse(sut.isLoading, "Should not be loading")
        XCTAssertNil(sut.error, "Should not have error")
    }
    
    // MARK: - Error Handling Tests
    
    func testLoadDoctorDetailError_InvalidURL() async {
        mockDoctorService.mockError = .invalidURL
        mockDoctorService.shouldThrowError = true
        
        sut = DoctorDetailViewModel(doctorId: 1, doctorService: mockDoctorService, locationService: mockLocationService)
        
        XCTAssertNil(sut.error, "Error should be nil initially")
        XCTAssertFalse(sut.hasError, "hasError should be false initially")
        
        await sut.loadDoctorDetail()
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after error")
        XCTAssertNil(sut.doctor, "Doctor should be nil on error")
        XCTAssertNotNil(sut.error, "Error should not be nil after network error")
        XCTAssertTrue(sut.hasError, "hasError should be true after error")
        
        if case .invalidURL = sut.error {
            XCTAssertTrue(true, "Error type should be invalidURL")
        } else {
            XCTFail("Expected invalidURL error")
        }
        
        XCTAssertEqual(mockDoctorService.fetchDoctorDetailCallCount, 1, "fetchDoctorDetail should be called once")
    }
    
    func testLoadDoctorDetailError_InvalidResponse() async {
        mockDoctorService.mockError = .invalidResponse
        mockDoctorService.shouldThrowError = true
        
        sut = DoctorDetailViewModel(doctorId: 1, doctorService: mockDoctorService, locationService: mockLocationService)
        
        await sut.loadDoctorDetail()
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after error")
        XCTAssertNil(sut.doctor, "Doctor should be nil on error")
        XCTAssertNotNil(sut.error, "Error should not be nil")
        XCTAssertTrue(sut.hasError, "hasError should be true")
        
        if case .invalidResponse = sut.error {
            XCTAssertTrue(true, "Error type should be invalidResponse")
        } else {
            XCTFail("Expected invalidResponse error")
        }
    }
    
    func testLoadDoctorDetailError_DecodingError() async {
        let decodingError = NSError(domain: "DecodingError", code: 1, userInfo: nil)
        mockDoctorService.mockError = .decodingError(decodingError)
        mockDoctorService.shouldThrowError = true
        
        sut = DoctorDetailViewModel(doctorId: 1, doctorService: mockDoctorService, locationService: mockLocationService)
        
        await sut.loadDoctorDetail()
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after error")
        XCTAssertNil(sut.doctor, "Doctor should be nil on error")
        XCTAssertNotNil(sut.error, "Error should not be nil")
        XCTAssertTrue(sut.hasError, "hasError should be true")
        
        if case .decodingError = sut.error {
            XCTAssertTrue(true, "Error type should be decodingError")
        } else {
            XCTFail("Expected decodingError")
        }
    }
    
    func testLoadDoctorDetailError_NetworkError() async {
        let networkError = NSError(domain: "NetworkError", code: -1009, userInfo: nil)
        mockDoctorService.mockError = .networkError(networkError)
        mockDoctorService.shouldThrowError = true
        
        sut = DoctorDetailViewModel(doctorId: 1, doctorService: mockDoctorService, locationService: mockLocationService)
        
        await sut.loadDoctorDetail()
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after error")
        XCTAssertNil(sut.doctor, "Doctor should be nil on error")
        XCTAssertNotNil(sut.error, "Error should not be nil")
        XCTAssertTrue(sut.hasError, "hasError should be true")
        
        if case .networkError = sut.error {
            XCTAssertTrue(true, "Error type should be networkError")
        } else {
            XCTFail("Expected networkError")
        }
    }
    
    func testLoadDoctorDetailError_UnknownError() async {
        mockDoctorService.mockError = .unknown
        mockDoctorService.shouldThrowError = true
        
        sut = DoctorDetailViewModel(doctorId: 1, doctorService: mockDoctorService, locationService: mockLocationService)
        
        await sut.loadDoctorDetail()
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after error")
        XCTAssertNil(sut.doctor, "Doctor should be nil on error")
        XCTAssertNotNil(sut.error, "Error should not be nil")
        XCTAssertTrue(sut.hasError, "hasError should be true")
        
        if case .unknown = sut.error {
            XCTAssertTrue(true, "Error type should be unknown")
        } else {
            XCTFail("Expected unknown error")
        }
    }
    
    func testLoadDoctorDetailError_StateTransitions() async {
        mockDoctorService.mockError = .invalidResponse
        mockDoctorService.shouldThrowError = true
        
        sut = DoctorDetailViewModel(doctorId: 1, doctorService: mockDoctorService, locationService: mockLocationService)
        
        var errorStates: [Bool] = []
        var loadingStates: [Bool] = []
        var hasErrorStates: [Bool] = []
        
        errorStates.append(sut.error != nil)
        loadingStates.append(sut.isLoading)
        hasErrorStates.append(sut.hasError)
        
        await sut.loadDoctorDetail()
        
        errorStates.append(sut.error != nil)
        loadingStates.append(sut.isLoading)
        hasErrorStates.append(sut.hasError)
        
        XCTAssertEqual(errorStates, [false, true], "Error state should transition to true")
        XCTAssertEqual(loadingStates, [false, false], "Loading should be false before and after")
        XCTAssertEqual(hasErrorStates, [false, true], "hasError should transition to true")
    }
    
    func testLoadDoctorDetailHandlesNonNetworkError() async {
        struct CustomError: Error {}
        mockDoctorService.shouldThrowError = true
        
        sut = DoctorDetailViewModel(doctorId: 1, doctorService: mockDoctorService, locationService: mockLocationService)
        
        await sut.loadDoctorDetail()
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after error")
        XCTAssertNil(sut.doctor, "Doctor should be nil on error")
        XCTAssertNotNil(sut.error, "Error should not be nil")
        
        if case .unknown = sut.error {
            XCTAssertTrue(true, "Non-NetworkError should be converted to .unknown")
        } else {
            XCTFail("Expected unknown error for non-NetworkError exceptions")
        }
    }
    
    // MARK: - Retry Tests
    
    func testRetry() async {
        mockDoctorService.mockError = .invalidResponse
        mockDoctorService.shouldThrowError = true
        
        sut = DoctorDetailViewModel(doctorId: 1, doctorService: mockDoctorService, locationService: mockLocationService)
        
        await sut.loadDoctorDetail()
        
        XCTAssertTrue(sut.hasError, "Should have error after first load")
        XCTAssertEqual(mockDoctorService.fetchDoctorDetailCallCount, 1, "Should have called once")
        
        mockDoctorService.shouldThrowError = false
        mockDoctorService.mockDoctors = Doctor.mockDoctors
        
        await sut.retry()
        
        XCTAssertFalse(sut.hasError, "Should not have error after retry")
        XCTAssertNotNil(sut.doctor, "Should have doctor after retry")
        XCTAssertEqual(mockDoctorService.fetchDoctorDetailCallCount, 2, "Should have called twice")
    }
    
    func testRetryCallsLoadDoctorDetail() async {
        let expectedDoctor = Doctor.mockDoctors[0]
        mockDoctorService.mockDoctors = [expectedDoctor]
        mockDoctorService.shouldThrowError = false
        
        sut = DoctorDetailViewModel(doctorId: expectedDoctor.id, doctorService: mockDoctorService, locationService: mockLocationService)
        
        await sut.retry()
        
        XCTAssertNotNil(sut.doctor, "Should load doctor via retry")
        XCTAssertEqual(sut.doctor, expectedDoctor, "Doctor should match expected data")
        XCTAssertEqual(mockDoctorService.fetchDoctorDetailCallCount, 1, "Should call fetchDoctorDetail through retry")
    }
    
    func testRetrySkipsWhenDoctorAlreadyPresent() async {
        let doctor = Doctor.mockDoctors[0]
        sut = DoctorDetailViewModel(doctor: doctor, doctorService: mockDoctorService, locationService: mockLocationService)
        
        await sut.retry()
        
        XCTAssertEqual(mockDoctorService.fetchDoctorDetailCallCount, 0, "Should not call fetchDoctorDetail when doctor already present")
        XCTAssertEqual(sut.doctor, doctor, "Doctor should remain unchanged")
    }
    
    // MARK: - Error Clearing Tests
    
    func testErrorClearedOnSubsequentLoad() async {
        mockDoctorService.mockError = .invalidResponse
        mockDoctorService.shouldThrowError = true
        
        sut = DoctorDetailViewModel(doctorId: 1, doctorService: mockDoctorService, locationService: mockLocationService)
        
        await sut.loadDoctorDetail()
        
        XCTAssertTrue(sut.hasError, "Should have error after first load")
        
        mockDoctorService.shouldThrowError = false
        mockDoctorService.mockDoctors = Doctor.mockDoctors
        
        await sut.loadDoctorDetail()
        
        XCTAssertFalse(sut.hasError, "Error should be cleared on subsequent successful load")
        XCTAssertNil(sut.error, "Error should be nil after successful load")
        XCTAssertNotNil(sut.doctor, "Should have doctor after successful load")
    }
    
    func testErrorClearedWhenLoadingStarts() async {
        mockDoctorService.mockError = .invalidResponse
        mockDoctorService.shouldThrowError = true
        
        sut = DoctorDetailViewModel(doctorId: 1, doctorService: mockDoctorService, locationService: mockLocationService)
        
        await sut.loadDoctorDetail()
        
        XCTAssertNotNil(sut.error, "Should have error after failed load")
        
        mockDoctorService.shouldThrowError = false
        mockDoctorService.mockDoctors = Doctor.mockDoctors
        mockDoctorService.delay = 200_000_000
        
        let expectation = XCTestExpectation(description: "Load completes")
        var errorDuringLoad: NetworkError?
        
        Task {
            let loadTask = Task {
                await sut.loadDoctorDetail()
            }
            
            try? await Task.sleep(nanoseconds: 100_000_000)
            errorDuringLoad = sut.error
            
            await loadTask.value
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertNil(errorDuringLoad, "Error should be cleared when loading starts")
        XCTAssertNil(sut.error, "Error should remain nil after successful load")
    }
    
    // MARK: - hasError Computed Property Tests
    
    func testHasErrorComputedProperty() async {
        sut = DoctorDetailViewModel(doctorId: 1, doctorService: mockDoctorService, locationService: mockLocationService)
        
        XCTAssertFalse(sut.hasError, "hasError should be false initially")
        
        mockDoctorService.mockError = .invalidResponse
        mockDoctorService.shouldThrowError = true
        
        await sut.loadDoctorDetail()
        
        XCTAssertTrue(sut.hasError, "hasError should be true when error is present")
        XCTAssertNotNil(sut.error, "error should not be nil")
        
        mockDoctorService.shouldThrowError = false
        mockDoctorService.mockDoctors = Doctor.mockDoctors
        
        await sut.loadDoctorDetail()
        
        XCTAssertFalse(sut.hasError, "hasError should be false when error is nil")
        XCTAssertNil(sut.error, "error should be nil after successful load")
    }
    
    // MARK: - Multiple Load Attempts Tests
    
    func testMultipleLoadAttempts_OnlyFirstCallLoads() async {
        let doctor = Doctor.mockDoctors[0]
        mockDoctorService.mockDoctors = [doctor]
        mockDoctorService.shouldThrowError = false
        
        sut = DoctorDetailViewModel(doctorId: doctor.id, doctorService: mockDoctorService, locationService: mockLocationService)
        
        await sut.loadDoctorDetail()
        
        XCTAssertNotNil(sut.doctor, "Doctor should be loaded after first call")
        XCTAssertEqual(mockDoctorService.fetchDoctorDetailCallCount, 1, "Should call fetchDoctorDetail once")
        
        await sut.loadDoctorDetail()
        await sut.loadDoctorDetail()
        
        XCTAssertEqual(mockDoctorService.fetchDoctorDetailCallCount, 1, "Should not call fetchDoctorDetail again when doctor already present")
    }
    
    // MARK: - Loading State Tests
    
    func testLoadingStateTransitions() async {
        let doctor = Doctor.mockDoctors[0]
        mockDoctorService.mockDoctors = [doctor]
        mockDoctorService.shouldThrowError = false
        mockDoctorService.delay = 200_000_000
        
        sut = DoctorDetailViewModel(doctorId: doctor.id, doctorService: mockDoctorService, locationService: mockLocationService)
        
        var loadingStates: [Bool] = []
        
        loadingStates.append(sut.isLoading)
        
        let expectation = XCTestExpectation(description: "Load completes")
        
        Task {
            let loadTask = Task {
                await sut.loadDoctorDetail()
            }
            
            try? await Task.sleep(nanoseconds: 100_000_000)
            loadingStates.append(sut.isLoading)
            
            await loadTask.value
            loadingStates.append(sut.isLoading)
            
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(loadingStates[0], false, "isLoading should be false initially")
        XCTAssertEqual(loadingStates[1], true, "isLoading should be true during load")
        XCTAssertEqual(loadingStates[2], false, "isLoading should be false after load")
    }
    
    func testLoadingStateNotSetWhenDoctorAlreadyPresent() async {
        let doctor = Doctor.mockDoctors[0]
        sut = DoctorDetailViewModel(doctor: doctor, doctorService: mockDoctorService, locationService: mockLocationService)
        
        var loadingStateChanged = false
        
        let expectation = XCTestExpectation(description: "Load completes")
        
        Task {
            let loadTask = Task {
                await sut.loadDoctorDetail()
            }
            
            try? await Task.sleep(nanoseconds: 50_000_000)
            if sut.isLoading {
                loadingStateChanged = true
            }
            
            await loadTask.value
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertFalse(loadingStateChanged, "isLoading should never be true when doctor is already present")
        XCTAssertFalse(sut.isLoading, "isLoading should remain false")
    }
}
