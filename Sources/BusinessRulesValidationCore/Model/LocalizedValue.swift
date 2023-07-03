/*
 * Copyright (c) 2022 BRZ GmbH &lt;https://www.brz.gv.at&gt;
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

/**
 Wrapper for localized value that contains different values based on a 2-character languageKey
 */
public struct LocalizedValue<T: Codable>: Codable {
    let dic: [String: T]

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        dic = (try container.decode([String: T?].self)).reduce(into: [String: T]()) { result, new in
            guard let value = new.value else { return }
            result[String(new.key.prefix(2))] = value
        }
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(dic)
    }

    /**
     Returns the localized value for the given 2-character languageKey or nil of no localized value for that language is defined
     */
    public func value(for languageKey: String) -> T? {
        return dic[languageKey]
    }
}


