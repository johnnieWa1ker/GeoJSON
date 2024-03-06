//
//  GeoJSONError.swift
//  GeoJSON
//
//  Created by Johnnie Walker on 06.03.2024.
//

import Foundation

enum GeoJSONError: Error {
    case urlNotFound
    case parsingFailed(Error)
}
