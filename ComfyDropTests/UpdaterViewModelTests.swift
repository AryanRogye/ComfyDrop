//
//  UpdaterViewModelTests.swift
//  ComfyDropTests
//
//  Created by Codex on 3/16/26.
//

import Foundation
import Testing
@testable import ComfyDrop

@MainActor
struct UpdaterViewModelTests {

    @Test("Check for updates title reflects active check state")
    func checkForUpdatesTitleReflectsState() {
        let vm = UpdaterViewModel()

        #expect(vm.checkForUpdatesTitle == "Check for Updates")

        vm.showUserInitiatedUpdate = true

        #expect(vm.checkForUpdatesTitle == "Checking for Updates")
    }

    @Test("Download progress accumulates and status text updates")
    func downloadProgressAccumulates() {
        let vm = UpdaterViewModel()

        vm.startedDownload(cancel: {})
        vm.receivedDownloadContentSize(100)
        vm.updateDownloadReceive(length: 25)

        #expect(vm.updateDownloadStarted)
        #expect(vm.downloadCurrentProgress == 25)
        #expect(vm.downloadContentSize == 100)
        #expect(vm.updateStatusLine == "Downloading update 25%")
    }

    @Test("Invalid content size is ignored")
    func invalidContentSizeIsIgnored() {
        let vm = UpdaterViewModel()

        vm.startedDownload(cancel: {})
        vm.receivedDownloadContentSize(0)
        #expect(vm.downloadContentSize == nil)

        vm.receivedDownloadContentSize(UInt64.max)
        #expect(vm.downloadContentSize == nil)
    }

    @Test("Progress beyond expected size expands tracked total")
    func progressBeyondExpectedSizeExpandsTotal() {
        let vm = UpdaterViewModel()

        vm.startedDownload(cancel: {})
        vm.receivedDownloadContentSize(100)
        vm.updateDownloadReceive(length: 125)

        #expect(vm.downloadCurrentProgress == 125)
        #expect(vm.downloadContentSize == 125)
        #expect(vm.updateStatusLine == "Downloading update 100%")
    }

    @Test("Extraction clears download state and reports preparation progress")
    func extractionClearsDownloadState() {
        let vm = UpdaterViewModel()

        vm.startedDownload(cancel: {})
        vm.receivedDownloadContentSize(100)
        vm.updateDownloadReceive(length: 40)
        vm.startedExtraction()
        vm.updateExtraction(progress: 0.6)

        #expect(vm.updateDownloadStarted == false)
        #expect(vm.downloadContentSize == nil)
        #expect(vm.downloadCurrentProgress == nil)
        #expect(vm.updateExtractionStarted)
        #expect(vm.currentExtraction == 0.6)
        #expect(vm.updateStatusLine == "Preparing update 60%")
    }

    @Test("Installing state reports installation status")
    func installingStateReportsStatus() {
        let vm = UpdaterViewModel()

        vm.startedInstalling()

        #expect(vm.installing)
        #expect(vm.updateStatusLine == "Installing update...")
    }
}

@MainActor
struct UpdateUserDriverTests {

    @Test("Not found error shows acknowledgement state and calls acknowledgement")
    func notFoundErrorShowsAcknowledgementState() {
        let vm = UpdaterViewModel()
        let driver = UpdateUserDriver(vm: vm)
        var acknowledgementCalled = false

        driver.showUserInitiatedUpdateCheck(cancellation: {})
        driver.showUpdateNotFoundWithError(
            TestUpdateError.notFound,
            acknowledgement: { acknowledgementCalled = true }
        )

        #expect(acknowledgementCalled)
        #expect(vm.showUserInitiatedUpdate == false)
        #expect(vm.showUpdateNotFoundError)
        #expect(vm.updateNotFoundError == TestUpdateError.notFound.localizedDescription)
        #expect(vm.phase == .noUpdate(message: TestUpdateError.notFound.localizedDescription))
    }

    @Test("Updater error clears progress but preserves visible error state")
    func updaterErrorClearsProgressButPreservesError() {
        let vm = UpdaterViewModel()
        let driver = UpdateUserDriver(vm: vm)
        var acknowledgementCalled = false

        vm.startedDownload(cancel: {})
        vm.receivedDownloadContentSize(100)
        vm.updateDownloadReceive(length: 50)

        driver.showUpdaterError(
            TestUpdateError.networkFailure,
            acknowledgement: { acknowledgementCalled = true }
        )

        #expect(acknowledgementCalled)
        #expect(vm.updateDownloadStarted == false)
        #expect(vm.downloadContentSize == nil)
        #expect(vm.downloadCurrentProgress == nil)
        #expect(vm.showUpdateError)
        #expect(vm.updateErrorMessage == TestUpdateError.networkFailure.localizedDescription)
        #expect(vm.phase == .error(message: TestUpdateError.networkFailure.localizedDescription))
    }

    @Test("Dismissing installation preserves no update message")
    func dismissingInstallationPreservesNoUpdateMessage() {
        let vm = UpdaterViewModel()
        let driver = UpdateUserDriver(vm: vm)

        vm.showUpdateNotFoundError = true
        vm.updateNotFoundError = "No updates available"
        vm.startedDownload(cancel: {})

        driver.dismissUpdateInstallation()

        #expect(vm.showUpdateNotFoundError)
        #expect(vm.updateNotFoundError == "No updates available")
        #expect(vm.phase == .noUpdate(message: "No updates available"))
    }
}

private enum TestUpdateError: LocalizedError {
    case notFound
    case networkFailure

    var errorDescription: String? {
        switch self {
        case .notFound:
            return "No update found"
        case .networkFailure:
            return "The update server could not be reached"
        }
    }
}
