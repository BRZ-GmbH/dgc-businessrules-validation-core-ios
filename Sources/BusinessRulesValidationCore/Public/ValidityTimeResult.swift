//
/*
 * Copyright (c) 2022 BRZ GmbH <https://www.brz.gv.at>
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 *
 * SPDX-License-Identifier: MPL-2.0
 */

import Foundation

/**
 Holds the validity result
 */
public struct ValidityTimeResult: Equatable {
    /**
     The date of the validity
     */
    public let time: Date
    /**
     The format
     */
    public let format: ValidityTimeFormat
    
    /**
     The conditions which apply to this validity time result or nil if no conditions apply
     */
    public let conditions: [String]?
    
    public static func == (lhs: ValidityTimeResult, rhs: ValidityTimeResult) -> Bool {
        return lhs.time == rhs.time && lhs.format == rhs.format && (lhs.conditions ?? []).elementsEqual(rhs.conditions ?? []) == true
    }
}
