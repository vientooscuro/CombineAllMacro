# CombineAll Macro

A Swift macro that automatically generates dictionaries of static properties or static functions based on their type.

## Features

- ✅ **Property Mode**: Collect static properties of a specific type into a named dictionary
- ✅ **Function Mode**: Collect static functions returning a specific type into a named dictionary
- ✅ Supports nested types (e.g., `String.Size`, `Int.Size`)
- ✅ Type-safe dictionaries for properties
- ✅ Function references stored with their signatures preserved

## Installation

Add this package to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/vientooscuro/CombineAllMacro.git", from: "1.0.0")
]
```

## Usage

### Property Mode

Use `@CombineAll(type: "TypeName")` to collect static properties:

```swift
import CombineAllMacro

struct Color {
    let name: String
}

@CombineAll(type: "Color")
public enum MyColors {
    static var red: Color { Color(name: "red") }
    static var blue: Color { Color(name: "blue") }
    static var green: Color { Color(name: "green") }
    
    // This will be ignored (wrong type)
    static let notAColor: Int = 0
}

// Generated extension provides:
// MyColors.namedColorValues: [String: Color]

// Usage:
for (name, color) in MyColors.namedColorValues {
    print("\(name): \(color.name)")
}
// Output:
// red: red
// blue: blue
// green: green
```

### Function Mode (NEW!)

Use `@CombineAll(funcType: "ReturnType")` to collect static functions:

```swift
import CombineAllMacro

enum SizeType {
    case small, medium, large
}

class MyAwesomeClass {
    let id: Int
    init(id: Int) { self.id = id }
}

@CombineAll(funcType: "MyAwesomeClass")
public struct FunctionContainer {
    static func first(size: SizeType) -> MyAwesomeClass {
        MyAwesomeClass(id: 100)
    }
    
    static func second(size: SizeType) -> MyAwesomeClass {
        MyAwesomeClass(id: 200)
    }
    
    static func third(size: SizeType) -> MyAwesomeClass {
        MyAwesomeClass(id: 300)
    }
    
    // This will be ignored (wrong return type)
    static func notAwesome(size: SizeType) -> Int {
        return 42
    }
}

// Generated extension provides:
// FunctionContainer.namedMyAwesomeClassFunctions: [String: Any]

// Usage:
for (name, function) in FunctionContainer.namedMyAwesomeClassFunctions {
    // Cast to the function type to use it
    if let typedFunc = function as? (SizeType) -> MyAwesomeClass {
        let result = typedFunc(.medium)
        print("\(name)(.medium) = \(result.id)")
    }
}
// Output:
// first(.medium) = 100
// second(.medium) = 200
// third(.medium) = 300
```

### Nested Types

The macro supports nested types:

```swift
extension String {
    struct Size { }

    @CombineAll(type: "String.Size")
    public enum Test {
        static let small: String.Size = String.Size()
        static let medium: String.Size = String.Size()
    }
}

// Generated: String.Test.namedStringSizeValues
```

## Generated Names

The macro generates dictionary names based on the type name:

### For Properties:
- Pattern: `named{TypeName}Values`
- Examples:
  - `Color` → `namedColorValues`
  - `String` → `namedStringValues`
  - `MyAwesomeClass` → `namedMyAwesomeClassValues`
  - `Int.Size` → `namedIntSizeValues`

### For Functions:
- Pattern: `named{TypeName}Functions`
- Examples:
  - `Color` → `namedColorFunctions`
  - `MyAwesomeClass` → `namedMyAwesomeClassFunctions`

## Implementation Details

### Property Mode
- Collects all `static` properties with the specified type
- Generates a type-safe dictionary `[String: SpecifiedType]`
- Non-static properties and properties of different types are ignored

### Function Mode
- Collects all `static` functions that return the specified type
- Generates a dictionary `[String: Any]` to store function references
- Functions with different return types are ignored
- Functions preserve their signatures and can be cast back to their original type

### Type Casting for Functions

When retrieving functions from the dictionary, you need to cast them to their proper type:

```swift
// For @Sendable functions (common in Swift 6+)
if let func = dict["name"] as? @Sendable (ParamType) -> ReturnType {
    func(param)
}

// For regular functions
if let func = dict["name"] as? (ParamType) -> ReturnType {
    func(param)
}
```

## Requirements

- Swift 5.9 or later
- Xcode 15 or later

## License

MIT License

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
