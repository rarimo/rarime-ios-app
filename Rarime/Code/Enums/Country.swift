enum Country {
    case afghanistan, alandIslands, albania, algeria, americanSamoa, andorra, angola, anguilla, antarctica, antiguaAndBarbuda, argentina, armenia, aruba, australia, austria, azerbaijan
    case bahamas, bahrain, bangladesh, barbados, belarus, belgium, belize, benin, bermuda, bhutan, bolivia, bonaire, bosniaAndHerzegovina, botswana, bouvetIsland, brazil, britishIndianOceanTerritory, bruneiDarussalam, bulgaria, burkinaFaso, burundi
    case caboVerde, cambodia, cameroon, canada, caymanIslands, centralAfricanRepublic, chad, chile, china, christmasIsland, cocosIslands, colombia, comoros, congo, congoDemocraticRepublic, cookIslands, costaRica, coteDIvoire, croatia, cuba, curacao, cyprus, czechia
    case denmark, djibouti, dominica, dominicanRepublic
    case ecuador, egypt, elSalvador, equatorialGuinea, eritrea, estonia, eswatini, ethiopia
    case falklandIslands, faroeIslands, fiji, finland, france, frenchGuiana, frenchPolynesia, frenchSouthernTerritories
    case gabon, gambia, georgia, germany, ghana, gibraltar, greece, greenland, grenada, guadeloupe, guam, guatemala, guernsey, guinea, guineaBissau, guyana
    case haiti, heardIslandAndMcDonaldIslands, holySee, honduras, hongKong, hungary
    case iceland, india, indonesia, iran, iraq, ireland, isleOfMan, israel, italy
    case jamaica, japan, jersey, jordan
    case kazakhstan, kenya, kiribati, koreaDemocraticPeoplesRepublic, koreaRepublic, kuwait, kyrgyzstan
    case laos, latvia, lebanon, lesotho, liberia, libya, liechtenstein, lithuania, luxembourg
    case macao, madagascar, malawi, malaysia, maldives, mali, malta, marshallIslands, martinique, mauritania, mauritius, mayotte, mexico, micronesia, moldova, monaco, mongolia, montenegro, montserrat, morocco, mozambique, myanmar
    case namibia, nauru, nepal, netherlands, newCaledonia, newZealand, nicaragua, niger, nigeria, niue, norfolkIsland, northMacedonia, northernMarianaIslands, norway
    case oman
    case pakistan, palau, palestine, panama, papuaNewGuinea, paraguay, peru, philippines, pitcairn, poland, portugal, puertoRico
    case qatar
    case reunion, romania, russianFederation, rwanda
    case saintBarthelemy, saintHelena, saintKittsAndNevis, saintLucia, saintMartin, saintPierreAndMiquelon, saintVincentAndTheGrenadines, samoa, sanMarino, saoTomeAndPrincipe, saudiArabia, senegal, serbia, seychelles, sierraLeone, singapore, sintMaarten, slovakia, slovenia, solomonIslands, somalia, southAfrica, southGeorgiaAndTheSouthSandwichIslands, southSudan, spain, sriLanka, sudan, suriname, svalbardAndJanMayen, sweden, switzerland, syrianArabRepublic
    case taiwan, tajikistan, tanzania, thailand, timorLeste, togo, tokelau, tonga, trinidadAndTobago, tunisia, turkey, turkmenistan, turksAndCaicosIslands, tuvalu
    case uganda, ukraine, unitedArabEmirates, unitedKingdom, unitedStates, uruguay, uzbekistan
    case vanuatu, venezuela, vietnam, virginIslandsBritish, virginIslandsUS
    case wallisAndFutuna, westernSahara
    case yemen
    case zambia, zimbabwe
    case unknown
}

