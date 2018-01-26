//
//  AirDataClient+Constants.swift
//  AirPollution
//
//  Created by Gokturk Ramazanoglu on 26.01.18.
//  Copyright © 2018 zigzag. All rights reserved.
//

import Foundation

extension AirDataClient {
    
    struct Constants {
        
        static let LAST_DAY_IMAGE_URL = "https://api.luftdaten.info/grafana/render/dashboard-solo/db/single-sensor-view?orgId=1&panelId=2&width=300&height=200&tz=UTC%2B02%3A00&var-node="
        static let FLOATING_IMAGE_URL = "https://api.luftdaten.info/grafana/render/dashboard-solo/db/single-sensor-view?orgId=1&panelId=1&width=300&height=200&tz=UTC%2B02%3A00&var-node="
        static let CLOSEST_AIR_DATA_URL = "https://api.luftdaten.info/v1/filter/area="
        static let FEINSTAUB_ALARM_URL = "http://istheutefeinstaubalarm.rocks/api/alarm"
        static let AIR_DATA_URL = "https://api.luftdaten.info/v1/filter/area="
    }
    
}
