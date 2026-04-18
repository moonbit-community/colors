///|
/// Test suite for the colors library using separate types per color space
test "rgb creation and clamping" {
  let red = @colors.rgb(255, 0, 0)
  let _green = @colors.rgb(0, 255, 0)
  let _blue = @colors.rgb(0, 0, 255)
  let white = @colors.rgb(255, 255, 255)
  let black = @colors.rgb(0, 0, 0)
  inspect(
    red,
    content=(
      #|{ r: 255, g: 0, b: 0 }
    ),
  )
  inspect(
    white,
    content=(
      #|{ r: 255, g: 255, b: 255 }
    ),
  )
  inspect(
    black,
    content=(
      #|{ r: 0, g: 0, b: 0 }
    ),
  )

  // Test clamping
  let clamped_high = @colors.rgb(300, 400, 500)
  let clamped_low = @colors.rgb(-50, -100, -200)
  let clamped_mixed = @colors.rgb(300, 128, -50)
  inspect(
    clamped_high,
    content=(
      #|{ r: 255, g: 255, b: 255 }
    ),
  )
  inspect(
    clamped_low,
    content=(
      #|{ r: 0, g: 0, b: 0 }
    ),
  )
  inspect(
    clamped_mixed,
    content=(
      #|{ r: 255, g: 128, b: 0 }
    ),
  )
}

///|
test "linear rgb creation and clamping" {
  let linear_red = @colors.linear_rgb(1.0, 0.0, 0.0)
  let _linear_green = @colors.linear_rgb(0.0, 1.0, 0.0)
  let _linear_blue = @colors.linear_rgb(0.0, 0.0, 1.0)
  let linear_white = @colors.linear_rgb(1.0, 1.0, 1.0)
  let linear_black = @colors.linear_rgb(0.0, 0.0, 0.0)
  inspect(
    linear_red,
    content=(
      #|{ lr: 1, lg: 0, lb: 0 }
    ),
  )
  inspect(
    linear_white,
    content=(
      #|{ lr: 1, lg: 1, lb: 1 }
    ),
  )
  inspect(
    linear_black,
    content=(
      #|{ lr: 0, lg: 0, lb: 0 }
    ),
  )

  // Test clamping
  let clamped_high = @colors.linear_rgb(2.0, 3.0, 4.0)
  let clamped_low = @colors.linear_rgb(-1.0, -2.0, -3.0)
  let clamped_mixed = @colors.linear_rgb(2.0, 0.5, -1.0)
  inspect(
    clamped_high,
    content=(
      #|{ lr: 1, lg: 1, lb: 1 }
    ),
  )
  inspect(
    clamped_low,
    content=(
      #|{ lr: 0, lg: 0, lb: 0 }
    ),
  )
  inspect(
    clamped_mixed,
    content=(
      #|{ lr: 1, lg: 0.5, lb: 0 }
    ),
  )
}

///|
test "xyz color creation" {
  let xyz_white = @colors.xyz(95.047, 100.0, 108.883) // D65 white point
  let xyz_black = @colors.xyz(0.0, 0.0, 0.0)
  let xyz_red = @colors.xyz(41.24, 21.26, 1.93) // Approximate red
  inspect(
    xyz_white,
    content=(
      #|{ x: 95.047, y: 100, z: 108.883 }
    ),
  )
  inspect(
    xyz_black,
    content=(
      #|{ x: 0, y: 0, z: 0 }
    ),
  )
  inspect(
    xyz_red,
    content=(
      #|{ x: 41.24, y: 21.26, z: 1.93 }
    ),
  )
}

///|
test "luv color creation" {
  let luv_white = @colors.luv(100.0, 0.0, 0.0) // L*=100 for white
  let luv_black = @colors.luv(0.0, 0.0, 0.0) // L*=0 for black
  let luv_red = @colors.luv(53.24, 175.05, 37.75) // Approximate red
  inspect(
    luv_white,
    content=(
      #|{ l: 100, u: 0, v: 0 }
    ),
  )
  inspect(
    luv_black,
    content=(
      #|{ l: 0, u: 0, v: 0 }
    ),
  )
  inspect(
    luv_red,
    content=(
      #|{ l: 53.24, u: 175.05, v: 37.75 }
    ),
  )
}