extension Country {
    static func fromISOCode(_ code: String) -> Country {
        switch code {
        case "ABW": .aruba
        case "AFG": .afghanistan
        case "AGO": .angola
        case "AIA": .anguilla
        case "ALA": .alandIslands
        case "ALB": .albania
        case "AND": .andorra
        case "ARE": .unitedArabEmirates
        case "ARG": .argentina
        case "ARM": .armenia
        case "ASM": .americanSamoa
        case "ATA": .antarctica
        case "ATF": .frenchSouthernTerritories
        case "ATG": .antiguaAndBarbuda
        case "AUS": .australia
        case "AUT": .austria
        case "AZE": .azerbaijan
        case "BDI": .burundi
        case "BEL": .belgium
        case "BEN": .benin
        case "BES": .bonaire
        case "BFA": .burkinaFaso
        case "BGD": .bangladesh
        case "BGR": .bulgaria
        case "BHR": .bahrain
        case "BHS": .bahamas
        case "BIH": .bosniaAndHerzegovina
        case "BLM": .saintBarthelemy
        case "BLR": .belarus
        case "BLZ": .belize
        case "BMU": .bermuda
        case "BOL": .bolivia
        case "BRA": .brazil
        case "BRB": .barbados
        case "BRN": .bruneiDarussalam
        case "BTN": .bhutan
        case "BVT": .bouvetIsland
        case "BWA": .botswana
        case "CAF": .centralAfricanRepublic
        case "CAN": .canada
        case "CCK": .cocosIslands
        case "CHE": .switzerland
        case "CHL": .chile
        case "CHN": .china
        case "CIV": .coteDIvoire
        case "CMR": .cameroon
        case "COD": .congoDemocraticRepublic
        case "COG": .congo
        case "COK": .cookIslands
        case "COL": .colombia
        case "COM": .comoros
        case "CPV": .caboVerde
        case "CRI": .costaRica
        case "CUB": .cuba
        case "CUW": .curacao
        case "CXR": .christmasIsland
        case "CYM": .caymanIslands
        case "CYP": .cyprus
        case "CZE": .czechia
        // German passports have one-letter country codes instead of three-letter ones
        case "DEU", "D", "D<<": .germany
        case "DJI": .djibouti
        case "DMA": .dominica
        case "DNK": .denmark
        case "DOM": .dominicanRepublic
        case "DZA": .algeria
        case "ECU": .ecuador
        case "EGY": .egypt
        case "ERI": .eritrea
        case "ESH": .westernSahara
        case "ESP": .spain
        case "EST": .estonia
        case "ETH": .ethiopia
        case "FIN": .finland
        case "FJI": .fiji
        case "FLK": .falklandIslands
        case "FRA": .france
        case "FRO": .faroeIslands
        case "FSM": .micronesia
        case "GAB": .gabon
        case "GBR": .unitedKingdom
        case "GEO": .georgia
        case "GGY": .guernsey
        case "GHA": .ghana
        case "GIB": .gibraltar
        case "GIN": .guinea
        case "GLP": .guadeloupe
        case "GMB": .gambia
        case "GNB": .guineaBissau
        case "GNQ": .equatorialGuinea
        case "GRC": .greece
        case "GRD": .grenada
        case "GRL": .greenland
        case "GTM": .guatemala
        case "GUF": .frenchGuiana
        case "GUM": .guam
        case "GUY": .guyana
        case "HKG": .hongKong
        case "HMD": .heardIslandAndMcDonaldIslands
        case "HND": .honduras
        case "HRV": .croatia
        case "HTI": .haiti
        case "HUN": .hungary
        case "IDN": .indonesia
        case "IMN": .isleOfMan
        case "IND": .india
        case "IOT": .britishIndianOceanTerritory
        case "IRL": .ireland
        case "IRN": .iran
        case "IRQ": .iraq
        case "ISL": .iceland
        case "ISR": .israel
        case "ITA": .italy
        case "JAM": .jamaica
        case "JEY": .jersey
        case "JOR": .jordan
        case "JPN": .japan
        case "KAZ": .kazakhstan
        case "KEN": .kenya
        case "KGZ": .kyrgyzstan
        case "KHM": .cambodia
        case "KIR": .kiribati
        case "KNA": .saintKittsAndNevis
        case "KOR": .koreaRepublic
        case "KWT": .kuwait
        case "LAO": .laos
        case "LBN": .lebanon
        case "LBR": .liberia
        case "LBY": .libya
        case "LCA": .saintLucia
        case "LIE": .liechtenstein
        case "LKA": .sriLanka
        case "LSO": .lesotho
        case "LTU": .lithuania
        case "LUX": .luxembourg
        case "LVA": .latvia
        case "MAC": .macao
        case "MAF": .saintMartin
        case "MAR": .morocco
        case "MCO": .monaco
        case "MDA": .moldova
        case "MDG": .madagascar
        case "MDV": .maldives
        case "MEX": .mexico
        case "MHL": .marshallIslands
        case "MKD": .northMacedonia
        case "MLI": .mali
        case "MLT": .malta
        case "MMR": .myanmar
        case "MNE": .montenegro
        case "MNG": .mongolia
        case "MNP": .northernMarianaIslands
        case "MOZ": .mozambique
        case "MRT": .mauritania
        case "MSR": .montserrat
        case "MTQ": .martinique
        case "MUS": .mauritius
        case "MWI": .malawi
        case "MYS": .malaysia
        case "MYT": .mayotte
        case "NAM": .namibia
        case "NCL": .newCaledonia
        case "NER": .niger
        case "NFK": .norfolkIsland
        case "NGA": .nigeria
        case "NIC": .nicaragua
        case "NIU": .niue
        case "NLD": .netherlands
        case "NOR": .norway
        case "NPL": .nepal
        case "NRU": .nauru
        case "NZL": .newZealand
        case "OMN": .oman
        case "PAK": .pakistan
        case "PAN": .panama
        case "PCN": .pitcairn
        case "PER": .peru
        case "PHL": .philippines
        case "PLW": .palau
        case "PNG": .papuaNewGuinea
        case "POL": .poland
        case "PRI": .puertoRico
        case "PRK": .koreaDemocraticPeoplesRepublic
        case "PRT": .portugal
        case "PRY": .paraguay
        case "PSE": .palestine
        case "PYF": .frenchPolynesia
        case "QAT": .qatar
        case "REU": .reunion
        case "ROU": .romania
        case "RUS": .russianFederation
        case "RWA": .rwanda
        case "SAU": .saudiArabia
        case "SDN": .sudan
        case "SEN": .senegal
        case "SGP": .singapore
        case "SGS": .southGeorgiaAndTheSouthSandwichIslands
        case "SHN": .saintHelena
        case "SJM": .svalbardAndJanMayen
        case "SLB": .solomonIslands
        case "SLE": .sierraLeone
        case "SLV": .elSalvador
        case "SMR": .sanMarino
        case "SOM": .somalia
        case "SPM": .saintPierreAndMiquelon
        case "SRB": .serbia
        case "SSD": .southSudan
        case "STP": .saoTomeAndPrincipe
        case "SUR": .suriname
        case "SVK": .slovakia
        case "SVN": .slovenia
        case "SWE": .sweden
        case "SWZ": .eswatini
        case "SXM": .sintMaarten
        case "SYC": .seychelles
        case "SYR": .syrianArabRepublic
        case "TCA": .turksAndCaicosIslands
        case "TCD": .chad
        case "TGO": .togo
        case "THA": .thailand
        case "TJK": .tajikistan
        case "TKL": .tokelau
        case "TKM": .turkmenistan
        case "TLS": .timorLeste
        case "TON": .tonga
        case "TTO": .trinidadAndTobago
        case "TUN": .tunisia
        case "TUR": .turkey
        case "TUV": .tuvalu
        case "TWN": .taiwan
        case "TZA": .tanzania
        case "UGA": .uganda
        case "UKR": .ukraine
        case "UMI": .unitedStates
        case "URY": .uruguay
        case "USA": .unitedStates
        case "UZB": .uzbekistan
        case "VAT": .holySee
        case "VCT": .saintVincentAndTheGrenadines
        case "VEN": .venezuela
        case "VGB": .virginIslandsBritish
        case "VIR": .virginIslandsUS
        case "VNM": .vietnam
        case "VUT": .vanuatu
        case "WLF": .wallisAndFutuna
        case "WSM": .samoa
        case "YEM": .yemen
        case "ZAF": .southAfrica
        case "ZMB": .zambia
        case "ZWE": .zimbabwe
        default: .unknown
        }
    }
}

