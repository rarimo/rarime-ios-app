import Foundation

let CIRCUIT_DATA_URLS: [String: URL] = [
    "registerIdentity_2_256_3_6_336_264_21_2448_6_2008": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits/v0.2.0/registerIdentity_2_256_3_6_336_264_21_2448_6_2008-download.zip")!,
    "registerIdentity_2_256_3_6_336_248_1_2432_3_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits/v0.2.1/registerIdentity_2_256_3_6_336_248_1_2432_3_256-download.zip")!,
    "registerIdentity_20_256_3_3_336_224_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits/v0.2.4/registerIdentity_20_256_3_3_336_224_NA-download.zip")!,
    "registerIdentityLight160": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits/v0.2.6-light/registerIdentityLight160-download.zip")!,
    "registerIdentityLight224": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits/v0.2.6-light/registerIdentityLight224-download.zip")!,
    "registerIdentityLight256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits/v0.2.6-light/registerIdentityLight256-download.zip")!,
    "registerIdentityLight384": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits/v0.2.6-light/registerIdentityLight384-download.zip")!,
    "registerIdentityLight512": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits/v0.2.6-light/registerIdentityLight512-download.zip")!,
    "registerIdentity_14_256_3_4_336_64_1_1480_5_296": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits/v0.2.10/registerIdentity_14_256_3_4_336_64_1_1480_5_296-download.zip")!,
    "registerIdentity_1_256_3_6_336_560_1_2744_4_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits/v0.2.11/registerIdentity_1_256_3_6_336_560_1_2744_4_256-download.zip")!,
    "registerIdentity_20_256_3_5_336_72_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits/v0.2.11/registerIdentity_20_256_3_5_336_72_NA-download.zip")!,
    "registerIdentity_4_160_3_3_336_216_1_1296_3_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits/v0.2.12/registerIdentity_4_160_3_3_336_216_1_1296_3_256-download.zip")!,
    "registerIdentity_20_160_3_3_736_200_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits/v0.2.12/registerIdentity_20_160_3_3_736_200_NA-download.zip")!
]

