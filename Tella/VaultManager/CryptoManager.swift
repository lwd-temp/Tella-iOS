//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

protocol CryptoManagerInterface {
    func encrypt(_ data: Data) -> Data?
    func decrypt(_ data: Data) -> Data?
}

class DummyCryptoManager: CryptoManagerInterface {

    func encrypt(_ data: Data) -> Data? {
        return data
    }
    
    func decrypt(_ data: Data) -> Data? {
        return data
    }
    
}

enum KeyEnum {
    case META_PRIVATE
    case PUBLIC
    case PRIVATE

    public func toKeyFileEnum() -> KeyFileEnum? {
        switch (self) {
        case .META_PRIVATE:
            return nil
        case .PUBLIC:
            return .PUBLIC
        case .PRIVATE:
            return .PRIVATE
        }
    }
}

enum KeyFileEnum: String {
    case PUBLIC = "pub-key.txt"
    case PRIVATE = "priv-key.txt"
}


class CryptoManager {
    
    static let shared = CryptoManager(cryptoFileManager: CryptoFileManager())
    private let cryptoFileManager: CryptoFileManagerProtocol
    
    private static let metaPrivateKeyTagPrefix = "org.horizontal.tella.ios"
    private static let algorithm: SecKeyAlgorithm = .eciesEncryptionCofactorX963SHA256AESGCM

    @UserDefaultsProperty(key: "keyID")
    private var keyID: String?

    private func metaPrivateKeyTag(_ keyID: String) -> String {
        return "\(Self.metaPrivateKeyTagPrefix).\(keyID)"
    }
    
    init(cryptoFileManager: CryptoFileManagerProtocol) {
        self.cryptoFileManager = cryptoFileManager
    }
    
    var metaPrivateKeyExists: Bool {
        return recoverMetaPrivateKey() != nil
    }

    // Returns the options for the given key
    private func getOptions(_ type: KeyEnum) -> [String: Any] {
        switch (type) {
        case .META_PRIVATE:
            return [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
                kSecAttrKeySizeInBits as String : 256,
                kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave]
        case .PUBLIC:
            return [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeyClass as String: kSecAttrKeyClassPublic,
                kSecAttrKeySizeInBits as String : 256]
        case .PRIVATE:
            return [kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
                kSecAttrKeyClass as String: kSecAttrKeyClassPrivate,
                kSecAttrKeySizeInBits as String : 256]
        }
    }
    
    // Retrieves the meta private key from the secure enclave.
    // Returns nil on failure or if the key doesn't exist yet.
    private func recoverMetaPrivateKey() -> SecKey? {
        guard let keyID = keyID else { return nil }
        let query = metaPrivateKeyQuery(keyID)
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        guard status == errSecSuccess else {
            debugLog("Error: \(SecCopyErrorMessageString(status, nil) ?? "" as CFString)", space: .crypto)
            return nil
        }
        let key = item as! SecKey
        return key
    }
    
    // Query used to recover the meta private key
    private func metaPrivateKeyQuery(_ keyID: String) -> [String: Any] {
        return [
            kSecClass as String: kSecClassKey,
            kSecAttrApplicationTag as String: metaPrivateKeyTag(keyID),
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecReturnRef as String: true,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
        ]
    }

    // Retrieves a key from a file: meta public, regular public, or regular private.
    // When retrieving the regular private, the user is prompted for their authentication.
    func recoverKey(_ type: KeyEnum) -> SecKey? {
        guard let keyFileType = type.toKeyFileEnum() else {
            return recoverMetaPrivateKey()
        }
        guard var data = cryptoFileManager.recoverKeyData(keyFileType) else {
            debugLog("key not found")
            return nil
        }
        if type == .PRIVATE {
            // Decrypts the regular private key
            guard let metaPrivateKey = recoverKey(.META_PRIVATE) else {
                debugLog("meta private key not recovered")
                return nil
            }
            guard let decryptedData = decrypt(data, metaPrivateKey) else {
                debugLog("data not decrypted")
                return nil
            }
            data = decryptedData
        }
        let options: [String: Any] = getOptions(type)
        var error: Unmanaged<CFError>?
        guard let key = SecKeyCreateWithData(data as CFData, options as CFDictionary, &error) else {
            debugLog("Error: \(error?.takeRetainedValue().localizedDescription ?? "")", space: .crypto)
            return nil
        }
        return key
    }

    @discardableResult
    func deleteMetaKeypair(_ keyID: String) -> Bool {
        let query = metaPrivateKeyQuery(keyID)
        let status = SecItemDelete(query as CFDictionary)
        if status != errSecSuccess {
            print("Failed to delete meta private key in enclave")
            return false
        }
        return true
    }

