///|
/// Main demo program for the colors library using separate types per color space
#coverage.skip
fn main {
  println("Colors Library Demo - Type-Safe Color Spaces")
  println("============================================")

  // Create some colors using different constructors
  println("\n1. Creating colors:")
  let red = @colors.rgb(255, 0, 0)
  let green = @colors.rgb(0, 255, 0)
  let blue = @colors.rgb(0, 0, 255)
  println("Red RGB: " + red.to_string())
  println("Green RGB: " + green.to_string())
  println("Blue RGB: " + blue.to_string())

  // Create linear RGB colors
  let linear_red = @colors.linear_rgb(1.0, 0.0, 0.0)
  let linear_green = @colors.linear_rgb(0.0, 1.0, 0.0)
  println("Linear Red: " + linear_red.to_string())
  println("Linear Green: " + linear_green.to_string())

  // Blend colors
  println("\n2. Blending colors:")
  let purple = red.blend(blue, 0.5)
  let yellow = red.blend(green, 0.5)
  println("Red + Blue (50/50): " + purple.to_string())
  println("Red + Green (50/50): " + yellow.to_string())

  // Linear blending (more accurate)
  let linear_purple = linear_red.blend(@colors.linear_rgb(0.0, 0.0, 1.0), 0.5)
  println("Linear Red + Blue (50/50): " + linear_purple.to_string())

  // XYZ and LUV blending (now supported!)
  let xyz_red_temp = @colors.xyz(41.24, 21.26, 1.93) // Approximate red in XYZ
  let xyz_blend = xyz_red_temp.blend(@colors.xyz(0.0, 0.0, 0.0), 0.5)
  println("XYZ Red + Black (50/50): " + xyz_blend.to_string())
  let luv_red_temp = @colors.luv(53.24, 175.05, 37.75) // Approximate red in LUV
  let luv_blend = luv_red_temp.blend(@colors.luv(0.0, 0.0, 0.0), 0.5)
  println("LUV Red + Black (50/50): " + luv_blend.to_string())

  // Convert between color spaces
  println("\n3. Color space conversions:")
  let red_linear = red.to_linear_rgb()
  let red_xyz = red_linear.to_xyz()
  let red_luv = red_xyz.to_luv()
  println("Red RGB: " + red.to_string())
  println("Red Linear: " + red_linear.to_string())
  println("Red XYZ: " + red_xyz.to_string())
  println("Red LUV: " + red_luv.to_string())

  // Universal conversions
  println("\n4. Universal conversions:")
  let xyz_color = @colors.xyz(41.24, 21.26, 1.93) // Approximate red in XYZ
  let luv_color = @colors.luv(53.24, 175.05, 37.75) // Approximate red in LUV
  println("XYZ color: " + xyz_color.to_string())
  println("XYZ to RGB: " + xyz_color.to_rgb().to_string())
  println("XYZ to Linear: " + xyz_color.to_linear_rgb().to_string())
  println("LUV color: " + luv_color.to_string())
  println("LUV to RGB: " + luv_color.to_rgb().to_string())
  println("LUV to XYZ: " + luv_color.to_xyz().to_string())

  // Demonstrate type safety - these are all compile-time checked!
  println("\n5. Type-safe chained conversions:")
  let final_color = red
    .to_linear_rgb() // RGB -> LinearRGB
    .to_xyz() // LinearRGB -> XYZ
    .to_luv() // XYZ -> LUV
    .to_xyz() // LUV -> XYZ
    .to_linear_rgb() // XYZ -> LinearRGB
    .to_rgb() // LinearRGB -> RGB
  println("Original: " + red.to_string())
  println("After round-trip: " + final_color.to_string())

  // Demonstrate gamma correction
  println("\n6. Gamma correction demonstration:")
  let rgb_mid = @colors.rgb(128, 128, 128) // 50% in sRGB
  let linear_mid = rgb_mid.to_linear_rgb()
  println("RGB middle gray: " + rgb_mid.to_string())
  println("Linear equivalent: " + linear_mid.to_string())
  match linear_mid {
    { lr, lg: _, lb: _ } =>
      println(
        "Linear value is ~" +
        lr.to_string() +
        ", not 0.5 due to gamma correction!",
      )
  }

  // Standard colors
  println("\n7. Standard colors:")
  let white = @colors.rgb(255, 255, 255)
  let black = @colors.rgb(0, 0, 0)
  let gray = white.blend(black, 0.5)
  println("White: " + white.to_string())
  println("Black: " + black.to_string())
  println("50% Gray: " + gray.to_string())

  // Convert white to all color spaces
  let white_linear = white.to_linear_rgb()
  let white_xyz = white_linear.to_xyz()
  let white_luv = white_xyz.to_luv()
  println("White in Linear: " + white_linear.to_string())
  println("White in XYZ: " + white_xyz.to_string())
  println("White in LUV: " + white_luv.to_string())
  println("\nDemo completed! All conversions are type-safe at compile time.")
}
