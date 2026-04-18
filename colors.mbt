///| Color type definitions and core functionality
/// A comprehensive MoonBit library for manipulating colors in different color spaces
/// with proper gamma correction and compile-time type safety.
///
/// This library provides separate types for each color space, ensuring type safety
/// and preventing runtime errors from incorrect color space usage.

///|
/// RGB color type representing standard sRGB with gamma encoding.
/// Values are in the range [0, 255] for each component.
///
/// # Example
/// ```moonbit nocheck
/// let red = @colors.rgb(255, 0, 0)
/// let _clamped = @colors.rgb(300, -50, 128)  // becomes RGBColor(255, 0, 128)
///
/// inspect(red, content="{r: 255, g: 0, b: 0}")
/// ```
#valtype
pub struct RGBColor {
  r : Int
  g : Int
  b : Int
} derive(Debug)

// Conversion traits for organizing the API

///|
pub trait ToRGB {
  to_rgb(Self) -> RGBColor
}

///|
pub trait ToLinearRGB {
  to_linear_rgb(Self) -> LinearRGBColor
}

///|
pub trait ToXYZ {
  to_xyz(Self) -> XYZColor
}

///|
pub trait ToLUV {
  to_luv(Self) -> LUVColor
}

///|
pub trait Blend {
  blend(Self, Self, Double) -> Self
}

// Trait implementations for RGBColor

///|
pub impl ToRGB for RGBColor with to_rgb(self) {
  self
}

///|
pub impl ToLinearRGB for RGBColor with to_linear_rgb(self) {
  rgb_to_linear(self)
}

///|
pub impl ToXYZ for RGBColor with to_xyz(self) {
  linear_to_xyz(rgb_to_linear(self))
}

///|
pub impl ToLUV for RGBColor with to_luv(self) {
  xyz_to_luv(linear_to_xyz(rgb_to_linear(self)))
}

///|
pub impl Blend for RGBColor with blend(self, other, mix) {
  rgb_blend(self, other, mix)
}

// Trait implementations for LinearRGBColor

///|
pub impl ToRGB for LinearRGBColor with to_rgb(self) {
  linear_to_rgb(self)
}

///|
pub impl ToLinearRGB for LinearRGBColor with to_linear_rgb(self) {
  self
}

///|
pub impl ToXYZ for LinearRGBColor with to_xyz(self) {
  linear_to_xyz(self)
}

///|
pub impl ToLUV for LinearRGBColor with to_luv(self) {
  xyz_to_luv(linear_to_xyz(self))
}

///|
pub impl Blend for LinearRGBColor with blend(self, other, mix) {
  linear_blend(self, other, mix)
}

///|
pub impl Blend for XYZColor with blend(self, other, mix) {
  xyz_blend(self, other, mix)
}

// Trait implementations for XYZColor

///|
pub impl ToRGB for XYZColor with to_rgb(self) {
  linear_to_rgb(xyz_to_linear(self))
}

///|
pub impl ToLinearRGB for XYZColor with to_linear_rgb(self) {
  xyz_to_linear(self)
}

///|
pub impl ToXYZ for XYZColor with to_xyz(self) {
  self
}

///|
pub impl ToLUV for XYZColor with to_luv(self) {
  xyz_to_luv(self)
}

// Trait implementations for LUVColor

///|
pub impl ToRGB for LUVColor with to_rgb(self) {
  linear_to_rgb(xyz_to_linear(luv_to_xyz(self)))
}

///|
pub impl ToLinearRGB for LUVColor with to_linear_rgb(self) {
  xyz_to_linear(luv_to_xyz(self))
}

///|
pub impl ToXYZ for LUVColor with to_xyz(self) {
  luv_to_xyz(self)
}

///|
pub impl ToLUV for LUVColor with to_luv(self) {
  self
}

///|
pub impl Blend for LUVColor with blend(self, other, mix) {
  luv_blend(self, other, mix)
}