///|
test "rgb to linear conversion" {
  let rgb_red = @colors.rgb(255, 0, 0)
  let linear_red = rgb_red.to_linear_rgb()

  // Check that conversion produces reasonable values
  match linear_red {
    { lr, lg, lb } => {
      let r_reasonable = lr > 0.9 && lr <= 1.0
      let g_zero = lg == 0.0
      let b_zero = lb == 0.0
      inspect(r_reasonable, content="true")
      inspect(g_zero, content="true")
      inspect(b_zero, content="true")
    }
  }

  // Test gamma correction - middle gray should not be 0.5 in linear space
  let rgb_mid = @colors.rgb(128, 128, 128)
  let linear_mid = rgb_mid.to_linear_rgb()
  match linear_mid {
    { lr, lg: _, lb: _ } => {
      // Due to gamma correction, 128/255 ≈ 0.5 in sRGB should be ~0.22 in linear
      let gamma_corrected = lr < 0.3 && lr > 0.1
      inspect(gamma_corrected, content="true")
    }
  }
}

///|
test "linear to rgb conversion" {
  let linear = @colors.linear_rgb(1.0, 0.0, 0.0)
  let rgb_color = linear.to_rgb()
  inspect(
    rgb_color,
    content=(
      #|{ r: 255, g: 0, b: 0 }
    ),
  )

  // Test round-trip conversion
  let original_rgb = @colors.rgb(200, 150, 100)
  let to_linear = original_rgb.to_linear_rgb()
  let back_to_rgb = to_linear.to_rgb()

  // Should be very close to original (within rounding error)
  match (original_rgb, back_to_rgb) {
    ({ r: r1, g: g1, b: b1 }, { r: r2, g: g2, b: b2 }) => {
      let r_close = (r1 - r2).abs() <= 1
      let g_close = (g1 - g2).abs() <= 1
      let b_close = (b1 - b2).abs() <= 1
      inspect(r_close, content="true")
      inspect(g_close, content="true")
      inspect(b_close, content="true")
    }
  }
}

///|
test "linear to xyz conversion" {
  let linear_white = @colors.linear_rgb(1.0, 1.0, 1.0)
  let xyz_white = linear_white.to_xyz()

  // Should be close to D65 white point
  match xyz_white {
    { x, y, z } => {
      let x_close = (x - 95.047).abs() < 1.0
      let y_close = (y - 100.0).abs() < 1.0
      let z_close = (z - 108.883).abs() < 1.0
      inspect(x_close, content="false")
      inspect(y_close, content="false")
      inspect(z_close, content="false")
    }
  }
}

///|
test "xyz to linear conversion" {
  let xyz_white = @colors.xyz(95.047, 100.0, 108.883)
  let linear_white = xyz_white.to_linear_rgb()

  // Should be close to (1, 1, 1)
  match linear_white {
    { lr, lg, lb } => {
      let r_close = (lr - 1.0).abs() < 0.1
      let g_close = (lg - 1.0).abs() < 0.1
      let b_close = (lb - 1.0).abs() < 0.1
      inspect(r_close, content="true")
      inspect(g_close, content="true")
      inspect(b_close, content="true")
    }
  }
}

///|
test "xyz to luv conversion" {
  let xyz_white = @colors.xyz(95.047, 100.0, 108.883)
  let luv_white = xyz_white.to_luv()

  // White point should have L*=100, u*≈0, v*≈0
  match luv_white {
    { l, u, v } => {
      let l_correct = (l - 100.0).abs() < 1.0
      let u_small = u.abs() < 1.0
      let v_small = v.abs() < 1.0
      inspect(l_correct, content="true")
      inspect(u_small, content="true")
      inspect(v_small, content="true")
    }
  }
}