extension Country {
    var flag: String {
        switch self {
        case .afghanistan: "🇦🇫"
        case .alandIslands: "🇦🇽"
        case .albania: "🇦🇱"
        case .algeria: "🇩🇿"
        case .americanSamoa: "🇦🇸"
        case .andorra: "🇦🇩"
        case .angola: "🇦🇴"
        case .anguilla: "🇦🇮"
        case .antarctica: "🇦🇶"
        case .antiguaAndBarbuda: "🇦🇬"
        case .argentina: "🇦🇷"
        case .armenia: "🇦🇲"
        case .aruba: "🇦🇼"
        case .australia: "🇦🇺"
        case .austria: "🇦🇹"
        case .azerbaijan: "🇦🇿"
        case .bahamas: "🇧🇸"
        case .bahrain: "🇧🇭"
        case .bangladesh: "🇧🇩"
        case .barbados: "🇧🇧"
        case .belarus: "🇧🇾"
        case .belgium: "🇧🇪"
        case .belize: "🇧🇿"
        case .benin: "🇧🇯"
        case .bermuda: "🇧🇲"
        case .bhutan: "🇧🇹"
        case .bolivia: "🇧🇴"
        case .bonaire: "🇧🇶"
        case .bosniaAndHerzegovina: "🇧🇦"
        case .botswana: "🇧🇼"
        case .bouvetIsland: "🇧🇻"
        case .brazil: "🇧🇷"
        case .britishIndianOceanTerritory: "🇮🇴"
        case .bruneiDarussalam: "🇧🇳"
        case .bulgaria: "🇧🇬"
        case .burkinaFaso: "🇧🇫"
        case .burundi: "🇧🇮"
        case .caboVerde: "🇨🇻"
        case .cambodia: "🇰🇭"
        case .cameroon: "🇨🇲"
        case .canada: "🇨🇦"
        case .caymanIslands: "🇰🇾"
        case .centralAfricanRepublic: "🇨🇫"
        case .chad: "🇹🇩"
        case .chile: "🇨🇱"
        case .china: "🇨🇳"
        case .christmasIsland: "🇨🇽"
        case .cocosIslands: "🇨🇨"
        case .colombia: "🇨🇴"
        case .comoros: "🇰🇲"
        case .congo: "🇨🇬"
        case .congoDemocraticRepublic: "🇨🇩"
        case .cookIslands: "🇨🇰"
        case .costaRica: "🇨🇷"
        case .coteDIvoire: "🇨🇮"
        case .croatia: "🇭🇷"
        case .cuba: "🇨🇺"
        case .curacao: "🇨🇼"
        case .cyprus: "🇨🇾"
        case .czechia: "🇨🇿"
        case .denmark: "🇩🇰"
        case .djibouti: "🇩🇯"
        case .dominica: "🇩🇲"
        case .dominicanRepublic: "🇩🇴"
        case .ecuador: "🇪🇨"
        case .egypt: "🇪🇬"
        case .elSalvador: "🇸🇻"
        case .equatorialGuinea: "🇬🇶"
        case .eritrea: "🇪🇷"
        case .estonia: "🇪🇪"
        case .eswatini: "🇸🇿"
        case .ethiopia: "🇪🇹"
        case .falklandIslands: "🇫🇰"
        case .faroeIslands: "🇫🇴"
        case .fiji: "🇫🇯"
        case .finland: "🇫🇮"
        case .france: "🇫🇷"
        case .frenchGuiana: "🇬🇫"
        case .frenchPolynesia: "🇵🇫"
        case .frenchSouthernTerritories: "🇹🇫"
        case .gabon: "🇬🇦"
        case .gambia: "🇬🇲"
        case .georgia: "🇬🇪"
        case .germany: "🇩🇪"
        case .ghana: "🇬🇭"
        case .gibraltar: "🇬🇮"
        case .greece: "🇬🇷"
        case .greenland: "🇬🇱"
        case .grenada: "🇬🇩"
        case .guadeloupe: "🇬🇵"
        case .guam: "🇬🇺"
        case .guatemala: "🇬🇹"
        case .guernsey: "🇬🇬"
        case .guinea: "🇬🇳"
        case .guineaBissau: "🇬🇼"
        case .guyana: "🇬🇾"
        case .haiti: "🇭🇹"
        case .heardIslandAndMcDonaldIslands: "🇭🇲"
        case .holySee: "🇻🇦"
        case .honduras: "🇭🇳"
        case .hongKong: "🇭🇰"
        case .hungary: "🇭🇺"
        case .iceland: "🇮🇸"
        case .india: "🇮🇳"
        case .indonesia: "🇮🇩"
        case .iran: "🇮🇷"
        case .iraq: "🇮🇶"
        case .ireland: "🇮🇪"
        case .isleOfMan: "🇮🇲"
        case .israel: "🇮🇱"
        case .italy: "🇮🇹"
        case .jamaica: "🇯🇲"
        case .japan: "🇯🇵"
        case .jersey: "🇯🇪"
        case .jordan: "🇯🇴"
        case .kazakhstan: "🇰🇿"
        case .kenya: "🇰🇪"
        case .kiribati: "🇰🇮"
        case .koreaDemocraticPeoplesRepublic: "🇰🇵"
        case .koreaRepublic: "🇰🇷"
        case .kuwait: "🇰🇼"
        case .kyrgyzstan: "🇰🇬"
        case .laos: "🇱🇦"
        case .latvia: "🇱🇻"
        case .lebanon: "🇱🇧"
        case .lesotho: "🇱🇸"
        case .liberia: "🇱🇷"
        case .libya: "🇱🇾"
        case .liechtenstein: "🇱🇮"
        case .lithuania: "🇱🇹"
        case .luxembourg: "🇱🇺"
        case .macao: "🇲🇴"
        case .madagascar: "🇲🇬"
        case .malawi: "🇲🇼"
        case .malaysia: "🇲🇾"
        case .maldives: "🇲🇻"
        case .mali: "🇲🇱"
        case .malta: "🇲🇹"
        case .marshallIslands: "🇲🇭"
        case .martinique: "🇲🇶"
        case .mauritania: "🇲🇷"
        case .mauritius: "🇲🇺"
        case .mayotte: "🇾🇹"
        case .mexico: "🇲🇽"
        case .micronesia: "🇫🇲"
        case .moldova: "🇲🇩"
        case .monaco: "🇲🇨"
        case .mongolia: "🇲🇳"
        case .montenegro: "🇲🇪"
        case .montserrat: "🇲🇸"
        case .morocco: "🇲🇦"
        case .mozambique: "🇲🇿"
        case .myanmar: "🇲🇲"
        case .namibia: "🇳🇦"
        case .nauru: "🇳🇷"
        case .nepal: "🇳🇵"
        case .netherlands: "🇳🇱"
        case .newCaledonia: "🇳🇨"
        case .newZealand: "🇳🇿"
        case .nicaragua: "🇳🇮"
        case .niger: "🇳🇪"
        case .nigeria: "🇳🇬"
        case .niue: "🇳🇺"
        case .norfolkIsland: "🇳🇫"
        case .northMacedonia: "🇲🇰"
        case .northernMarianaIslands: "🇲🇵"
        case .norway: "🇳🇴"
        case .oman: "🇴🇲"
        case .pakistan: "🇵🇰"
        case .palau: "🇵🇼"
        case .palestine: "🇵🇸"
        case .panama: "🇵🇦"
        case .papuaNewGuinea: "🇵🇬"
        case .paraguay: "🇵🇾"
        case .peru: "🇵🇪"
        case .philippines: "🇵🇭"
        case .pitcairn: "🇵🇳"
        case .poland: "🇵🇱"
        case .portugal: "🇵🇹"
        case .puertoRico: "🇵🇷"
        case .qatar: "🇶🇦"
        case .reunion: "🇷🇪"
        case .romania: "🇷🇴"
        case .russianFederation: "🇷🇺"
        case .rwanda: "🇷🇼"
        case .saintBarthelemy: "🇧🇱"
        case .saintHelena: "🇸🇭"
        case .saintKittsAndNevis: "🇰🇳"
        case .saintLucia: "🇱🇨"
        case .saintMartin: "🇲🇫"
        case .saintPierreAndMiquelon: "🇵🇲"
        case .saintVincentAndTheGrenadines: "🇻🇨"
        case .samoa: "🇼🇸"
        case .sanMarino: "🇸🇲"
        case .saoTomeAndPrincipe: "🇸🇹"
        case .saudiArabia: "🇸🇦"
        case .senegal: "🇸🇳"
        case .serbia: "🇷🇸"
        case .seychelles: "🇸🇨"
        case .sierraLeone: "🇸🇱"
        case .singapore: "🇸🇬"
        case .sintMaarten: "🇸🇽"
        case .slovakia: "🇸🇰"
        case .slovenia: "🇸🇮"
        case .solomonIslands: "🇸🇧"
        case .somalia: "🇸🇴"
        case .southAfrica: "🇿🇦"
        case .southGeorgiaAndTheSouthSandwichIslands: "🇬🇸"
        case .southSudan: "🇸🇸"
        case .spain: "🇪🇸"
        case .sriLanka: "🇱🇰"
        case .sudan: "🇸🇩"
        case .suriname: "🇸🇷"
        case .svalbardAndJanMayen: "🇸🇯"
        case .sweden: "🇸🇪"
        case .switzerland: "🇨🇭"
        case .syrianArabRepublic: "🇸🇾"
        case .taiwan: "🇹🇼"
        case .tajikistan: "🇹🇯"
        case .tanzania: "🇹🇿"
        case .thailand: "🇹🇭"
        case .timorLeste: "🇹🇱"
        case .togo: "🇹🇬"
        case .tokelau: "🇹🇰"
        case .tonga: "🇹🇴"
        case .trinidadAndTobago: "🇹🇹"
        case .tunisia: "🇹🇳"
        case .turkey: "🇹🇷"
        case .turkmenistan: "🇹🇲"
        case .turksAndCaicosIslands: "🇹🇨"
        case .tuvalu: "🇹🇻"
        case .uganda: "🇺🇬"
        case .ukraine: "🇺🇦"
        case .unitedArabEmirates: "🇦🇪"
        case .unitedKingdom: "🇬🇧"
        case .unitedStates: "🇺🇸"
        case .uruguay: "🇺🇾"
        case .uzbekistan: "🇺🇿"
        case .vanuatu: "🇻🇺"
        case .venezuela: "🇻🇪"
        case .vietnam: "🇻🇳"
        case .virginIslandsBritish: "🇻🇬"
        case .virginIslandsUS: "🇻🇮"
        case .wallisAndFutuna: "🇼🇫"
        case .westernSahara: "🇪🇭"
        case .yemen: "🇾🇪"
        case .zambia: "🇿🇲"
        case .zimbabwe: "🇿🇼"
        case .unknown: "🏳️"
        }
    }
}

