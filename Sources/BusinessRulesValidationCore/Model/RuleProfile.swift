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

public struct RuleProfile: Codable {
    var id: String
    var localizedName: LocalizedValue<String>
    var links: [String:String]?
    
    private enum CodingKeys: String, CodingKey {
        case id
        case localizedName = "name"
        case links
    }
}