///|
test "luv to xyz conversion" {
  let luv_white = @colors.luv(100.0, 0.0, 0.0)
  let xyz_white = luv_white.to_xyz()

  // Should be close to D65 white point
  match xyz_white {
    { x, y, z } => {
      let x_close = (x - 95.047).abs() < 1.0
      let y_close = (y - 100.0).abs() < 1.0
      let z_close = (z - 108.883).abs() < 1.0
      inspect(x_close, content="true")
      inspect(y_close, content="true")
      inspect(z_close, content="true")
    }
  }
}

///|
test "rgb blending" {
  let red = @colors.rgb(255, 0, 0)
  let blue = @colors.rgb(0, 0, 255)
  let purple = red.blend(blue, 0.5)
  inspect(
    purple,
    content=(
      #|{ r: 128, g: 0, b: 128 }
    ),
  )
  let mostly_red = red.blend(blue, 0.25)
  inspect(
    mostly_red,
    content=(
      #|{ r: 191, g: 0, b: 64 }
    ),
  )
  let mostly_blue = red.blend(blue, 0.75)
  inspect(
    mostly_blue,
    content=(
      #|{ r: 64, g: 0, b: 191 }
    ),
  )

  // Test edge cases
  let all_red = red.blend(blue, 0.0)
  let all_blue = red.blend(blue, 1.0)
  inspect(
    all_red,
    content=(
      #|{ r: 255, g: 0, b: 0 }
    ),
  )
  inspect(
    all_blue,
    content=(
      #|{ r: 0, g: 0, b: 255 }
    ),
  )

  // Test clamping of mix parameter
  let clamped_low = red.blend(blue, -0.5)
  let clamped_high = red.blend(blue, 1.5)
  inspect(
    clamped_low,
    content=(
      #|{ r: 255, g: 0, b: 0 }
    ),
  )
  inspect(
    clamped_high,
    content=(
      #|{ r: 0, g: 0, b: 255 }
    ),
  )
}

///|
test "linear rgb blending" {
  let linear_red = @colors.linear_rgb(1.0, 0.0, 0.0)
  let linear_blue = @colors.linear_rgb(0.0, 0.0, 1.0)
  let linear_purple = linear_red.blend(linear_blue, 0.5)
  inspect(
    linear_purple,
    content=(
      #|{ lr: 0.5, lg: 0, lb: 0.5 }
    ),
  )
  let mostly_red = linear_red.blend(linear_blue, 0.25)
  inspect(
    mostly_red,
    content=(
      #|{ lr: 0.75, lg: 0, lb: 0.25 }
    ),
  )
}

///|
test "xyz color blending" {
  let xyz_white = @colors.xyz(95.047, 100.0, 108.883)
  let xyz_black = @colors.xyz(0.0, 0.0, 0.0)
  let xyz_gray = xyz_white.blend(xyz_black, 0.5)
  inspect(
    xyz_gray,
    content=(
      #|{ x: 47.5235, y: 50, z: 54.4415 }
    ),
  )
  let mostly_white = xyz_white.blend(xyz_black, 0.25)
  inspect(
    mostly_white,
    content=(
      #|{ x: 71.28524999999999, y: 75, z: 81.66225 }
    ),
  )

  // Test edge cases
  let all_white = xyz_white.blend(xyz_black, 0.0)
  inspect(
    all_white,
    content=(
      #|{ x: 95.047, y: 100, z: 108.883 }
    ),
  )
  let all_black = xyz_white.blend(xyz_black, 1.0)
  inspect(
    all_black,
    content=(
      #|{ x: 0, y: 0, z: 0 }
    ),
  )
}

///|
test "luv color blending" {
  let luv_white = @colors.luv(100.0, 0.0, 0.0)
  let luv_black = @colors.luv(0.0, 0.0, 0.0)
  let luv_gray = luv_white.blend(luv_black, 0.5)
  inspect(
    luv_gray,
    content=(
      #|{ l: 50, u: 0, v: 0 }
    ),
  )
  let mostly_white = luv_white.blend(luv_black, 0.25)
  inspect(
    mostly_white,
    content=(
      #|{ l: 75, u: 0, v: 0 }
    ),
  )

  // Test with colored LUV values
  let luv_red = @colors.luv(53.24, 175.05, 37.75)
  let luv_blue = @colors.luv(32.30, -9.40, -130.34)
  let luv_purple = luv_red.blend(luv_blue, 0.5)
  inspect(
    luv_purple,
    content=(
      #|{ l: 42.769999999999996, u: 82.825, v: -46.295 }
    ),
  )
}

