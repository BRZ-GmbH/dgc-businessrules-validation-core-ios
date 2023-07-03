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
 Enum for the time modifier for a date
 */
enum ValidityTimeModifier: String {
    /**
     Sets the time of a given date to the start of the day (hour, minute, second = 0)
     */
    case startOfDay = "startOfDay"
    /**
     Sets the time of a given date to the end of the day (hour 23, minute 59, second 59)
     */
    case endOfDay = "endOfDay"
    /**
     Sets the time of a given date to the start of the month (and start of the day)
     */
    case startOfMonth = "startOfMonth"
    /**
     Sets the time of a given date to the end of month (and end of that day)
     */
    case endOfMonth = "endOfMonth"
}
