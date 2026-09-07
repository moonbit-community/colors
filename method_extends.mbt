///| Explicit method promotions for the color trait implementations.
///
/// Each color type implements `ToRGB`, `ToLinearRGB`, `ToXYZ`, `ToLUV`,
/// `Blend`, `Show` and derives `@debug.Debug`. Users of this library call
/// those trait methods in dot form (`color.to_rgb()`, `a.blend(b, 0.5)`,
/// `color.to_string()`), so the implementations are explicitly extended onto
/// each type instead of relying on the deprecated implicit promotion.

///|
pub extend RGBColor with ToRGB::{to_rgb}

///|
pub extend RGBColor with ToLinearRGB::{to_linear_rgb}

///|
pub extend RGBColor with ToXYZ::{to_xyz}

///|
pub extend RGBColor with ToLUV::{to_luv}

///|
pub extend RGBColor with Blend::{blend}

///|
pub extend RGBColor with Show::{to_string, output}

///|
pub extend RGBColor with @debug.Debug::{to_repr}

///|
pub extend LinearRGBColor with ToRGB::{to_rgb}

///|
pub extend LinearRGBColor with ToLinearRGB::{to_linear_rgb}

///|
pub extend LinearRGBColor with ToXYZ::{to_xyz}

///|
pub extend LinearRGBColor with ToLUV::{to_luv}

///|
pub extend LinearRGBColor with Blend::{blend}

///|
pub extend LinearRGBColor with Show::{to_string, output}

///|
pub extend LinearRGBColor with @debug.Debug::{to_repr}

///|
pub extend XYZColor with ToRGB::{to_rgb}

///|
pub extend XYZColor with ToLinearRGB::{to_linear_rgb}

///|
pub extend XYZColor with ToXYZ::{to_xyz}

///|
pub extend XYZColor with ToLUV::{to_luv}

///|
pub extend XYZColor with Blend::{blend}

///|
pub extend XYZColor with Show::{to_string, output}

///|
pub extend XYZColor with @debug.Debug::{to_repr}

///|
pub extend LUVColor with ToRGB::{to_rgb}

///|
pub extend LUVColor with ToLinearRGB::{to_linear_rgb}

///|
pub extend LUVColor with ToXYZ::{to_xyz}

///|
pub extend LUVColor with ToLUV::{to_luv}

///|
pub extend LUVColor with Blend::{blend}

///|
pub extend LUVColor with Show::{to_string, output}

///|
pub extend LUVColor with @debug.Debug::{to_repr}