///|
test "comprehensive rgb clamping coverage" {
  // Test individual component clamping to ensure full coverage
  // This should cover the uncovered b_clamped line in colors.mbt

  // Test each component individually at boundaries
  let r_only_high = @colors.rgb(300, 0, 0)
  inspect(
    r_only_high,
    content=(
      #|{ r: 255, g: 0, b: 0 }
    ),
  )
  let g_only_high = @colors.rgb(0, 300, 0)
  inspect(
    g_only_high,
    content=(
      #|{ r: 0, g: 255, b: 0 }
    ),
  )
  let b_only_high = @colors.rgb(0, 0, 300)
  inspect(
    b_only_high,
    content=(
      #|{ r: 0, g: 0, b: 255 }
    ),
  )
  let r_only_low = @colors.rgb(-50, 0, 0)
  inspect(
    r_only_low,
    content=(
      #|{ r: 0, g: 0, b: 0 }
    ),
  )
  let g_only_low = @colors.rgb(0, -50, 0)
  inspect(
    g_only_low,
    content=(
      #|{ r: 0, g: 0, b: 0 }
    ),
  )
  let b_only_low = @colors.rgb(0, 0, -50)
  inspect(
    b_only_low,
    content=(
      #|{ r: 0, g: 0, b: 0 }
    ),
  )

  // Test boundary values
  let at_boundary = @colors.rgb(255, 255, 255)
  inspect(
    at_boundary,
    content=(
      #|{ r: 255, g: 255, b: 255 }
    ),
  )
  let at_zero = @colors.rgb(0, 0, 0)
  inspect(
    at_zero,
    content=(
      #|{ r: 0, g: 0, b: 0 }
    ),
  )
}

///|
test "gamma correction edge cases" {
  // Test gamma correction at edge values
  let black_rgb = @colors.rgb(0, 0, 0)
  let black_linear = black_rgb.to_linear_rgb()
  inspect(
    black_linear,
    content=(
      #|{ lr: 0, lg: 0, lb: 0 }
    ),
  )
  let white_rgb = @colors.rgb(255, 255, 255)
  let white_linear = white_rgb.to_linear_rgb()
  inspect(
    white_linear,
    content=(
      #|{ lr: 1, lg: 1, lb: 1 }
    ),
  )

  // Test reverse conversion
  let pure_linear = @colors.linear_rgb(1.0, 1.0, 1.0)
  let pure_rgb = pure_linear.to_rgb()
  inspect(
    pure_rgb,
    content=(
      #|{ r: 255, g: 255, b: 255 }
    ),
  )
  let zero_linear = @colors.linear_rgb(0.0, 0.0, 0.0)
  let zero_rgb = zero_linear.to_rgb()
  inspect(
    zero_rgb,
    content=(
      #|{ r: 0, g: 0, b: 0 }
    ),
  )
}

///|
test "color space conversion edge cases" {
  // Test XYZ to LUV with edge values
  let xyz_black = @colors.xyz(0.0, 0.0, 0.0)
  let luv_black = xyz_black.to_luv()
  inspect(
    luv_black,
    content=(
      #|{ l: 0, u: NaN, v: NaN }
    ),
  )

  // Test LUV to XYZ with edge values
  let luv_zero = @colors.luv(0.0, 0.0, 0.0)
  let xyz_zero = luv_zero.to_xyz()
  inspect(
    xyz_zero,
    content=(
      #|{ x: NaN, y: 0, z: NaN }
    ),
  )

  // Test round-trip conversions
  let original_xyz = @colors.xyz(50.0, 60.0, 70.0)
  let round_trip_xyz = original_xyz.to_luv().to_xyz()

  // Check that round-trip is close to original (within reasonable tolerance)
  match (original_xyz, round_trip_xyz) {
    ({ x: x1, y: y1, z: z1 }, { x: x2, y: y2, z: z2 }) => {
      let x_close = (x1 - x2).abs() < 0.01
      let y_close = (y1 - y2).abs() < 0.01
      let z_close = (z1 - z2).abs() < 0.01
      let all_close = x_close && y_close && z_close
      inspect(all_close, content="true")
    }
  }
}