extension Country {
    var name: String {
        switch self {
        case .afghanistan: String(localized: "Afghanistan")
        case .alandIslands: String(localized: "Aland Islands")
        case .albania: String(localized: "Albania")
        case .algeria: String(localized: "Algeria")
        case .americanSamoa: String(localized: "American Samoa")
        case .andorra: String(localized: "Andorra")
        case .angola: String(localized: "Angola")
        case .anguilla: String(localized: "Anguilla")
        case .antarctica: String(localized: "Antarctica")
        case .antiguaAndBarbuda: String(localized: "Antigua and Barbuda")
        case .argentina: String(localized: "Argentina")
        case .armenia: String(localized: "Armenia")
        case .aruba: String(localized: "Aruba")
        case .australia: String(localized: "Australia")
        case .austria: String(localized: "Austria")
        case .azerbaijan: String(localized: "Azerbaijan")
        case .bahamas: String(localized: "Bahamas")
        case .bahrain: String(localized: "Bahrain")
        case .bangladesh: String(localized: "Bangladesh")
        case .barbados: String(localized: "Barbados")
        case .belarus: String(localized: "Belarus")
        case .belgium: String(localized: "Belgium")
        case .belize: String(localized: "Belize")
        case .benin: String(localized: "Benin")
        case .bermuda: String(localized: "Bermuda")
        case .bhutan: String(localized: "Bhutan")
        case .bolivia: String(localized: "Bolivia")
        case .bonaire: String(localized: "Bonaire")
        case .bosniaAndHerzegovina: String(localized: "Bosnia and Herzegovina")
        case .botswana: String(localized: "Botswana")
        case .bouvetIsland: String(localized: "Bouvet Island")
        case .brazil: String(localized: "Brazil")
        case .britishIndianOceanTerritory: String(localized: "British Indian Ocean Territory")
        case .bruneiDarussalam: String(localized: "Brunei Darussalam")
        case .bulgaria: String(localized: "Bulgaria")
        case .burkinaFaso: String(localized: "Burkina Faso")
        case .burundi: String(localized: "Burundi")
        case .caboVerde: String(localized: "Cabo Verde")
        case .cambodia: String(localized: "Cambodia")
        case .cameroon: String(localized: "Cameroon")
        case .canada: String(localized: "Canada")
        case .caymanIslands: String(localized: "Cayman Islands")
        case .centralAfricanRepublic: String(localized: "Central African Republic")
        case .chad: String(localized: "Chad")
        case .chile: String(localized: "Chile")
        case .china: String(localized: "China")
        case .christmasIsland: String(localized: "Christmas Island")
        case .cocosIslands: String(localized: "Cocos Islands")
        case .colombia: String(localized: "Colombia")
        case .comoros: String(localized: "Comoros")
        case .congo: String(localized: "Congo")
        case .congoDemocraticRepublic: String(localized: "Democratic Republic of the Congo")
        case .cookIslands: String(localized: "Cook Islands")
        case .costaRica: String(localized: "Costa Rica")
        case .coteDIvoire: String(localized: "Cote d'Ivoire")
        case .croatia: String(localized: "Croatia")
        case .cuba: String(localized: "Cuba")
        case .curacao: String(localized: "Curacao")
        case .cyprus: String(localized: "Cyprus")
        case .czechia: String(localized: "Czechia")
        case .denmark: String(localized: "Denmark")
        case .djibouti: String(localized: "Djibouti")
        case .dominica: String(localized: "Dominica")
        case .dominicanRepublic: String(localized: "Dominican Republic")
        case .ecuador: String(localized: "Ecuador")
        case .egypt: String(localized: "Egypt")
        case .elSalvador: String(localized: "El Salvador")
        case .equatorialGuinea: String(localized: "Equatorial Guinea")
        case .eritrea: String(localized: "Eritrea")
        case .estonia: String(localized: "Estonia")
        case .eswatini: String(localized: "Eswatini")
        case .ethiopia: String(localized: "Ethiopia")
        case .falklandIslands: String(localized: "Falkland Islands")
        case .faroeIslands: String(localized: "Faroe Islands")
        case .fiji: String(localized: "Fiji")
        case .finland: String(localized: "Finland")
        case .france: String(localized: "France")
        case .frenchGuiana: String(localized: "French Guiana")
        case .frenchPolynesia: String(localized: "French Polynesia")
        case .frenchSouthernTerritories: String(localized: "French Southern Territories")
        case .gabon: String(localized: "Gabon")
        case .gambia: String(localized: "Gambia")
        case .georgia: String(localized: "Georgia")
        case .germany: String(localized: "Germany")
        case .ghana: String(localized: "Ghana")
        case .gibraltar: String(localized: "Gibraltar")
        case .greece: String(localized: "Greece")
        case .greenland: String(localized: "Greenland")
        case .grenada: String(localized: "Grenada")
        case .guadeloupe: String(localized: "Guadeloupe")
        case .guam: String(localized: "Guam")
        case .guatemala: String(localized: "Guatemala")
        case .guernsey: String(localized: "Guernsey")
        case .guinea: String(localized: "Guinea")
        case .guineaBissau: String(localized: "Guinea-Bissau")
        case .guyana: String(localized: "Guyana")
        case .haiti: String(localized: "Haiti")
        case .heardIslandAndMcDonaldIslands: String(localized: "Heard Island and McDonald Islands")
        case .holySee: String(localized: "Holy See")
        case .honduras: String(localized: "Honduras")
        case .hongKong: String(localized: "Hong Kong")
        case .hungary: String(localized: "Hungary")
        case .iceland: String(localized: "Iceland")
        case .india: String(localized: "India")
        case .indonesia: String(localized: "Indonesia")
        case .iran: String(localized: "Iran")
        case .iraq: String(localized: "Iraq")
        case .ireland: String(localized: "Ireland")
        case .isleOfMan: String(localized: "Isle of Man")
        case .israel: String(localized: "Israel")
        case .italy: String(localized: "Italy")
        case .jamaica: String(localized: "Jamaica")
        case .japan: String(localized: "Japan")
        case .jersey: String(localized: "Jersey")
        case .jordan: String(localized: "Jordan")
        case .kazakhstan: String(localized: "Kazakhstan")
        case .kenya: String(localized: "Kenya")
        case .kiribati: String(localized: "Kiribati")
        case .koreaDemocraticPeoplesRepublic: String(localized: "Democratic People's Republic of Korea")
        case .koreaRepublic: String(localized: "Republic of Korea")
        case .kuwait: String(localized: "Kuwait")
        case .kyrgyzstan: String(localized: "Kyrgyzstan")
        case .laos: String(localized: "Laos")
        case .latvia: String(localized: "Latvia")
        case .lebanon: String(localized: "Lebanon")
        case .lesotho: String(localized: "Lesotho")
        case .liberia: String(localized: "Liberia")
        case .libya: String(localized: "Libya")
        case .liechtenstein: String(localized: "Liechtenstein")
        case .lithuania: String(localized: "Lithuania")
        case .luxembourg: String(localized: "Luxembourg")
        case .macao: String(localized: "Macao")
        case .madagascar: String(localized: "Madagascar")
        case .malawi: String(localized: "Malawi")
        case .malaysia: String(localized: "Malaysia")
        case .maldives: String(localized: "Maldives")
        case .mali: String(localized: "Mali")
        case .malta: String(localized: "Malta")
        case .marshallIslands: String(localized: "Marshall Islands")
        case .martinique: String(localized: "Martinique")
        case .mauritania: String(localized: "Mauritania")
        case .mauritius: String(localized: "Mauritius")
        case .mayotte: String(localized: "Mayotte")
        case .mexico: String(localized: "Mexico")
        case .micronesia: String(localized: "Micronesia")
        case .moldova: String(localized: "Moldova")
        case .monaco: String(localized: "Monaco")
        case .mongolia: String(localized: "Mongolia")
        case .montenegro: String(localized: "Montenegro")
        case .montserrat: String(localized: "Montserrat")
        case .morocco: String(localized: "Morocco")
        case .mozambique: String(localized: "Mozambique")
        case .myanmar: String(localized: "Myanmar")
        case .namibia: String(localized: "Namibia")
        case .nauru: String(localized: "Nauru")
        case .nepal: String(localized: "Nepal")
        case .netherlands: String(localized: "Netherlands")
        case .newCaledonia: String(localized: "New Caledonia")
        case .newZealand: String(localized: "New Zealand")
        case .nicaragua: String(localized: "Nicaragua")
        case .niger: String(localized: "Niger")
        case .nigeria: String(localized: "Nigeria")
        case .niue: String(localized: "Niue")
        case .norfolkIsland: String(localized: "Norfolk Island")
        case .northMacedonia: String(localized: "North Macedonia")
        case .northernMarianaIslands: String(localized: "Northern Mariana Islands")
        case .norway: String(localized: "Norway")
        case .oman: String(localized: "Oman")
        case .pakistan: String(localized: "Pakistan")
        case .palau: String(localized: "Palau")
        case .palestine: String(localized: "Palestine")
        case .panama: String(localized: "Panama")
        case .papuaNewGuinea: String(localized: "Papua New Guinea")
        case .paraguay: String(localized: "Paraguay")
        case .peru: String(localized: "Peru")
        case .philippines: String(localized: "Philippines")
        case .pitcairn: String(localized: "Pitcairn")
        case .poland: String(localized: "Poland")
        case .portugal: String(localized: "Portugal")
        case .puertoRico: String(localized: "Puerto Rico")
        case .qatar: String(localized: "Qatar")
        case .reunion: String(localized: "Reunion")
        case .romania: String(localized: "Romania")
        case .russianFederation: String(localized: "Russian Federation")
        case .rwanda: String(localized: "Rwanda")
        case .saintBarthelemy: String(localized: "Saint Barthelemy")
        case .saintHelena: String(localized: "Saint Helena")
        case .saintKittsAndNevis: String(localized: "Saint Kitts and Nevis")
        case .saintLucia: String(localized: "Saint Lucia")
        case .saintMartin: String(localized: "Saint Martin")
        case .saintPierreAndMiquelon: String(localized: "Saint Pierre and Miquelon")
        case .saintVincentAndTheGrenadines: String(localized: "Saint Vincent and the Grenadines")
        case .samoa: String(localized: "Samoa")
        case .sanMarino: String(localized: "San Marino")
        case .saoTomeAndPrincipe: String(localized: "Sao Tome and Principe")
        case .saudiArabia: String(localized: "Saudi Arabia")
        case .senegal: String(localized: "Senegal")
        case .serbia: String(localized: "Serbia")
        case .seychelles: String(localized: "Seychelles")
        case .sierraLeone: String(localized: "Sierra Leone")
        case .singapore: String(localized: "Singapore")
        case .sintMaarten: String(localized: "Sint Maarten")
        case .slovakia: String(localized: "Slovakia")
        case .slovenia: String(localized: "Slovenia")
        case .solomonIslands: String(localized: "Solomon Islands")
        case .somalia: String(localized: "Somalia")
        case .southAfrica: String(localized: "South Africa")
        case .southGeorgiaAndTheSouthSandwichIslands: String(localized: "South Georgia and the South Sandwich Islands")
        case .southSudan: String(localized: "South Sudan")
        case .spain: String(localized: "Spain")
        case .sriLanka: String(localized: "Sri Lanka")
        case .sudan: String(localized: "Sudan")
        case .suriname: String(localized: "Suriname")
        case .svalbardAndJanMayen: String(localized: "Svalbard and Jan Mayen")
        case .sweden: String(localized: "Sweden")
        case .switzerland: String(localized: "Switzerland")
        case .syrianArabRepublic: String(localized: "Syrian Arab Republic")
        case .taiwan: String(localized: "Taiwan")
        case .tajikistan: String(localized: "Tajikistan")
        case .tanzania: String(localized: "Tanzania")
        case .thailand: String(localized: "Thailand")
        case .timorLeste: String(localized: "Timor-Leste")
        case .togo: String(localized: "Togo")
        case .tokelau: String(localized: "Tokelau")
        case .tonga: String(localized: "Tonga")
        case .trinidadAndTobago: String(localized: "Trinidad and Tobago")
        case .tunisia: String(localized: "Tunisia")
        case .turkey: String(localized: "Turkey")
        case .turkmenistan: String(localized: "Turkmenistan")
        case .turksAndCaicosIslands: String(localized: "Turks and Caicos Islands")
        case .tuvalu: String(localized: "Tuvalu")
        case .uganda: String(localized: "Uganda")
        case .ukraine: String(localized: "Ukraine")
        case .unitedArabEmirates: String(localized: "United Arab Emirates")
        case .unitedKingdom: String(localized: "United Kingdom")
        case .unitedStates: String(localized: "United States")
        case .uruguay: String(localized: "Uruguay")
        case .uzbekistan: String(localized: "Uzbekistan")
        case .vanuatu: String(localized: "Vanuatu")
        case .venezuela: String(localized: "Venezuela")
        case .vietnam: String(localized: "Vietnam")
        case .virginIslandsBritish: String(localized: "Virgin Islands, British")
        case .virginIslandsUS: String(localized: "Virgin Islands, U.S.")
        case .wallisAndFutuna: String(localized: "Wallis and Futuna")
        case .westernSahara: String(localized: "Western Sahara")
        case .yemen: String(localized: "Yemen")
        case .zambia: String(localized: "Zambia")
        case .zimbabwe: String(localized: "Zimbabwe")
        case .unknown: String(localized: "Unknown Country")
        }
    }
}
