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
import jsonlogic

class CertificateCondition: Codable {
    let logic: String
    let localizedViolationDescription: LocalizedValue<String>?
    
    private enum CodingKeys: String, CodingKey {
        case logic
        case localizedViolationDescription = "violation_description"
    }
    
    private var _parsedJsonLogic: JsonLogic? = nil
    
    func parsedJsonLogic() throws -> JsonLogic {
      if let _parsedJsonLogic = _parsedJsonLogic {
        return _parsedJsonLogic
      }
      let parsedJsonLogicObject = try JsonLogic(logic)
      _parsedJsonLogic = parsedJsonLogicObject
      return parsedJsonLogicObject
    }
    
}