///|
/// LinearRGB color type representing linear RGB without gamma encoding.
/// Values are in the range [0.0, 1.0] for each component.
/// Ideal for lighting calculations and physically accurate blending.
///
/// # Example
/// ```moonbit nocheck
/// let linear_red = @colors.linear_rgb(1.0, 0.0, 0.0)
/// let _clamped = @colors.linear_rgb(2.0, -0.5, 0.8)  // becomes LinearRGBColor(1.0, 0.0, 0.8)
///
/// inspect(linear_red, content="{lr: 1, lg: 0, lb: 0}")
/// ```
#valtype
pub struct LinearRGBColor {
  lr : Double
  lg : Double
  lb : Double
} derive(Debug)

///|
/// XYZ color type representing CIE XYZ color space.
/// Device-independent color space used as intermediate for conversions.
///
/// # Example
/// ```moonbit nocheck
/// let xyz_white = @colors.xyz(95.047, 100.0, 108.883)  // D65 white point
///
/// inspect(xyz_white, content="{x: 95.047, y: 100, z: 108.883}")
/// ```
#valtype
pub struct XYZColor {
  x : Double
  y : Double
  z : Double
} derive(Debug)

///|
/// LUV color type representing CIE LUV color space.
/// Perceptually uniform color space useful for color difference calculations.
///
/// # Example
/// ```moonbit nocheck
/// let luv_white = @colors.luv(100.0, 0.0, 0.0)  // L*=100 for white
///
/// inspect(luv_white, content="{l: 100, u: 0, v: 0}")
/// ```
#valtype
pub struct LUVColor {
  l : Double
  u : Double
  v : Double
} derive(Debug)

///|
/// Constants for color space conversions
let srgb_to_xyz_matrix : Array[Array[Double]] = [
  [0.4124564, 0.3575761, 0.1804375],
  [0.2126729, 0.7151522, 0.0721750],
  [0.0193339, 0.1191920, 0.9503041],
]

///|
let xyz_to_srgb_matrix : Array[Array[Double]] = [
  [3.2404542, -1.5371385, -0.4985314],
  [-0.9692660, 1.8760108, 0.0415560],
  [0.0556434, -0.2040259, 1.0572252],
]

// D65 white point for LUV conversions

///|
let d65_white_x : Double = 95.047

///|
let d65_white_y : Double = 100.0

///|
let d65_white_z : Double = 108.883

///|
/// Utility function to clamp a value between min and max
fn clamp(value : Double, min : Double, max : Double) -> Double {
  if value < min {
    min
  } else if value > max {
    max
  } else {
    value
  }
}

///|
/// sRGB gamma correction function
fn srgb_to_linear(value : Double) -> Double {
  if value <= 0.04045 {
    value / 12.92
  } else {
    @math.pow((value + 0.055) / 1.055, 2.4)
  }
}

///|
/// Inverse sRGB gamma correction function
fn linear_to_srgb(value : Double) -> Double {
  if value <= 0.0031308 {
    value * 12.92
  } else {
    1.055 * @math.pow(value, 1.0 / 2.4) - 0.055
  }
}

///|
/// Matrix multiplication helper for color space conversions
fn apply_matrix(
  matrix : Array[Array[Double]],
  x : Double,
  y : Double,
  z : Double,
) -> (Double, Double, Double) {
  let r = matrix[0][0] * x + matrix[0][1] * y + matrix[0][2] * z
  let g = matrix[1][0] * x + matrix[1][1] * y + matrix[1][2] * z
  let b = matrix[2][0] * x + matrix[2][1] * y + matrix[2][2] * z
  (r, g, b)
}

// ============================================================================
// RGB Color Constructor and Methods
// ============================================================================

///|
/// Create a new RGB color with automatic clamping to [0, 255].
///
/// # Parameters
/// - `r`: Red component (0-255)
/// - `g`: Green component (0-255)
/// - `b`: Blue component (0-255)
///
/// # Returns
/// A new `RGBColor` with clamped values
///
/// # Example
/// ```moonbit nocheck
/// let red = @colors.rgb(255, 0, 0)
/// let _clamped = @colors.rgb(300, -50, 128)  // becomes RGBColor(255, 0, 128)
///
/// inspect(red, content="{r: 255, g: 0, b: 0}")
/// ```
pub fn rgb(r : Int, g : Int, b : Int) -> RGBColor {
  let r_clamped = if r < 0 { 0 } else if r > 255 { 255 } else { r }
  let g_clamped = if g < 0 { 0 } else if g > 255 { 255 } else { g }
  let b_clamped = if b < 0 { 0 } else if b > 255 { 255 } else { b }
  { r: r_clamped, g: g_clamped, b: b_clamped }
}

