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
 Enum for the time format of validity times. Should be used to decide which format to use for convert a ValidityTime to human-readable string
 */
public enum ValidityTimeFormat: String {
    /**
     Format as date with time
     */
    case dateTime = "dateTime"
    /**
     Format as date only without time
     */
    case date = "date"
}
