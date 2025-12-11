/// A macro that generates an extension with a `namedTypes` property containing all static properties of the specified type defined in the attached type.
@attached(extension, names: arbitrary)
public macro CombineAll(type: String) = #externalMacro(module: "CombineAllMacroMacro", type: "CombineAllMacro")

/// A macro that generates an extension with a `namedFunctions` property containing all static functions returning the specified type defined in the attached type.
@attached(extension, names: arbitrary)
public macro CombineAll(funcType: String) = #externalMacro(module: "CombineAllMacroMacro", type: "CombineAllMacro")
