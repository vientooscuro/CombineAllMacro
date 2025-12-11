import SwiftCompilerPlugin
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros
import Foundation

public struct CombineAllMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        
        // Extract type or funcType argument
        var targetType = "Color"
        var isFunctionMode = false
        
        if let arguments = node.arguments?.as(LabeledExprListSyntax.self) {
            for argument in arguments {
                if argument.label?.text == "type",
                   let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self),
                   let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
                    targetType = segment.content.text
                    isFunctionMode = false
                } else if argument.label?.text == "funcType",
                          let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self),
                          let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
                    targetType = segment.content.text
                    isFunctionMode = true
                }
            }
        }
        
        // Inspect the members of the declaration
        let members = declaration.memberBlock.members
        
        var properties: [String] = []
        var functions: [String] = []
        
        for member in members {
            if isFunctionMode {
                // Handle static functions
                guard let functionDecl = member.decl.as(FunctionDeclSyntax.self) else {
                    continue
                }
                
                // Check if it is static
                let isStatic = functionDecl.modifiers.contains { modifier in
                    modifier.name.text == "static"
                }
                
                guard isStatic else { continue }
                
                // Check return type
                if let returnClause = functionDecl.signature.returnClause {
                    let returnTypeName = returnClause.type.description.trimmingCharacters(in: .whitespaces)
                    let shortTypeName = targetType.components(separatedBy: ".").last ?? targetType
                    
                    if returnTypeName == targetType || returnTypeName == shortTypeName {
                        functions.append(functionDecl.name.text)
                    }
                }
            } else {
                // Handle static properties
                guard let variableDecl = member.decl.as(VariableDeclSyntax.self) else {
                    continue
                }
                
                // Check if it is static
                let isStatic = variableDecl.modifiers.contains { modifier in
                    modifier.name.text == "static"
                }
                
                guard isStatic else { continue }
                
                // Check bindings
                for binding in variableDecl.bindings {
                    // Check type annotation
                    if let typeAnnotation = binding.typeAnnotation {
                        let typeName = typeAnnotation.type.description.trimmingCharacters(in: .whitespaces)
                        // Compare both the full qualified name and the short name
                        // This handles cases like "Size" matching "String.Size"
                        let shortTypeName = targetType.components(separatedBy: ".").last ?? targetType
                        if typeName == targetType || typeName == shortTypeName {
                            if let identifierPattern = binding.pattern.as(IdentifierPatternSyntax.self) {
                                properties.append(identifierPattern.identifier.text)
                            }
                        }
                    }
                }
            }
        }
        
        // Calculate property name - remove dots to create valid Swift identifier
        let sanitizedTypeName = targetType.replacingOccurrences(of: ".", with: "")
        
        if isFunctionMode {
            // Generate dictionary for functions
            let variableName = "named\(sanitizedTypeName)Functions"
            
            // For functions, we need to store them in a way that preserves their signature
            // We'll create a dictionary where the value type matches the function signature
            // Since we can't know the exact signature at compile time, we store closures
            
            // Check if we have any functions
            guard !functions.isEmpty else {
                // No functions found, return empty extension
                let extensionDecl = try ExtensionDeclSyntax("public extension \(type)") {
                    try VariableDeclSyntax("static var \(raw: variableName): [String: Any]") {
                        "[:]"
                    }
                }
                return [extensionDecl]
            }
            
            // We'll store the functions as their actual function references
            let funcList = functions.map { "\"\($0)\": \($0) as Any" }.joined(separator: ",\n    ")
            
            let extensionDecl = try ExtensionDeclSyntax("public extension \(type)") {
                try VariableDeclSyntax("static var \(raw: variableName): [String: Any]") {
                    "[\n    \(raw: funcList)\n]"
                }
            }
            
            return [extensionDecl]
        } else {
            // Generate dictionary for properties
            let variableName = "named\(sanitizedTypeName)Values"
            let propList = properties.map { "\"\($0)\": \($0)" }.joined(separator: ",\n    ")
            
            let extensionDecl = try ExtensionDeclSyntax("public extension \(type)") {
                try VariableDeclSyntax("static var \(raw: variableName): [String: \(raw: targetType)]") {
                    "[\n    \(raw: propList)\n]"
                }
            }
            
            return [extensionDecl]
        }
    }
}

@main
struct CombineAllMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CombineAllMacro.self,
    ]
}
