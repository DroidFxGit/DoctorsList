//
//  DoctorsListViewModelTests.swift
//  DoctorsListTests
//
//  Created by Carlos Vazquez on 15/03/26.
//

import XCTest
@testable import DoctorsList

@MainActor
final class DoctorsListViewModelTests: XCTestCase {
    
    var sut: DoctorsListViewModel!
    var mockDoctorService: MockDoctorService!
    
    override func setUp() {
        super.setUp()
        mockDoctorService = MockDoctorService()
        sut = DoctorsListViewModel(doctorService: mockDoctorService)
    }
    
    override func tearDown() {
        sut = nil
        mockDoctorService = nil
        super.tearDown()
    }
    
    // MARK: - testLoadingDoctorsSuccess
    
    func testLoadingDoctorsSuccess() async {
        let expectedDoctors = Doctor.mockDoctors
        mockDoctorService.mockDoctors = expectedDoctors
        mockDoctorService.shouldThrowError = false
        
        XCTAssertFalse(sut.isLoading, "Should not be loading initially")
        XCTAssertTrue(sut.doctors.isEmpty, "Doctors array should be empty initially")
        XCTAssertNil(sut.error, "Error should be nil initially")
        XCTAssertFalse(sut.hasError, "hasError should be false initially")
        
        await sut.loadDoctors()
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after successful load")
        XCTAssertEqual(sut.doctors.count, expectedDoctors.count, "Should have loaded all doctors")
        XCTAssertEqual(sut.doctors, expectedDoctors, "Doctors should match expected data")
        XCTAssertNil(sut.error, "Error should be nil after successful load")
        XCTAssertFalse(sut.hasError, "hasError should be false after successful load")
        XCTAssertFalse(sut.isEmpty, "isEmpty should be false when doctors are loaded")
        XCTAssertEqual(mockDoctorService.fetchDoctorsCallCount, 1, "fetchDoctors should be called once")
    }
    
