import SwiftSyntaxMacros
import SwiftSyntaxMacrosTestSupport
import XCTest

// Macro implementations build for the host, so the corresponding module is not available when cross-compiling. Cross-compiled tests may still make use of the macro itself in end-to-end tests.
#if canImport(iMastPackageMacros)
import iMastPackageMacros

let testMacros: [String: Macro.Type] = [
    "UserInfoProperty": UserInfoPropertyMacro.self,
]
#endif

final class PackageTests: XCTestCase {
    func testMacro() throws {
        #if canImport(iMastPackageMacros)
        assertMacroExpansion(
            """
            extension Some {
                @UserInfoProperty("user.info.key") var hoge: String?
                @UserInfoProperty("user.info.int") var fuga: Int?
            }
            """,
            expandedSource: """
            extension Some {
                var hoge: String? {
                    get {
                        userInfo? ["user.info.key"] as? String
                    }
                    set {
                        if let newValue {
                            addUserInfoEntries(from: ["user.info.key": newValue])
                        } else {
                            userInfo?.removeValue(forKey: "user.info.key")
                        }
                    }
                }
                var fuga: Int? {
                    get {
                        userInfo? ["user.info.int"] as? Int
                    }
                    set {
                        if let newValue {
                            addUserInfoEntries(from: ["user.info.int": newValue])
                        } else {
                            userInfo?.removeValue(forKey: "user.info.int")
                        }
                    }
                }
            }
            """,
            macros: testMacros
        )
        #else
        throw XCTSkip("macros are only supported when running tests for the host platform")
        #endif
    }
}
