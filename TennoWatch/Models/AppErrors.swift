//
//  AppErrors.swift
//  TennoWatch
//
//  Created by Andrii Bryzhnychenko on 10/24/26.
//

import Foundation
import SwiftData
import UserNotifications

enum APIError: Error {
    case invalidResponse
    case httpStatus(Int)
}

extension PersistentProfileRepository {
    enum ProfileError: Error {
        case noData, noPlayerId
    }
}

extension PersistentCatalogRepository {
    enum CatalogError: Error {
        case wrongFilename, noCatalogAvailable, wrongCategory
    }
}

extension SettingsViewModel {
    enum ClearCacheError: Error {
        case missingBundleIdentifier
    }
}

enum NotificationError: Error {
    case notAllowed
    case authorizationFailed(underlying: Error)
    case schedulingFailed(underlying: Error)
}

struct AppErrors {
    private init() {}

    static func isCancellation(_ error: Error) -> Bool {
        error is CancellationError || (error as? URLError)?.code == .cancelled
    }

    private static func isNotificationPermissionDenied(_ error: Error) -> Bool {
        let systemError = error as NSError
        return systemError.domain == UNErrorDomain && systemError.code == UNError.Code.notificationsNotAllowed.rawValue
    }

    static func message(for error: Error) -> String {
        switch error {
        case APIError.invalidResponse: return Strings.Errors.invalidResponse
        case is DecodingError: return Strings.Errors.decoding
        case PersistentProfileRepository.ProfileError.noData: return Strings.Errors.profileNotFound
        case PersistentProfileRepository.ProfileError.noPlayerId: return Strings.Errors.playerNotFound
        case PersistentCatalogRepository.CatalogError.wrongFilename: return Strings.Errors.catalogFile
        case PersistentCatalogRepository.CatalogError.noCatalogAvailable: return Strings.Errors.catalogUnavailable
        case PersistentCatalogRepository.CatalogError.wrongCategory: return Strings.Errors.catalogCategory
        case SettingsViewModel.ClearCacheError.missingBundleIdentifier: return Strings.Errors.cacheConfiguration
        case NotificationError.notAllowed: return Strings.Errors.notificationPermission
        case NotificationError.authorizationFailed(let underlying):
            return isNotificationPermissionDenied(underlying)
                ? Strings.Errors.notificationPermission : Strings.Errors.notificationAuthorization
        case NotificationError.schedulingFailed(let underlying):
            return isNotificationPermissionDenied(underlying)
                ? Strings.Errors.notificationPermission : Strings.Errors.notificationScheduling
        default: break
        }
        let systemError = error as NSError
        if systemError.domain == UNErrorDomain {
            return systemError.code == UNError.Code.notificationsNotAllowed.rawValue
                ? Strings.Errors.notificationPermission : Strings.Errors.notificationScheduling
        }
        if case APIError.httpStatus(let status) = error {
            switch status {
            case 400, 422: return Strings.Errors.badRequest
            case 401: return Strings.Errors.unauthorized
            case 403: return Strings.Errors.forbidden
            case 404, 410: return Strings.Errors.notFound
            case 408, 504: return Strings.Errors.requestTimeout
            case 409: return Strings.Errors.conflict
            case 429: return Strings.Errors.rateLimited
            case 500...599: return Strings.Errors.serviceUnavailable
            default: return Strings.Errors.httpFailure
            }
        }
        if let urlError = error as? URLError {
            switch urlError.code {
            case .badURL, .unsupportedURL:
                return Strings.Errors.invalidURL
            case .badServerResponse, .zeroByteResource:
                return Strings.Errors.invalidResponse
            case .cannotDecodeRawData, .cannotDecodeContentData, .cannotParseResponse:
                return Strings.Errors.decoding
            case .notConnectedToInternet, .dataNotAllowed, .internationalRoamingOff, .callIsActive:
                return Strings.Errors.offline
            case .networkConnectionLost:
                return Strings.Errors.connectionLost
            case .timedOut:
                return Strings.Errors.requestTimeout
            case .cannotFindHost, .cannotConnectToHost, .dnsLookupFailed:
                return Strings.Errors.unreachable
            case .secureConnectionFailed, .serverCertificateHasBadDate, .serverCertificateUntrusted,
                 .serverCertificateHasUnknownRoot, .serverCertificateNotYetValid,
                 .clientCertificateRejected, .clientCertificateRequired:
                return Strings.Errors.secureConnection
            default: break
            }
        }
        let cocoaError = error as NSError
        if error is SwiftDataError || (cocoaError.domain == NSCocoaErrorDomain &&
            ((1550...1699).contains(cocoaError.code) || (132000...134999).contains(cocoaError.code))) {
            return Strings.Errors.database
        }
        return error.localizedDescription
    }
}