    func testLoadingDoctorsSuccess_VerifyStateTransitions() async {
        let expectedDoctors = Doctor.mockDoctors
        mockDoctorService.mockDoctors = expectedDoctors
        mockDoctorService.shouldThrowError = false
        
        var loadingStates: [Bool] = []
        var doctorCounts: [Int] = []
        var errorStates: [NetworkError?] = []
        
        loadingStates.append(sut.isLoading)
        doctorCounts.append(sut.doctors.count)
        errorStates.append(sut.error)
        
        let expectation = XCTestExpectation(description: "Load doctors completes")
        
        Task {
            await sut.loadDoctors()
            
            loadingStates.append(sut.isLoading)
            doctorCounts.append(sut.doctors.count)
            errorStates.append(sut.error)
            
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(loadingStates, [false, false], "Loading state transitions should be correct")
        XCTAssertEqual(doctorCounts, [0, 3], "Doctor count should transition from 0 to 3")
        XCTAssertTrue(errorStates.allSatisfy { $0 == nil }, "Error should remain nil throughout")
    }
    
    // MARK: - testEmptyDoctorsResponse
    
    func testEmptyDoctorsResponse() async {
        mockDoctorService.mockDoctors = []
        mockDoctorService.shouldThrowError = false
        
        XCTAssertFalse(sut.isLoading, "Should not be loading initially")
        XCTAssertTrue(sut.doctors.isEmpty, "Doctors array should be empty initially")
        
        await sut.loadDoctors()
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after load completes")
        XCTAssertTrue(sut.doctors.isEmpty, "Doctors array should remain empty")
        XCTAssertNil(sut.error, "Error should be nil for empty response")
        XCTAssertFalse(sut.hasError, "hasError should be false for empty response")
        XCTAssertTrue(sut.isEmpty, "isEmpty should be true when no doctors and no error")
        XCTAssertEqual(mockDoctorService.fetchDoctorsCallCount, 1, "fetchDoctors should be called once")
    }
    
    func testEmptyDoctorsResponse_StateTransitions() async {
        mockDoctorService.mockDoctors = []
        mockDoctorService.shouldThrowError = false
        
        var isEmptyStates: [Bool] = []
        var loadingStates: [Bool] = []
        
        isEmptyStates.append(sut.isEmpty)
        loadingStates.append(sut.isLoading)
        
        await sut.loadDoctors()
        
        isEmptyStates.append(sut.isEmpty)
        loadingStates.append(sut.isLoading)
        
        XCTAssertEqual(isEmptyStates, [true, true], "isEmpty should remain true for empty response")
        XCTAssertEqual(loadingStates, [false, false], "Loading should start and end as false")
        XCTAssertTrue(sut.doctors.isEmpty, "Doctors should be empty")
        XCTAssertNil(sut.error, "Error should be nil")
    }
    
    // MARK: - testNetworkErrorHandling
    
    func testNetworkErrorHandling_InvalidURL() async {
        mockDoctorService.mockError = .invalidURL
        mockDoctorService.shouldThrowError = true
        
        XCTAssertNil(sut.error, "Error should be nil initially")
        XCTAssertFalse(sut.hasError, "hasError should be false initially")
        
        await sut.loadDoctors()
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after error")
        XCTAssertTrue(sut.doctors.isEmpty, "Doctors should be empty on error")
        XCTAssertNotNil(sut.error, "Error should not be nil after network error")
        XCTAssertTrue(sut.hasError, "hasError should be true after error")
        XCTAssertFalse(sut.isEmpty, "isEmpty should be false when there's an error")
        
        if case .invalidURL = sut.error {
            XCTAssertTrue(true, "Error type should be invalidURL")
        } else {
            XCTFail("Expected invalidURL error")
        }
        
        XCTAssertEqual(mockDoctorService.fetchDoctorsCallCount, 1, "fetchDoctors should be called once")
    }
    
    func testNetworkErrorHandling_InvalidResponse() async {
        mockDoctorService.mockError = .invalidResponse
        mockDoctorService.shouldThrowError = true
        
        await sut.loadDoctors()
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after error")
        XCTAssertTrue(sut.doctors.isEmpty, "Doctors should be empty on error")
        XCTAssertNotNil(sut.error, "Error should not be nil")
        XCTAssertTrue(sut.hasError, "hasError should be true")
        
        if case .invalidResponse = sut.error {
            XCTAssertTrue(true, "Error type should be invalidResponse")
        } else {
            XCTFail("Expected invalidResponse error")
        }
    }
    
    func testNetworkErrorHandling_DecodingError() async {
        let decodingError = NSError(domain: "DecodingError", code: 1, userInfo: nil)
        mockDoctorService.mockError = .decodingError(decodingError)
        mockDoctorService.shouldThrowError = true
        
        await sut.loadDoctors()
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after error")
        XCTAssertTrue(sut.doctors.isEmpty, "Doctors should be empty on error")
        XCTAssertNotNil(sut.error, "Error should not be nil")
        XCTAssertTrue(sut.hasError, "hasError should be true")
        
        if case .decodingError = sut.error {
            XCTAssertTrue(true, "Error type should be decodingError")
        } else {
            XCTFail("Expected decodingError")
        }
    }
    
    func testNetworkErrorHandling_NetworkError() async {
        let networkError = NSError(domain: "NetworkError", code: -1009, userInfo: nil)
        mockDoctorService.mockError = .networkError(networkError)
        mockDoctorService.shouldThrowError = true
        
        await sut.loadDoctors()
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after error")
        XCTAssertTrue(sut.doctors.isEmpty, "Doctors should be empty on error")
        XCTAssertNotNil(sut.error, "Error should not be nil")
        XCTAssertTrue(sut.hasError, "hasError should be true")
        
        if case .networkError = sut.error {
            XCTAssertTrue(true, "Error type should be networkError")
        } else {
            XCTFail("Expected networkError")
        }
    }
    
    func testNetworkErrorHandling_UnknownError() async {
        mockDoctorService.mockError = .unknown
        mockDoctorService.shouldThrowError = true
        
        await sut.loadDoctors()
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after error")
        XCTAssertTrue(sut.doctors.isEmpty, "Doctors should be empty on error")
        XCTAssertNotNil(sut.error, "Error should not be nil")
        XCTAssertTrue(sut.hasError, "hasError should be true")
        
        if case .unknown = sut.error {
            XCTAssertTrue(true, "Error type should be unknown")
        } else {
            XCTFail("Expected unknown error")
        }
    }
    
    func testNetworkErrorHandling_StateTransitions() async {
        mockDoctorService.mockError = .invalidResponse
        mockDoctorService.shouldThrowError = true
        
        var errorStates: [Bool] = []
        var loadingStates: [Bool] = []
        var hasErrorStates: [Bool] = []
        
        errorStates.append(sut.error != nil)
        loadingStates.append(sut.isLoading)
        hasErrorStates.append(sut.hasError)
        
        await sut.loadDoctors()
        
        errorStates.append(sut.error != nil)
        loadingStates.append(sut.isLoading)
        hasErrorStates.append(sut.hasError)
        
        XCTAssertEqual(errorStates, [false, true], "Error state should transition to true")
        XCTAssertEqual(loadingStates, [false, false], "Loading should be false before and after")
        XCTAssertEqual(hasErrorStates, [false, true], "hasError should transition to true")
    }
    
    // MARK: - Additional Tests
    
    func testRetry() async {
        mockDoctorService.mockError = .invalidResponse
        mockDoctorService.shouldThrowError = true
        
        await sut.loadDoctors()
        
        XCTAssertTrue(sut.hasError, "Should have error after first load")
        XCTAssertEqual(mockDoctorService.fetchDoctorsCallCount, 1, "Should have called once")
        
        mockDoctorService.shouldThrowError = false
        mockDoctorService.mockDoctors = Doctor.mockDoctors
        
        await sut.retry()
        
        XCTAssertFalse(sut.hasError, "Should not have error after retry")
        XCTAssertFalse(sut.doctors.isEmpty, "Should have doctors after retry")
        XCTAssertEqual(mockDoctorService.fetchDoctorsCallCount, 2, "Should have called twice")
    }
    
    func testErrorClearedOnSubsequentLoad() async {
        mockDoctorService.mockError = .invalidResponse
        mockDoctorService.shouldThrowError = true
        
        await sut.loadDoctors()
        
        XCTAssertTrue(sut.hasError, "Should have error after first load")
        
        mockDoctorService.shouldThrowError = false
        mockDoctorService.mockDoctors = Doctor.mockDoctors
        
        await sut.loadDoctors()
        
        XCTAssertFalse(sut.hasError, "Error should be cleared on subsequent successful load")
        XCTAssertNil(sut.error, "Error should be nil after successful load")
        XCTAssertFalse(sut.doctors.isEmpty, "Should have doctors after successful load")
    }
    
    func testIsEmptyComputedProperty() async {
        XCTAssertTrue(sut.isEmpty, "isEmpty should be true initially (no doctors, no loading, no error)")
        
        mockDoctorService.mockDoctors = []
        mockDoctorService.shouldThrowError = false
        
        await sut.loadDoctors()
        
        XCTAssertTrue(sut.isEmpty, "isEmpty should remain true when not loading, no doctors, no error")
        
        mockDoctorService.mockError = .invalidResponse
        mockDoctorService.shouldThrowError = true
        
        await sut.loadDoctors()
        
        XCTAssertFalse(sut.isEmpty, "isEmpty should be false when there's an error")
    }
    
    func testMultipleLoadDoctorsCalls() async {
        mockDoctorService.mockDoctors = [Doctor.mockDoctors[0]]
        
        await sut.loadDoctors()
        XCTAssertEqual(sut.doctors.count, 1, "Should have 1 doctor after first load")
        
        mockDoctorService.mockDoctors = Doctor.mockDoctors
        
        await sut.loadDoctors()
        XCTAssertEqual(sut.doctors.count, 3, "Should have 3 doctors after second load")
        XCTAssertEqual(mockDoctorService.fetchDoctorsCallCount, 2, "Should have called fetchDoctors twice")
    }
    
    // MARK: - Refresh Tests
    
    func testRefreshSuccess() async {
        mockDoctorService.mockDoctors = [Doctor.mockDoctors[0]]
        mockDoctorService.shouldThrowError = false
        
        await sut.loadDoctors()
        XCTAssertEqual(sut.doctors.count, 1, "Should have 1 doctor after initial load")
        XCTAssertFalse(sut.isLoading, "Should not be loading after initial load")
        
        mockDoctorService.mockDoctors = Doctor.mockDoctors
        
        await sut.refresh()
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after refresh completion")
        XCTAssertEqual(sut.doctors.count, 3, "Should have 3 doctors after refresh")
        XCTAssertNil(sut.error, "Error should be nil after successful refresh")
        XCTAssertEqual(mockDoctorService.fetchDoctorsCallCount, 2, "Should have called fetchDoctors twice")
    }
    
    func testRefreshStateTransitions() async {
        mockDoctorService.mockDoctors = Doctor.mockDoctors
        mockDoctorService.shouldThrowError = false
        
        await sut.loadDoctors()
        
        var loadingStates: [Bool] = []
        
        loadingStates.append(sut.isLoading)
        
        // Set delay to 200ms to allow test to observe isLoading=true state.
        // Without this delay, the mock completes instantly before we can capture the loading state.
        mockDoctorService.delay = 200_000_000
        
        let expectation = XCTestExpectation(description: "Refresh completes")
        
        Task {
            let refreshTask = Task {
                await sut.refresh()
            }
            
            try? await Task.sleep(nanoseconds: 100_000_000)
            loadingStates.append(sut.isLoading)
            
            await refreshTask.value
            loadingStates.append(sut.isLoading)
            
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertEqual(loadingStates[0], false, "isLoading should be false initially")
        XCTAssertEqual(loadingStates[1], true, "isLoading should be true during refresh")
        XCTAssertEqual(loadingStates[2], false, "isLoading should be false after refresh")
    }
    
    func testRefreshWithError() async {
        mockDoctorService.mockDoctors = Doctor.mockDoctors
        mockDoctorService.shouldThrowError = false
        
        await sut.loadDoctors()
        XCTAssertEqual(sut.doctors.count, 3, "Should have doctors after initial load")
        XCTAssertNil(sut.error, "Should not have error initially")
        
        mockDoctorService.mockError = .networkError(NSError(domain: "NetworkError", code: -1009, userInfo: nil))
        mockDoctorService.shouldThrowError = true
        
        await sut.refresh()
        
        XCTAssertFalse(sut.isLoading, "Should not be loading after refresh with error")
        XCTAssertNotNil(sut.error, "Should have error after failed refresh")
        XCTAssertEqual(sut.doctors.count, 3, "Doctors should remain from previous successful load")
    }
    
    func testRefreshClearsPreviousError() async {
        mockDoctorService.mockError = .invalidResponse
        mockDoctorService.shouldThrowError = true
        
        await sut.loadDoctors()
        XCTAssertTrue(sut.hasError, "Should have error after failed load")
        
        mockDoctorService.shouldThrowError = false
        mockDoctorService.mockDoctors = Doctor.mockDoctors
        
        await sut.refresh()
        
        XCTAssertFalse(sut.hasError, "Error should be cleared after successful refresh")
        XCTAssertNil(sut.error, "Error should be nil after successful refresh")
        XCTAssertEqual(sut.doctors.count, 3, "Should have doctors after successful refresh")
    }
    
    func testRefreshSetsIsLoadingState() async {
        mockDoctorService.mockDoctors = Doctor.mockDoctors
        mockDoctorService.shouldThrowError = false
        
        await sut.loadDoctors()
        
        XCTAssertFalse(sut.isLoading, "isLoading should be false after initial load")
        
        // Set delay to 200ms to simulate network latency and properly test loading state.
        // This ensures isLoading stays true long enough for the test to observe it.
        mockDoctorService.delay = 200_000_000
        
        let expectation = XCTestExpectation(description: "Refresh completes")
        var isLoadingDuringRefresh = false
        
        Task {
            let refreshTask = Task {
                await sut.refresh()
            }
            
            try? await Task.sleep(nanoseconds: 100_000_000)
            isLoadingDuringRefresh = sut.isLoading
            
            await refreshTask.value
            expectation.fulfill()
        }
        
        await fulfillment(of: [expectation], timeout: 2.0)
        
        XCTAssertTrue(isLoadingDuringRefresh, "isLoading should be true during refresh")
        XCTAssertFalse(sut.isLoading, "isLoading should be false after refresh")
    }
}