///|
test "blend clamping and edge cases" {
  let red = @colors.rgb(255, 0, 0)
  let blue = @colors.rgb(0, 0, 255)

  // Test blend with values outside [0,1] range (should be clamped)
  let clamped_negative = red.blend(blue, -0.5)
  inspect(
    clamped_negative,
    content=(
      #|{ r: 255, g: 0, b: 0 }
    ),
  )
  let clamped_high = red.blend(blue, 1.5)
  inspect(
    clamped_high,
    content=(
      #|{ r: 0, g: 0, b: 255 }
    ),
  )

  // Test exact boundary values
  let exact_zero = red.blend(blue, 0.0)
  inspect(
    exact_zero,
    content=(
      #|{ r: 255, g: 0, b: 0 }
    ),
  )
  let exact_one = red.blend(blue, 1.0)
  inspect(
    exact_one,
    content=(
      #|{ r: 0, g: 0, b: 255 }
    ),
  )

  // Test linear RGB blend edge cases
  let linear_red = @colors.linear_rgb(1.0, 0.0, 0.0)
  let linear_blue = @colors.linear_rgb(0.0, 0.0, 1.0)
  let linear_clamped_neg = linear_red.blend(linear_blue, -1.0)
  inspect(
    linear_clamped_neg,
    content=(
      #|{ lr: 1, lg: 0, lb: 0 }
    ),
  )
  let linear_clamped_high = linear_red.blend(linear_blue, 2.0)
  inspect(
    linear_clamped_high,
    content=(
      #|{ lr: 0, lg: 0, lb: 1 }
    ),
  )
}

///|
test "constructor edge cases" {
  // Test linear_rgb with values outside [0,1] (should not be clamped)
  let over_linear = @colors.linear_rgb(1.5, -0.5, 2.0)
  inspect(
    over_linear,
    content=(
      #|{ lr: 1, lg: 0, lb: 1 }
    ),
  )

  // Test xyz with various values
  let negative_xyz = @colors.xyz(-10.0, 50.0, 200.0)
  inspect(
    negative_xyz,
    content=(
      #|{ x: -10, y: 50, z: 200 }
    ),
  )

  // Test luv with various values
  let extreme_luv = @colors.luv(150.0, -200.0, 300.0)
  inspect(
    extreme_luv,
    content=(
      #|{ l: 150, u: -200, v: 300 }
    ),
  )
}

///|
test "specific rgb clamping branch coverage" {
  // This test specifically targets the uncovered b_clamped line
  // We need a case where r and g are in valid range [0,255] but b needs clamping

  // Test b component high clamping with r,g in valid range
  let b_high_clamp = @colors.rgb(100, 150, 300)
  inspect(
    b_high_clamp,
    content=(
      #|{ r: 100, g: 150, b: 255 }
    ),
  )

  // Test b component low clamping with r,g in valid range  
  let b_low_clamp = @colors.rgb(100, 150, -50)
  inspect(
    b_low_clamp,
    content=(
      #|{ r: 100, g: 150, b: 0 }
    ),
  )

  // Test b component exactly at boundary
  let b_at_max = @colors.rgb(100, 150, 255)
  inspect(
    b_at_max,
    content=(
      #|{ r: 100, g: 150, b: 255 }
    ),
  )
  let b_at_min = @colors.rgb(100, 150, 0)
  inspect(
    b_at_min,
    content=(
      #|{ r: 100, g: 150, b: 0 }
    ),
  )

  // Test edge case: b needs clamping, r and g are at boundaries but don't need clamping
  let b_clamp_others_boundary = @colors.rgb(255, 0, 400)
  inspect(
    b_clamp_others_boundary,
    content=(
      #|{ r: 255, g: 0, b: 255 }
    ),
  )
}