///|
/// Convert RGB to LinearRGB with proper gamma correction.
///
/// This method applies the inverse sRGB gamma function to convert from
/// gamma-encoded RGB values to linear RGB values.
///
/// # Returns
/// A new `LinearRGBColor` in linear space
///
/// # Example
/// ```moonbit nocheck
/// let rgb_gray = @colors.rgb(128, 128, 128)
/// let _linear_gray = rgb_gray.to_linear_rgb()
/// // RGB(128, 128, 128) becomes approximately LinearRGB(0.22, 0.22, 0.22)
///
/// inspect(rgb_gray, content="{r: 128, g: 128, b: 128}")
/// ```
fn rgb_to_linear(color : RGBColor) -> LinearRGBColor {
  let r_norm = color.r.to_double() / 255.0
  let g_norm = color.g.to_double() / 255.0
  let b_norm = color.b.to_double() / 255.0
  linear_rgb(
    srgb_to_linear(r_norm),
    srgb_to_linear(g_norm),
    srgb_to_linear(b_norm),
  )
}

///|
/// Blend two RGB colors with a mixing ratio.
/// Also available as trait method: `color1.blend(color2, mix)`
///
/// # Parameters
/// - `color1`: The first RGB color
/// - `color2`: The second RGB color to blend with
/// - `mix`: Mixing ratio (0.0 = 100% color1, 1.0 = 100% color2)
///
/// # Returns
/// A new `RGBColor` representing the blended result
///
/// # Example
/// ```moonbit nocheck
/// let red = @colors.rgb(255, 0, 0)
/// let blue = @colors.rgb(0, 0, 255)
/// let purple = red.blend(blue, 0.5)
/// // Or using function: let purple = @colors.rgb_blend(red, blue, 0.5)
///
/// inspect(purple, content="{r: 128, g: 0, b: 128}")
/// ```
fn rgb_blend(color1 : RGBColor, color2 : RGBColor, mix : Double) -> RGBColor {
  let mix_clamped = clamp(mix, 0.0, 1.0)
  let r = (color1.r.to_double() * (1.0 - mix_clamped) +
  color2.r.to_double() * mix_clamped +
  0.5).to_int()
  let g = (color1.g.to_double() * (1.0 - mix_clamped) +
  color2.g.to_double() * mix_clamped +
  0.5).to_int()
  let b = (color1.b.to_double() * (1.0 - mix_clamped) +
  color2.b.to_double() * mix_clamped +
  0.5).to_int()
  { r, g, b }
}

// ============================================================================
// LinearRGB Color Constructor and Methods
// ============================================================================

///|
/// Create a new LinearRGB color with automatic clamping to [0.0, 1.0].
///
/// # Parameters
/// - `r`: Red component (0.0-1.0)
/// - `g`: Green component (0.0-1.0)
/// - `b`: Blue component (0.0-1.0)
///
/// # Returns
/// A new `LinearRGBColor` with clamped values
///
/// # Example
/// ```moonbit nocheck
/// let linear_red = @colors.linear_rgb(1.0, 0.0, 0.0)
/// let _clamped = @colors.linear_rgb(2.0, -0.5, 0.8)
///
/// inspect(linear_red, content="{lr: 1, lg: 0, lb: 0}")
/// ```
pub fn linear_rgb(r : Double, g : Double, b : Double) -> LinearRGBColor {
  { lr: clamp(r, 0.0, 1.0), lg: clamp(g, 0.0, 1.0), lb: clamp(b, 0.0, 1.0) }
}

///|
/// Convert LinearRGB to RGB with proper gamma correction.
///
/// # Returns
/// A new `RGBColor` with gamma encoding applied
fn linear_to_rgb(color : LinearRGBColor) -> RGBColor {
  let r_gamma = linear_to_srgb(color.lr)
  let g_gamma = linear_to_srgb(color.lg)
  let b_gamma = linear_to_srgb(color.lb)
  rgb(
    (r_gamma * 255.0 + 0.5).to_int(),
    (g_gamma * 255.0 + 0.5).to_int(),
    (b_gamma * 255.0 + 0.5).to_int(),
  )
}

