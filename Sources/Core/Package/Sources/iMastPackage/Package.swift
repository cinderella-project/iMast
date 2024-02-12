// The Swift Programming Language
// https://docs.swift.org/swift-book

@attached(accessor)
public macro UserInfoProperty(_ key: String) = #externalMacro(module: "iMastPackageMacros", type: "UserInfoPropertyMacro")

@attached(accessor)
public macro UserInfoCodableProperty(_ key: String) = #externalMacro(module: "iMastPackageMacros", type: "UserInfoCodablePropertyMacro")