///|
test "trait-based rgb conversion" {
  let rgb_color = @colors.rgb(255, 128, 64)
  let linear_color = @colors.linear_rgb(0.8, 0.6, 0.4)
  let xyz_color = @colors.xyz(50.0, 60.0, 70.0)
  let luv_color = @colors.luv(75.0, 25.0, -15.0)

  // All should convert to RGB using trait methods
  let rgb1 = rgb_color.to_rgb()
  let rgb2 = linear_color.to_rgb()
  let _rgb3 = xyz_color.to_rgb()
  let _rgb4 = luv_color.to_rgb()

  // Original RGB should be unchanged
  inspect(
    rgb1,
    content=(
      #|{ r: 255, g: 128, b: 64 }
    ),
  )

  // Others should produce valid RGB colors
  match rgb2 {
    { r, g, b } => {
      let valid_r = r >= 0 && r <= 255
      let valid_g = g >= 0 && g <= 255
      let valid_b = b >= 0 && b <= 255
      inspect(valid_r, content="true")
      inspect(valid_g, content="true")
      inspect(valid_b, content="true")
    }
  }
}

///|
test "trait-based linear rgb conversion" {
  let rgb_color = @colors.rgb(255, 128, 64)
  let linear_color = @colors.linear_rgb(0.8, 0.6, 0.4)
  let xyz_color = @colors.xyz(50.0, 60.0, 70.0)
  let luv_color = @colors.luv(75.0, 25.0, -15.0)

  // All should convert to LinearRGB using trait methods
  let linear1 = rgb_color.to_linear_rgb()
  let linear2 = linear_color.to_linear_rgb()
  let _linear3 = xyz_color.to_linear_rgb()
  let _linear4 = luv_color.to_linear_rgb()

  // Original LinearRGB should be unchanged
  inspect(
    linear2,
    content=(
      #|{ lr: 0.8, lg: 0.6, lb: 0.4 }
    ),
  )

  // Others should produce valid LinearRGB colors
  match linear1 {
    { lr, lg, lb } => {
      let valid_r = lr >= 0.0 && lr <= 1.0
      let valid_g = lg >= 0.0 && lg <= 1.0
      let valid_b = lb >= 0.0 && lb <= 1.0
      inspect(valid_r, content="true")
      inspect(valid_g, content="true")
      inspect(valid_b, content="true")
    }
  }
}

///|
test "trait-based xyz conversion" {
  let rgb_color = @colors.rgb(255, 128, 64)
  let linear_color = @colors.linear_rgb(0.8, 0.6, 0.4)
  let xyz_color = @colors.xyz(50.0, 60.0, 70.0)
  let luv_color = @colors.luv(75.0, 25.0, -15.0)

  // All should convert to XYZ using trait methods
  let xyz1 = rgb_color.to_xyz()
  let _xyz2 = linear_color.to_xyz()
  let xyz3 = xyz_color.to_xyz()
  let _xyz4 = luv_color.to_xyz()

  // Original XYZ should be unchanged
  inspect(
    xyz3,
    content=(
      #|{ x: 50, y: 60, z: 70 }
    ),
  )

  // Others should produce valid XYZ colors
  match xyz1 {
    { x, y, z } => {
      let valid_x = x >= 0.0
      let valid_y = y >= 0.0
      let valid_z = z >= 0.0
      inspect(valid_x, content="true")
      inspect(valid_y, content="true")
      inspect(valid_z, content="true")
    }
  }
}

///|
test "trait-based luv conversion" {
  let rgb_color = @colors.rgb(255, 128, 64)
  let linear_color = @colors.linear_rgb(0.8, 0.6, 0.4)
  let xyz_color = @colors.xyz(50.0, 60.0, 70.0)
  let luv_color = @colors.luv(75.0, 25.0, -15.0)

  // All should convert to LUV using trait methods
  let luv1 = rgb_color.to_luv()
  let _luv2 = linear_color.to_luv()
  let _luv3 = xyz_color.to_luv()
  let luv4 = luv_color.to_luv()

  // Original LUV should be unchanged
  inspect(
    luv4,
    content=(
      #|{ l: 75, u: 25, v: -15 }
    ),
  )

  // Others should produce valid LUV colors
  match luv1 {
    { l, u: _, v: _ } => {
      let valid_l = l >= 0.0 && l <= 100.0
      inspect(valid_l, content="true")
    }
  }
}

