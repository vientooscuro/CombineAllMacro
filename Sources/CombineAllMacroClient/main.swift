import CombineAllMacro
import Foundation

// --- Color Test ---

public struct Color {
    let name: String
}

@CombineAll(type: "Color")
public enum MyColors {
    static var red: Color { Color(name: "red") }
    static var blue: Color { Color(name: "blue") }
    
    // This should be ignored
    static let notAColor: Int = 0
    
    // This should be ignored (not static)
    var instanceColor: Color { Color(name: "instanceGreen") }
}

print("--- Default (Color) ---")
for (propertyName, color) in MyColors.namedColorValues {
    print("\(propertyName): \(color.name)")
}

// --- String Test ---

@CombineAll(type: "String")
public struct StringsPalette {
    static let hello: String = "Hello"
    static let world: String = "World"
    
    // Ignored
    static let number: Int = 42
}

print("\n--- Strings ---")
for (propertyName, value) in StringsPalette.namedStringValues {
    print("\(propertyName): \(value)")
}


public final class MyAwesomeClass: Sendable {
    public let id: Int
    public init(id: Int) { self.id = id }
}

@CombineAll(type: "MyAwesomeClass")
public struct AwesomeContainer {
    static let first: MyAwesomeClass = MyAwesomeClass(id: 1)
    static let second: MyAwesomeClass = MyAwesomeClass(id: 2)
}

// Since MyAwesomeClass ends in 's', the macro should generate 'namedMyAwesomeClasses'
for (propertyName, value) in AwesomeContainer.namedMyAwesomeClassValues {
    print("\(propertyName): \(value.id)")
}

// --- Nested Type Test (String.Size) ---

extension Int {
    public struct Size: Sendable {}
}

extension String {
    public struct Size: Sendable { }

    @CombineAll(type: "Int.Size")
    public enum Test {
        static let size: Int.Size = Int.Size()
    }
}

print("\n--- Nested Type (String.Size) ---")
for (propertyName, value) in String.Test.namedIntSizeValues {
    print("\(propertyName): \(type(of: value))")
}

// --- Function Mode Test ---

public enum SizeType {
    case small
    case medium
    case large
}

@CombineAll(funcType: "MyAwesomeClass")
public struct FunctionContainer {
    static func first(size: SizeType) -> MyAwesomeClass {
        MyAwesomeClass(id: 100 + size.hashValue)
    }
    
    static func second(size: SizeType) -> MyAwesomeClass {
        MyAwesomeClass(id: 200 + size.hashValue)
    }
    
    static func third(size: SizeType) -> MyAwesomeClass {
        MyAwesomeClass(id: 300 + size.hashValue)
    }
    
    // This should be ignored - wrong return type
    static func notAwesome(size: SizeType) -> Int {
        return 42
    }
}

print("\n--- Function Mode (MyAwesomeClass) ---")
print("Available functions: \(FunctionContainer.namedMyAwesomeClassFunctions.keys.sorted())")

// Calling functions from dictionary
for (functionName, function) in FunctionContainer.namedMyAwesomeClassFunctions {
    // Cast to the function type and call it
    if let typedFunc = function as? @Sendable (SizeType) -> MyAwesomeClass {
        let result = typedFunc(.medium)
        print("\(functionName)(.medium) = \(result.id)")
    }
}
