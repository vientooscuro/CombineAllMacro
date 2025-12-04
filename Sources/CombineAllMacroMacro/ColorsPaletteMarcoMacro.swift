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
        
        // Extract type argument
        var targetType = "Color"
        if let arguments = node.arguments?.as(LabeledExprListSyntax.self) {
            for argument in arguments {
                if argument.label?.text == "type",
                   let stringLiteral = argument.expression.as(StringLiteralExprSyntax.self),
                   let segment = stringLiteral.segments.first?.as(StringSegmentSyntax.self) {
                    targetType = segment.content.text
                }
            }
        }
        
        // Inspect the members of the declaration
        let members = declaration.memberBlock.members
        
        var properties: [String] = []
        
        for member in members {
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
                    if typeName == targetType {
                        if let identifierPattern = binding.pattern.as(IdentifierPatternSyntax.self) {
                            properties.append(identifierPattern.identifier.text)
                        }
                    }
                }
            }
        }
        
        // Calculate property name
        let variableName = "named\(targetType)Values"
        
        // Generate the extension
        let propList = properties.map { "\"\($0)\": \($0)" }.joined(separator: ",\n    ")
        
        let extensionDecl = try ExtensionDeclSyntax("public extension \(type)") {
            try VariableDeclSyntax("static var \(raw: variableName): [String: \(raw: targetType)]") {
                "[\n    \(raw: propList)\n]"
            }
        }
        
        return [extensionDecl]
    }
}

@main
struct CombineAllMacroPlugin: CompilerPlugin {
    let providingMacros: [Macro.Type] = [
        CombineAllMacro.self,
    ]
}