///|
/// Convert LinearRGB to XYZ color space.
///
/// # Returns
/// A new `XYZColor` in CIE XYZ color space
fn linear_to_xyz(color : LinearRGBColor) -> XYZColor {
  let (x, y, z) = apply_matrix(srgb_to_xyz_matrix, color.lr, color.lg, color.lb)
  xyz(x, y, z)
}

///|
/// Blend two LinearRGB colors with a mixing ratio.
/// This is more accurate for lighting calculations.
/// Also available as trait method: `color1.blend(color2, mix)`
///
/// # Parameters
/// - `color1`: The first LinearRGB color
/// - `color2`: The second LinearRGB color to blend with
/// - `mix`: Mixing ratio (0.0 = 100% color1, 1.0 = 100% color2)
///
/// # Returns
/// A new `LinearRGBColor` representing the blended result
fn linear_blend(
  color1 : LinearRGBColor,
  color2 : LinearRGBColor,
  mix : Double,
) -> LinearRGBColor {
  let mix_clamped = clamp(mix, 0.0, 1.0)
  linear_rgb(
    color1.lr * (1.0 - mix_clamped) + color2.lr * mix_clamped,
    color1.lg * (1.0 - mix_clamped) + color2.lg * mix_clamped,
    color1.lb * (1.0 - mix_clamped) + color2.lb * mix_clamped,
  )
}

///|
/// Blend two XYZ colors using linear interpolation.
/// 
/// # Parameters
/// - `color1`: The first XYZ color to blend
/// - `color2`: The second XYZ color to blend with
/// - `mix`: Mixing ratio (0.0 = 100% color1, 1.0 = 100% color2)
///
/// # Returns
/// A new `XYZColor` representing the blended result
///
/// # Example
/// ```moonbit nocheck
/// let white = @colors.xyz(95.047, 100.0, 108.883)
/// let black = @colors.xyz(0.0, 0.0, 0.0)
/// let gray = white.blend(black, 0.5)
/// // Or using function: let gray = @colors.xyz_blend(white, black, 0.5)
///
/// inspect(gray, content="{x: 47.5235, y: 50, z: 54.4415}")
/// ```
fn xyz_blend(color1 : XYZColor, color2 : XYZColor, mix : Double) -> XYZColor {
  let mix_clamped = clamp(mix, 0.0, 1.0)
  xyz(
    color1.x * (1.0 - mix_clamped) + color2.x * mix_clamped,
    color1.y * (1.0 - mix_clamped) + color2.y * mix_clamped,
    color1.z * (1.0 - mix_clamped) + color2.z * mix_clamped,
  )
}

///|
/// Blend two LUV colors using linear interpolation.
/// 
/// # Parameters
/// - `color1`: The first LUV color to blend
/// - `color2`: The second LUV color to blend with
/// - `mix`: Mixing ratio (0.0 = 100% color1, 1.0 = 100% color2)
///
/// # Returns
/// A new `LUVColor` representing the blended result
///
/// # Example
/// ```moonbit nocheck
/// let white = @colors.luv(100.0, 0.0, 0.0)
/// let black = @colors.luv(0.0, 0.0, 0.0)
/// let gray = white.blend(black, 0.5)
/// // Or using function: let gray = @colors.luv_blend(white, black, 0.5)
///
/// inspect(gray, content="{l: 50, u: 0, v: 0}")
/// ```
fn luv_blend(color1 : LUVColor, color2 : LUVColor, mix : Double) -> LUVColor {
  let mix_clamped = clamp(mix, 0.0, 1.0)
  luv(
    color1.l * (1.0 - mix_clamped) + color2.l * mix_clamped,
    color1.u * (1.0 - mix_clamped) + color2.u * mix_clamped,
    color1.v * (1.0 - mix_clamped) + color2.v * mix_clamped,
  )
}

// ============================================================================
// XYZ Color Constructor and Methods
// ============================================================================

///|
/// Create a new XYZ color.
///
/// # Parameters
/// - `x`: X component
/// - `y`: Y component (luminance)
/// - `z`: Z component
///
/// # Returns
/// A new `XYZColor`
pub fn xyz(x : Double, y : Double, z : Double) -> XYZColor {
  { x, y, z }
}