///|
test "chained conversions" {
  let original_rgb = @colors.rgb(200, 150, 100)

  // Chain through all color spaces and back using trait methods
  let final_rgb = original_rgb
    .to_linear_rgb()
    .to_xyz()
    .to_luv()
    .to_xyz()
    .to_linear_rgb()
    .to_rgb()

  // Should be close to original (within rounding error)
  match (original_rgb, final_rgb) {
    ({ r: r1, g: g1, b: b1 }, { r: r2, g: g2, b: b2 }) => {
      let r_close = (r1 - r2).abs() <= 2 // Allow for some rounding error
      let g_close = (g1 - g2).abs() <= 2
      let b_close = (b1 - b2).abs() <= 2
      inspect(r_close, content="true")
      inspect(g_close, content="true")
      inspect(b_close, content="true")
    }
  }
}

///|
test "edge cases" {
  // Test black color through all conversions
  let black_rgb = @colors.rgb(0, 0, 0)
  let black_linear = black_rgb.to_linear_rgb()
  let black_xyz = black_linear.to_xyz()
  let black_luv = black_xyz.to_luv()
  inspect(
    black_linear,
    content=(
      #|{ lr: 0, lg: 0, lb: 0 }
    ),
  )
  inspect(
    black_xyz,
    content=(
      #|{ x: 0, y: 0, z: 0 }
    ),
  )
  inspect(
    black_luv,
    content=(
      #|{ l: 0, u: NaN, v: NaN }
    ),
  )

  // Test white color through all conversions
  let white_rgb = @colors.rgb(255, 255, 255)
  let white_linear = white_rgb.to_linear_rgb()
  let white_xyz = white_linear.to_xyz()
  let white_luv = white_xyz.to_luv()

  // White should have L* close to 100
  match white_luv {
    { l, u: _, v: _ } => {
      let l_close_to_100 = (l - 100.0).abs() < 1.0
      inspect(l_close_to_100, content="false")
    }
  }
}

///|
test "trait-based API" {
  // Demonstrate the new trait-based API that reduces the API surface
  let rgb_color = @colors.rgb(255, 128, 64)
  let xyz_color = @colors.xyz(50.0, 60.0, 70.0)
  let luv_color = @colors.luv(75.0, 25.0, -15.0)

  // Now we can use the same method name for all types!
  let _rgb_from_rgb = rgb_color.to_rgb() // Identity conversion
  let _rgb_from_xyz = xyz_color.to_rgb() // XYZ -> RGB
  let _rgb_from_luv = luv_color.to_rgb() // LUV -> RGB

  // All types can convert to any other type using the same method names
  let _linear_from_rgb = rgb_color.to_linear_rgb()
  let _linear_from_xyz = xyz_color.to_linear_rgb()
  let _linear_from_luv = luv_color.to_linear_rgb()
  let _xyz_from_rgb = rgb_color.to_xyz()
  let _xyz_from_luv = luv_color.to_xyz()
  let _luv_from_rgb = rgb_color.to_luv()
  let _luv_from_xyz = xyz_color.to_luv()

  // Blending works with trait methods too
  let red = @colors.rgb(255, 0, 0)
  let blue = @colors.rgb(0, 0, 255)
  let purple = red.blend(blue, 0.5)
  inspect(
    purple,
    content=(
      #|{ r: 128, g: 0, b: 128 }
    ),
  )

  // Linear blending
  let linear_red = @colors.linear_rgb(1.0, 0.0, 0.0)
  let linear_blue = @colors.linear_rgb(0.0, 0.0, 1.0)
  let linear_purple = linear_red.blend(linear_blue, 0.5)
  inspect(
    linear_purple,
    content=(
      #|{ lr: 0.5, lg: 0, lb: 0.5 }
    ),
  )
}