let NOIR_CIRCUIT_DATA_URLS: [String: URL] = [
    "registerIdentity_2_256_3_6_336_264_21_2448_6_2008": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.3/registerIdentity_2_256_3_6_336_264_21_2448_6_2008.json")!,
    "registerIdentity_2_256_3_6_336_248_1_2432_3_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.3/registerIdentity_2_256_3_6_336_248_1_2432_3_256.json")!,
    "registerIdentity_20_256_3_3_336_224_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.3/registerIdentity_20_256_3_3_336_224_NA.json")!,
    "registerIdentity_10_256_3_3_576_248_1_1184_5_264": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v1.0.4/registerIdentity_10_256_3_3_576_248_1_1184_5_264.json")!,
    "registerIdentity_1_256_3_4_600_248_1_1496_3_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v1.0.4/registerIdentity_1_256_3_4_600_248_1_1496_3_256.json")!,
    "registerIdentity_21_256_3_3_576_232_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v1.0.4/registerIdentity_21_256_3_3_576_232_NA.json")!,
    "registerIdentity_21_256_3_4_576_232_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.5-fix/registerIdentity_21_256_3_4_576_232_NA.json")!,
    "registerIdentity_11_256_3_4_336_232_1_1480_4_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.6-fix/registerIdentity_11_256_3_4_336_232_1_1480_4_256.json")!,
    "registerIdentity_2_256_3_6_576_248_1_2432_3_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.6-fix/registerIdentity_2_256_3_6_576_248_1_2432_3_256.json")!,
    "registerIdentity_3_512_3_3_336_264_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.6-fix/registerIdentity_3_512_3_3_336_264_NA.json")!,
    "registerIdentity_1_256_3_5_336_248_1_2120_4_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.7-fix/registerIdentity_1_256_3_5_336_248_1_2120_4_256.json")!,
    "registerIdentity_2_256_3_4_336_232_1_1480_4_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.7-fix/registerIdentity_2_256_3_4_336_232_1_1480_4_256.json")!,
    "registerIdentity_2_256_3_4_336_248_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.7-fix/registerIdentity_2_256_3_4_336_248_NA.json")!,
    "registerIdentity_14_256_3_3_576_240_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.8-fix/registerIdentity_14_256_3_3_576_240_NA.json")!,
    "registerIdentity_14_256_3_4_576_248_1_1496_3_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.8-fix/registerIdentity_14_256_3_4_576_248_1_1496_3_256.json")!,
    "registerIdentity_20_160_3_2_576_184_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.8-fix/registerIdentity_20_160_3_2_576_184_NA.json")!,
    "registerIdentity_1_256_3_5_576_248_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.9-fix/registerIdentity_1_256_3_5_576_248_NA.json")!,
    "registerIdentity_1_256_3_6_576_264_1_2448_3_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.9-fix/registerIdentity_1_256_3_6_576_264_1_2448_3_256.json")!,
    "registerIdentity_20_160_3_3_576_200_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.9-fix/registerIdentity_20_160_3_3_576_200_NA.json")!,
    "registerIdentity_11_256_3_3_576_248_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.10-fix/registerIdentity_11_256_3_3_576_248_NA.json")!,
    "registerIdentity_23_160_3_3_576_200_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.10-fix/registerIdentity_23_160_3_3_576_200_NA.json")!,
    "registerIdentity_3_256_3_4_600_248_1_1496_3_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.10-fix/registerIdentity_3_256_3_4_600_248_1_1496_3_256.json")!,
    "registerIdentity_20_256_3_5_336_248_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.11-fix/registerIdentity_20_256_3_5_336_248_NA.json")!,
    "registerIdentity_24_256_3_4_336_248_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.11-fix/registerIdentity_24_256_3_4_336_248_NA.json")!,
    "registerIdentity_6_160_3_3_336_216_1_1080_3_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.11-fix/registerIdentity_6_160_3_3_336_216_1_1080_3_256.json")!,
    "registerIdentity_11_256_3_5_576_248_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.12-fix/registerIdentity_11_256_3_5_576_248_NA.json")!,
    "registerIdentity_14_256_3_4_336_232_1_1480_5_296": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.12-fix/registerIdentity_14_256_3_4_336_232_1_1480_5_296.json")!,
    "registerIdentity_1_256_3_4_576_232_1_1480_3_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.12-fix/registerIdentity_1_256_3_4_576_232_1_1480_3_256.json")!,
    "registerIdentity_11_256_3_5_576_264_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.13/registerIdentity_11_256_3_5_576_264_NA.json")!,
    "registerIdentity_11_256_3_5_584_264_1_2136_4_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.13/registerIdentity_11_256_3_5_584_264_1_2136_4_256.json")!,
    "registerIdentity_1_256_3_4_336_232_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.14/registerIdentity_1_256_3_4_336_232_NA.json")!,
    "registerIdentity_2_256_3_4_336_248_22_1496_7_2408": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.14/registerIdentity_2_256_3_4_336_248_22_1496_7_2408.json")!,

    "registerIdentity_1_256_3_5_336_248_1_2120_3_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.18/registerIdentity_1_256_3_5_336_248_1_2120_3_256.json")!,
    "registerIdentity_7_160_3_3_336_216_1_1080_3_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.18/registerIdentity_7_160_3_3_336_216_1_1080_3_256.json")!,

    "registerIdentity_8_160_3_3_336_216_1_1080_3_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.19/registerIdentity_8_160_3_3_336_216_1_1080_3_256.json")!,

    "registerIdentity_3_256_3_3_576_248_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.20/registerIdentity_3_256_3_3_576_248_NA.json")!,

    "registerIdentity_25_384_3_3_336_264_1_2024_3_296": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.21/registerIdentity_25_384_3_3_336_264_1_2024_3_296.json")!,

    "registerIdentity_28_384_3_3_576_264_24_2024_4_2792": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.22/registerIdentity_28_384_3_3_576_264_24_2024_4_2792.json")!,
    "registerIdentity_1_256_3_6_576_248_1_2432_5_296": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.22/registerIdentity_1_256_3_6_576_248_1_2432_5_296.json")!,
    "registerIdentity_25_384_3_3_336_248_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.22/registerIdentity_25_384_3_3_336_248_NA.json")!,

    "registerIdentity_1_160_3_3_576_200_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.23/registerIdentity_1_160_3_3_576_200_NA.json")!,
    "registerIdentity_1_256_3_3_576_248_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.23/registerIdentity_1_256_3_3_576_248_NA.json")!,
    "registerIdentity_1_256_3_4_336_232_1_1480_5_296": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.23/registerIdentity_1_256_3_4_336_232_1_1480_5_296.json")!,

    "registerIdentity_1_256_3_6_336_248_1_2744_4_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.24/registerIdentity_1_256_3_6_336_248_1_2744_4_256.json")!,
    "registerIdentity_2_256_3_6_336_264_1_2448_3_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.24/registerIdentity_2_256_3_6_336_264_1_2448_3_256.json")!,
    "registerIdentity_3_160_3_3_336_200_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.24/registerIdentity_3_160_3_3_336_200_NA.json")!,

    "registerIdentity_3_160_3_4_576_216_1_1512_3_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.25/registerIdentity_3_160_3_4_576_216_1_1512_3_256.json")!,
    "registerIdentity_11_256_3_2_336_216_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.25/registerIdentity_11_256_3_2_336_216_NA.json")!,
    "registerIdentity_11_256_3_3_336_248_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.25/registerIdentity_11_256_3_3_336_248_NA.json")!,

    "registerIdentity_11_256_3_3_576_240_1_864_5_264": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.26/registerIdentity_11_256_3_3_576_240_1_864_5_264.json")!,
    "registerIdentity_11_256_3_3_576_248_1_1184_5_264": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.26/registerIdentity_11_256_3_3_576_248_1_1184_5_264.json")!,
    "registerIdentity_11_256_3_4_584_248_1_1496_4_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.26/registerIdentity_11_256_3_4_584_248_1_1496_4_256.json")!,

    "registerIdentity_11_256_3_5_576_248_1_1808_5_296": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.27/registerIdentity_11_256_3_5_576_248_1_1808_5_296.json")!,
    "registerIdentity_12_256_3_3_336_232_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.27/registerIdentity_12_256_3_3_336_232_NA.json")!,
    "registerIdentity_15_512_3_3_336_248_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.27/registerIdentity_15_512_3_3_336_248_NA.json")!,

    "registerIdentity_21_256_3_3_336_232_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.28/registerIdentity_21_256_3_3_336_232_NA.json")!,
    "registerIdentity_21_256_3_5_576_232_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.28/registerIdentity_21_256_3_5_576_232_NA.json")!,
    "registerIdentity_24_256_3_4_336_232_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.28/registerIdentity_24_256_3_4_336_232_NA.json")!,

    "registerIdentity_11_256_3_5_576_248_1_1808_4_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.29/registerIdentity_11_256_3_5_576_248_1_1808_4_256.json")!,

    "registerIdentity_25_384_3_5_576_248_20_3768_3_2008": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.30/registerIdentity_25_384_3_5_576_248_20_3768_3_2008.json")!,
    "registerIdentity_1_256_3_6_336_248_1_2432_3_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.30/registerIdentity_1_256_3_6_336_248_1_2432_3_256.json")!,
    "registerIdentity_2_256_3_5_336_248_22_1808_7_2408": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.30/registerIdentity_2_256_3_5_336_248_22_1808_7_2408.json")!,

    "registerIdentity_11_256_3_4_576_248_1_1496_5_296": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.31/registerIdentity_11_256_3_4_576_248_1_1496_5_296.json")!,
    "registerIdentity_1_256_3_4_336_248_1_1496_4_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.31/registerIdentity_1_256_3_4_336_248_1_1496_4_256.json")!,

    "registerIdentity_21_256_3_7_336_264_21_3072_6_2008": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.32/registerIdentity_21_256_3_7_336_264_21_3072_6_2008.json")!,
    "registerIdentity_1_256_3_5_344_232_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.32/registerIdentity_1_256_3_5_344_232_NA.json")!,

    "registerIdentity_1_256_3_5_336_232_NA": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.33/registerIdentity_1_256_3_5_336_232_NA.json")!,

    "registerIdentity_1_256_3_7_336_264_20_2760_6_2008": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.34/registerIdentity_1_256_3_7_336_264_20_2760_6_2008.json")!,

    "registerIdentity_1_256_3_4_336_232_1_1480_4_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.36/registerIdentity_1_256_3_4_336_232_1_1480_4_256.json")!,

    "registerIdentity_1_256_3_4_336_248_1_560_4_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.37/registerIdentity_1_256_3_4_336_248_1_560_4_256.json")!,

    "registerIdentity_26_512_3_2_336_248_1_1384_2_256": URL(string: "https://storage.googleapis.com/rarimo-store/passport-zk-circuits-noir/v0.1.38/registerIdentity_26_512_3_2_336_248_1_1384_2_256.json")!
]

let ZKEY_URLS: [String: URL] = [
    "likeness": URL(string: "https://storage.googleapis.com/rarimo-store/zkey/circuit_final.zkey")!
]

let DOWNLOADABLE_FILE_URLS: [String: URL] = [
    "faceRecognitionTFLite": URL(string: "https://storage.googleapis.com/rarimo-store/face-recognition/face-recognition.tflite")!,
    "ultraPlonkTrustedSetup.dat": URL(string: "https://storage.googleapis.com/rarimo-store/trusted-setups/ultraPlonkTrustedSetup.dat")!
]
