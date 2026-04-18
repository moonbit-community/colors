# Colors Library

A comprehensive MoonBit library for manipulating colors across multiple color spaces with proper gamma correction and compile-time type safety.

This library is a port of the [OCaml colors library](https://github.com/ocaml-tui/colors) to MoonBit, redesigned with separate types per color space for maximum type safety and performance.

## Features

- **Multiple Color Spaces**: RGB, LinearRGB, XYZ, and CIE LUV with separate types
- **Compile-Time Type Safety**: No runtime type checking or potential panics
- **Seamless Conversions**: Convert between any color spaces with automatic intermediate conversions
- **Color Blending**: Blend colors in RGB or LinearRGB space with proper gamma handling
- **Gamma Correction**: Proper sRGB gamma correction for accurate color representation
- **Trait-Based API**: Clean, consistent methods for all color types
- **Function Chaining**: Fluent API for chaining color operations with pipe operator
- **Performance**: Zero-overhead abstractions with no enum discriminants

## Quick Start

test "quick start example" {
  // Create colors using type-safe constructors
  let red = @colors.rgb(255, 0, 0)
  let linear_red = @colors.linear_rgb(1.0, 0.0, 0.0)

  // Convert between color spaces (compile-time checked)
  let xyz_red = red.to_linear_rgb().to_xyz()
  let luv_red = xyz_red.to_luv()

  // Chain conversions with full type safety
  let final_color = red
    .to_linear_rgb()
    .to_xyz()
    .to_luv()
    .to_xyz()
    .to_linear_rgb()
    .to_rgb()

  // Blend colors
  let blue = @colors.rgb(0, 0, 255)
  let purple = red.blend(blue, 0.5)
  
  // Verify the results
  inspect(red, content="RGBColor({ {r: 255, g: 0, b: 0 }})")
  inspect(purple, content="RGBColor({ {r: 128, g: 0, b: 128 }})")
}

## Documentation

- **[API Reference](API.md)**: Complete API documentation with examples
- **[Usage Examples](#usage-examples)**: Common usage patterns below
- **[Color Space Guide](API.md#color-space-information)**: Detailed information about each color space

## Usage Examples

### Creating Colors

test "creating colors in different color spaces" {
  // Create RGB colors (0-255 range)
  let red = @colors.rgb(255, 0, 0)
  let green = @colors.rgb(0, 255, 0)
  let blue = @colors.rgb(0, 0, 255)
  let white = @colors.rgb(255, 255, 255)
  
  inspect(red, content="RGBColor({ {r: 255, g: 0, b: 0 }})")
  inspect(white, content="RGBColor({ {r: 255, g: 255, b: 255 }})")
  
  // Create LinearRGB colors (0.0-1.0 range)
  let linear_red = @colors.linear_rgb(1.0, 0.0, 0.0)
  let linear_white = @colors.linear_rgb(1.0, 1.0, 1.0)
  
  inspect(linear_red, content="LinearRGBColor({ {r: 1, g: 0, b: 0 }})")
  
  // Create XYZ colors
  let xyz_white = @colors.xyz(95.047, 100.0, 108.883)  // D65 white point
  inspect(xyz_white, content="XYZColor({ {x: 95.047, y: 100, z: 108.883 }})")
  
  // Create LUV colors
  let luv_white = @colors.luv(100.0, 0.0, 0.0)  // L*=100 for white
  inspect(luv_white, content="LUVColor({ {l: 100, u: 0, v: 0 }})")
}

### Color Space Conversions

test "color space conversions" {
  let rgb_color = @colors.rgb(255, 128, 64)
  
  // Direct conversions (compile-time type checked)
  let linear_color = rgb_color.to_linear_rgb()
  let xyz_color = linear_color.to_xyz()
  let luv_color = xyz_color.to_luv()
  
  // Reverse conversions
  let back_to_xyz = luv_color.to_xyz()
  let back_to_linear = back_to_xyz.to_linear_rgb()
  let back_to_rgb = back_to_linear.to_rgb()
  
  // Should be very close to original
  match (rgb_color, back_to_rgb) {
    ({ r: r1, g: g1, b: b1 }, { r: r2, g: g2, b: b2 }) => {
      let close = (r1 - r2).abs() <= 2 && (g1 - g2).abs() <= 2 && (b1 - b2).abs() <= 2
      inspect(close, content="true")
    }
  }
}

### Universal Conversions

test "universal conversions with functions" {
  // Convert through different color spaces to RGB
  let rgb_original = @colors.rgb(200, 100, 50)
  let linear_color = @colors.linear_rgb(0.8, 0.4, 0.2)
  let xyz_color = @colors.xyz(30.0, 25.0, 15.0)
  let luv_color = @colors.luv(60.0, 40.0, 20.0)
  
  // All can be converted to RGB using trait methods
  let rgb1 = rgb_original.to_rgb()  // Identity
  let rgb2 = linear_color.to_rgb()  // LinearRGB -> RGB
  let rgb3 = xyz_color.to_rgb()     // XYZ -> LinearRGB -> RGB
  let rgb4 = luv_color.to_rgb()     // LUV -> XYZ -> LinearRGB -> RGB
  
  // Original should be unchanged
  inspect(rgb1, content="RGBColor({ {r: 200, g: 100, b: 50 }})")
  
  // Others should produce valid RGB colors
  match rgb2 {
    { r, g, b } => {
      let valid = r >= 0 && r <= 255 && g >= 0 && g <= 255 && b >= 0 && b <= 255
      inspect(valid, content="true")
    }
  }
}

### Color Blending

test "color blending" {
  let red = @colors.rgb(255, 0, 0)
  let blue = @colors.rgb(0, 0, 255)
  
  // RGB blending
  let purple = red.blend(blue, 0.5)
  let mostly_red = red.blend(blue, 0.25)
  
  inspect(purple, content="RGBColor({ {r: 128, g: 0, b: 128 }})")
  inspect(mostly_red, content="RGBColor({ {r: 192, g: 0, b: 64 }})")
  
  // Linear blending (more accurate for lighting)
  let linear_red = @colors.linear_rgb(1.0, 0.0, 0.0)
  let linear_blue = @colors.linear_rgb(0.0, 0.0, 1.0)
  let linear_purple = linear_red.blend(linear_blue, 0.5)
  
  inspect(linear_purple, content="LinearRGBColor({ {r: 0.5, g: 0, b: 0.5 }})")
}

### Gamma Correction

test "gamma correction demonstration" {
  // Demonstrate the difference between RGB and LinearRGB
  let rgb_mid = @colors.rgb(128, 128, 128)  // 50% in RGB space
  let linear_mid = rgb_mid.to_linear_rgb()
  
  // The linear value will be around 0.22, not 0.5!
  match linear_mid {
    { r, g, b } => {
      // Due to gamma correction, RGB 128 ≈ Linear 0.22
      let gamma_corrected = r < 0.3 && r > 0.1
      inspect(gamma_corrected, content="true")
    }
  }
  
  // Convert back to verify round-trip accuracy
  let back_to_rgb = linear_mid.to_rgb()
  inspect(back_to_rgb, content="RGBColor({ {r: 128, g: 128, b: 128 }})")
}

### Working with Standard Colors

test "standard colors" {
  // Primary colors
  let red = @colors.rgb(255, 0, 0)
  let green = @colors.rgb(0, 255, 0)
  let blue = @colors.rgb(0, 0, 255)
  
  // Secondary colors through blending
  let cyan = green.blend(blue, 0.5)
  let magenta = red.blend(blue, 0.5)
  let yellow = red.blend(green, 0.5)
  
  inspect(cyan, content="RGBColor({ {r: 0, g: 128, b: 128 }})")
  inspect(magenta, content="RGBColor({ {r: 128, g: 0, b: 128 }})")
  inspect(yellow, content="RGBColor({ {r: 128, g: 128, b: 0 }})")
  
  // Convert to XYZ for color science applications
  let red_xyz = @colors.rgb_to_xyz(red)
  match red_xyz {
    { x, y, z } => {
      // Should be approximately the red primary in XYZ
      let reasonable_red = x > 30.0 && x < 50.0 && y > 15.0 && y < 25.0 && z < 5.0
      inspect(reasonable_red, content="true")
    }
  }
}

### Function Chaining with Pipe Operator

test "chained color operations" {
  let original_color = @colors.rgb(200, 150, 100)
  
  // Chain multiple conversions using pipe operator
  let processed_color = original_color
    .to_linear_rgb()      // Convert to linear space
    .to_xyz()             // Convert to XYZ
    .to_luv()             // Convert to LUV for processing
    .to_xyz()             // Convert back to XYZ
    .to_linear_rgb()      // Convert back to linear
    .to_rgb()             // Convert back to RGB
  
  // Should be very close to original (within rounding error)
  match (original_color, processed_color) {
    ({ r: r1, g: g1, b: b1 }, { r: r2, g: g2, b: b2 }) => {
      let close = (r1 - r2).abs() <= 2 && (g1 - g2).abs() <= 2 && (b1 - b2).abs() <= 2
      inspect(close, content="true")
    }
  }
}

## Type System Design

This library uses separate types for each color space, providing several advantages:

### Compile-Time Type Safety
- **No runtime type checking** - all conversions are statically verified
- **No `abort()` calls** - impossible to call wrong conversion method
- **Clear API contracts** - function signatures show exactly what types are expected

### Performance Benefits
- **No enum overhead** - each struct contains only the data it needs
- **Better memory layout** - no discriminant field
- **Zero-cost abstractions** - compiler can optimize better with known types

### Function-Based API
- **Type-specific functions** - each color type has dedicated conversion functions
- **IDE support** - autocomplete shows only valid operations
- **Documentation clarity** - each function can have specific documentation

### Conversion Methods
The library provides two ways to convert between color spaces:

**Trait Methods (Recommended):**
- `.to_rgb()` - Convert any color to RGB
- `.to_linear_rgb()` - Convert any color to LinearRGB  
- `.to_xyz()` - Convert any color to XYZ
- `.to_luv()` - Convert any color to LUV
- `.blend(other, mix)` - Blend two colors of the same type

**Direct Functions:**
- `rgb_to_linear()` / `linear_to_rgb()` - RGB ↔ LinearRGB conversion
- `linear_to_xyz()` / `xyz_to_linear()` - LinearRGB ↔ XYZ conversion  
- `xyz_to_luv()` / `luv_to_xyz()` - XYZ ↔ LUV conversion
- `rgb_blend()` / `linear_blend()` - Color blending functions

The trait methods provide a cleaner API while the direct functions offer explicit control over the conversion pipeline.

### Trait-Based API

The library also provides a clean trait-based API that reduces the API surface and makes conversions more intuitive:

```moonbit nocheck
///|
test "trait-based conversions" {
  let rgb_color = @colors.rgb(255, 128, 64)
  let xyz_color = @colors.xyz(50.0, 60.0, 70.0)
  let luv_color = @colors.luv(75.0, 25.0, -15.0)

  // All types can convert to any other type using the same method names
  let _rgb_from_rgb = rgb_color.to_rgb() // Identity conversion
  let _rgb_from_xyz = xyz_color.to_rgb() // XYZ -> RGB
  let _rgb_from_luv = luv_color.to_rgb() // LUV -> RGB
  let _linear_from_rgb = rgb_color.to_linear_rgb()
  let _xyz_from_rgb = rgb_color.to_xyz()
  let _luv_from_rgb = rgb_color.to_luv()

  // Blending works with trait methods too
  let red = @colors.rgb(255, 0, 0)
  let blue = @colors.rgb(0, 0, 255)
  let _purple = red.blend(blue, 0.5)
}
```

**Available Traits:**
- `ToRGB` - Convert any color to RGB
- `ToLinearRGB` - Convert any color to Linear RGB
- `ToXYZ` - Convert any color to XYZ
- `ToLUV` - Convert any color to LUV
- `Blend` - Blend two colors of the same type

## Installation

Add this library to your MoonBit project:

```json
{
  "deps": {
    "bobzhang/colors": "*"
  }
}
```

## Testing

Run the comprehensive test suite:

```bash
moon test
```

The library includes comprehensive test cases covering all color spaces, conversions, edge cases, and known reference values.

## Contributing

Contributions are welcome! Please ensure all tests pass and add tests for new functionality.

## License

This project is licensed under the same terms as the original OCaml colors library.