    // Generates meta public key from meta private key.
    private func createMetaPublicKey(_ privateKey: SecKey) throws -> SecKey {
        debugLog("Saving meta public")
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw RuntimeError("Failed to generate meta public key")
        }
        return publicKey
    }
    
    // Retrieves the regular public key, encrypts the regular private key, and saves both.
    private func saveKeypair(_ privateKey: SecKey, _ metaPrivateKey: SecKey, _ keyID: String) throws {
        var error: Unmanaged<CFError>?
        guard let privateData = SecKeyCopyExternalRepresentation(privateKey, &error) as Data? else {
            let msg = "Error: \(error?.takeRetainedValue().localizedDescription ?? "")"
            throw RuntimeError(msg)
        }
        let metaPublicKey = try createMetaPublicKey(metaPrivateKey)
        guard let privateEncryptedData = encrypt(privateData, metaPublicKey) else {
            throw RuntimeError("Error: Could not encrypt private key")
        }
        guard let publicKey = SecKeyCopyPublicKey(privateKey) else {
            throw RuntimeError("Failed to generate public key")
        }
        guard let publicData = SecKeyCopyExternalRepresentation(publicKey, &error) as Data? else {
            let msg = "Error: \(error?.takeRetainedValue().localizedDescription ?? "")"
            throw RuntimeError(msg)
        }
        try cryptoFileManager.initKeyFolder(keyID)
        guard cryptoFileManager.saveKeyData(privateEncryptedData, .PRIVATE, keyID) else {
            cryptoFileManager.deleteKeyFolder(keyID)
            throw RuntimeError("Failed to save encrypted private key")
        }
        guard cryptoFileManager.saveKeyData(publicData, .PUBLIC, keyID) else {
            cryptoFileManager.deleteKeyFolder(keyID)
            throw RuntimeError("Failed to save public key")
        }
    }
    
    // Generates the meta private key with the appropriate authentication
    private func createMetaPrivateKey(_ type: PasswordTypeEnum, _ appTag: String) throws -> SecKey {
        // .privateKeyUsage needed so it is accessible
        let access = SecAccessControlCreateWithFlags(
                kCFAllocatorDefault,
                kSecAttrAccessibleWhenUnlockedThisDeviceOnly,
                [.privateKeyUsage, type.toFlag()],
                nil)!
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256,
            kSecAttrTokenID as String: kSecAttrTokenIDSecureEnclave,
            kSecPrivateKeyAttrs as String: [
                kSecAttrIsPermanent as String: true,
                kSecAttrApplicationTag as String: appTag,
                kSecAttrAccessControl as String: access
            ]
        ]
        var error: Unmanaged<CFError>?
        guard let metaPrivateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            let msg = "Error: \(error?.takeRetainedValue().localizedDescription ?? "")"
            throw RuntimeError(msg)
        }
        return metaPrivateKey
    }
    
    // Generates a new regular private key. Returns nil on failure.
    private func createPrivateKey() throws -> SecKey {
        let attributes: [String: Any] = [
            kSecAttrKeyType as String: kSecAttrKeyTypeECSECPrimeRandom,
            kSecAttrKeySizeInBits as String: 256
        ]
        var error: Unmanaged<CFError>?
        guard let privateKey = SecKeyCreateRandomKey(attributes as CFDictionary, &error) else {
            print("Creating private key failed")
            let msg = "Error: \(error?.takeRetainedValue().localizedDescription ?? "")"
            throw RuntimeError(msg)
        }
        return privateKey
    }
    
    // Checks if both private keys are properly initialized
    func keysInitialized() -> Bool {
        return metaPrivateKeyExists && cryptoFileManager.keyFileExists(.PRIVATE)
    }
    
    func initKeys(_ type: PasswordTypeEnum) throws {
        debugLog("Creating all-new keys")
        let privateKey = try createPrivateKey()
        try keyHelper(privateKey, type)
    }
    
    func updateKeys(_ privateKey: SecKey, _ type: PasswordTypeEnum) throws {
        guard let keyID = keyID else {
            throw RuntimeError("Could not find key ID")
        }
        try keyHelper(privateKey, type)
        deleteMetaKeypair(keyID)
    }
    
    func keyHelper(_ privateKey: SecKey, _ type: PasswordTypeEnum) throws {
        let newKeyID = UUID().uuidString
        let newAppTag = metaPrivateKeyTag(newKeyID)
        let metaPrivateKey = try createMetaPrivateKey(type, newAppTag)
        try saveKeypair(privateKey, metaPrivateKey, newKeyID)

        if let keyID = keyID {
            cryptoFileManager.deleteKeyFolder(keyID)
        }
        keyID = newKeyID
    }
    
    // Uses the given public key to encrypt the data. Returns nil on failure.
    private func encrypt(_ data: Data, _ publicKey: SecKey) -> Data? {
        guard SecKeyIsAlgorithmSupported(publicKey, .encrypt, CryptoManager.algorithm) else {
            debugLog("Algorithm is not supported", space: .crypto)
            return nil
        }
        var error: Unmanaged<CFError>?
        guard let cipherText = SecKeyCreateEncryptedData(publicKey, CryptoManager.algorithm, data as CFData, &error) as Data? else {
            debugLog("Error: Failed to produce cipher text. \(error!.takeRetainedValue().localizedDescription)", space: .crypto)
            return nil
        }
        return cipherText
    }
    
    // Uses the given private key to decrypt the data. Returns nil on failure.
    func decrypt(_ data: Data, _ privateKey: SecKey) -> Data? {
        guard SecKeyIsAlgorithmSupported(privateKey, .decrypt, CryptoManager.algorithm) else {
            debugLog("Algorithm is not supported")
            return nil
        }
        var error: Unmanaged<CFError>?
        guard let clearText = SecKeyCreateDecryptedData(privateKey, CryptoManager.algorithm, data as CFData, &error) as Data? else {
            debugLog("Decryption failed: \(error!.takeRetainedValue().localizedDescription)", space: .crypto)
            return nil
        }
        return clearText
    }

}

extension CryptoManager: CryptoManagerInterface {
    
    func encrypt(_ data: Data) -> Data? {
        guard let publicKey = recoverKey(.PUBLIC) else {
            debugLog("Failed to recover public key", space: .crypto)
            return nil
        }
        return encrypt(data, publicKey)
    }
    
    func decrypt(_ data: Data) -> Data? {
        return data
    }
    
}