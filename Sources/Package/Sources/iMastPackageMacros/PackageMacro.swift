import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

public struct UserInfoPropertyMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf decl: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        // extract key part
        guard case .argumentList(let arguments) = node.arguments else {
            // TODO: throw error like "arguments required"
            return []
        }
        guard arguments.count == 1, let key = arguments.first else {
            // TODO: throw error like "arguments count wrong"
            return []
        }

        // extract type part
        guard let decl = decl.as(VariableDeclSyntax.self) else {
            // TODO: throw error like "this macro should be attached to var decl"
            return []
        }
        guard decl.bindings.count == 1, let binding = decl.bindings.first else {
            // TODO: throw error like "bindings count wrong"
            return []
        }
        guard let typeAnot = binding.typeAnnotation else {
            // TODO: throw error like "type annotation is required"
            return []
        }
        guard let optionalInnerType = typeAnot.type.as(OptionalTypeSyntax.self)?.wrappedType else {
            // TODO: throw error like "type should be optional wrapped"
            return []
        }
        return [
            """
            get {
                userInfo?[\(key)] as? \(optionalInnerType)
            }
            """,
            """
            set {
                if let newValue {
                    addUserInfoEntries(from: [\(key): newValue])
                } else {
                    userInfo?.removeValue(forKey: \(key))
                }
            }
            """,
        ]
    }
}

public struct UserInfoCodablePropertyMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf decl: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        // extract key part
        guard case .argumentList(let arguments) = node.arguments else {
            // TODO: throw error like "arguments required"
            return []
        }
        guard arguments.count == 1, let key = arguments.first else {
            // TODO: throw error like "arguments count wrong"
            return []
        }

        // extract type part
        guard let decl = decl.as(VariableDeclSyntax.self) else {
            // TODO: throw error like "this macro should be attached to var decl"
            return []
        }
        guard decl.bindings.count == 1, let binding = decl.bindings.first else {
            // TODO: throw error like "bindings count wrong"
            return []
        }
        guard let typeAnot = binding.typeAnnotation else {
            // TODO: throw error like "type annotation is required"
            return []
        }
        guard let optionalInnerType = typeAnot.type.as(OptionalTypeSyntax.self)?.wrappedType else {
            // TODO: throw error like "type should be optional wrapped"
            return []
        }
        return [
            """
            get {
                guard let data = userInfo?[\(key)] as? Data else {
                    return nil
                }
                return try? JSONDecoder().decode(\(optionalInnerType).self, from: data)
            }
            """,
            """
            set {
                if let newValue {
                    addUserInfoEntries(from: [\(key): try? JSONEncoder().encode(newValue)])
                } else {
                    userInfo?.removeValue(forKey: \(key))
                }
            }
            """,
        ]
    }
}

@main
struct PackagePlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        UserInfoPropertyMacro.self,
        UserInfoCodablePropertyMacro.self,
    ]
}