///|
/// Convert XYZ to LinearRGB color space.
/// Values are clamped to [0.0, 1.0].
///
/// # Returns
/// A new `LinearRGBColor` with clamped values
fn xyz_to_linear(color : XYZColor) -> LinearRGBColor {
  let (r, g, b) = apply_matrix(xyz_to_srgb_matrix, color.x, color.y, color.z)
  linear_rgb(r, g, b)
}

///|
/// Convert XYZ to LUV color space using D65 white point.
///
/// # Returns
/// A new `LUVColor` in CIE LUV color space
fn xyz_to_luv(color : XYZColor) -> LUVColor {
  let u_prime = 4.0 * color.x / (color.x + 15.0 * color.y + 3.0 * color.z)
  let v_prime = 9.0 * color.y / (color.x + 15.0 * color.y + 3.0 * color.z)
  let u_prime_n = 4.0 *
    d65_white_x /
    (d65_white_x + 15.0 * d65_white_y + 3.0 * d65_white_z)
  let v_prime_n = 9.0 *
    d65_white_y /
    (d65_white_x + 15.0 * d65_white_y + 3.0 * d65_white_z)
  let y_ratio = color.y / d65_white_y
  let l = if y_ratio > 0.008856 {
    116.0 * @math.pow(y_ratio, 1.0 / 3.0) - 16.0
  } else {
    903.3 * y_ratio
  }
  let u = 13.0 * l * (u_prime - u_prime_n)
  let v = 13.0 * l * (v_prime - v_prime_n)
  luv(l, u, v)
}

// ============================================================================
// LUV Color Constructor and Methods
// ============================================================================

///|
/// Create a new LUV color.
///
/// # Parameters
/// - `l`: L* component (lightness, 0-100)
/// - `u`: u* component (chromaticity)
/// - `v`: v* component (chromaticity)
///
/// # Returns
/// A new `LUVColor`
pub fn luv(l : Double, u : Double, v : Double) -> LUVColor {
  { l, u, v }
}

///|
/// Convert LUV to XYZ color space using D65 white point.
///
/// # Returns
/// A new `XYZColor` in CIE XYZ color space
fn luv_to_xyz(color : LUVColor) -> XYZColor {
  let u_prime_n = 4.0 *
    d65_white_x /
    (d65_white_x + 15.0 * d65_white_y + 3.0 * d65_white_z)
  let v_prime_n = 9.0 *
    d65_white_y /
    (d65_white_x + 15.0 * d65_white_y + 3.0 * d65_white_z)
  let y = if color.l > 8.0 {
    d65_white_y * @math.pow((color.l + 16.0) / 116.0, 3.0)
  } else {
    d65_white_y * color.l / 903.3
  }
  let u_prime = color.u / (13.0 * color.l) + u_prime_n
  let v_prime = color.v / (13.0 * color.l) + v_prime_n
  let x = y * 9.0 * u_prime / (4.0 * v_prime)
  let z = y * (12.0 - 3.0 * u_prime - 20.0 * v_prime) / (4.0 * v_prime)
  xyz(x, y, z)
}

// ============================================================================
// Universal Conversion Functions
// ============================================================================

// Universal RGB conversion functions removed - use .to_rgb() trait method instead

// Universal LinearRGB conversion functions removed - use .to_linear_rgb() trait method instead

// Universal XYZ conversion functions removed - use .to_xyz() trait method instead

// Universal LUV conversion functions removed - use .to_luv() trait method instead

///|
pub impl Show for RGBColor with output(self, logger) {
  logger.write_string(@debug.render(self.to_repr(), max_depth=2147483647))
}

///|
pub impl Show for LinearRGBColor with output(self, logger) {
  logger.write_string(@debug.render(self.to_repr(), max_depth=2147483647))
}

///|
pub impl Show for XYZColor with output(self, logger) {
  logger.write_string(@debug.render(self.to_repr(), max_depth=2147483647))
}

///|
pub impl Show for LUVColor with output(self, logger) {
  logger.write_string(@debug.render(self.to_repr(), max_depth=2147483647))
}
