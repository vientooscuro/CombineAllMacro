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
