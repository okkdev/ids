//// A module for generating UUIDs (Universally Unique Identifiers).
////
//// The module currently supports UUID versions:
//// - Version 4 (random)
////

import gleam/bit_string
import gleam/result
import gleam/erlang

@external(erlang, "crypto", "strong_rand_bytes")
fn crypto_strong_rand_bytes(n: Int) -> BitString

/// Generates a version 4 (random) UUID. The version 4 UUID produced
/// by this function is generated using a cryptographically secure 
/// random number generator.
///
/// ### Usage
/// ```gleam
/// import ids/uuid
///
/// let assert Ok(id) = uuid.generate_v4()
/// ```
///
pub fn generate_v4() -> Result(String, String) {
  let <<u0:size(48), _:size(4), u1:size(12), _:size(2), u2:size(62)>> =
    crypto_strong_rand_bytes(16)

  cast(<<u0:size(48), 4:size(4), u1:size(12), 2:size(2), u2:size(62)>>)
}

/// Generates a version 7 UUID. The version 7 UUID produced
/// by this function is generated using a cryptographically secure 
/// random number generator and includes a unix timestamp.
///
/// ### Usage
/// ```gleam
/// import ids/uuid
///
/// let assert Ok(id) = uuid.generate_v7()
/// ```
///
pub fn generate_v7() -> Result(String, String) {
  let timestamp = erlang.system_time(erlang.Millisecond)
  generate_v7_from_timestamp(timestamp)
}

/// Generates a version 7 UUID from a given unix timestamp in milliseconds.
pub fn generate_v7_from_timestamp(timestamp: Int) -> Result(String, String) {
  let <<_:size(48), _:size(4), a:size(12), _:size(2), b:size(62)>> =
    crypto_strong_rand_bytes(16)

  cast(<<timestamp:size(48), 7:size(4), a:size(12), 2:size(2), b:size(62)>>)
}

fn cast(raw_uuid: BitString) -> Result(String, String) {
  case raw_uuid {
    <<
      a1:size(4),
      a2:size(4),
      a3:size(4),
      a4:size(4),
      a5:size(4),
      a6:size(4),
      a7:size(4),
      a8:size(4),
      b1:size(4),
      b2:size(4),
      b3:size(4),
      b4:size(4),
      c1:size(4),
      c2:size(4),
      c3:size(4),
      c4:size(4),
      d1:size(4),
      d2:size(4),
      d3:size(4),
      d4:size(4),
      e1:size(4),
      e2:size(4),
      e3:size(4),
      e4:size(4),
      e5:size(4),
      e6:size(4),
      e7:size(4),
      e8:size(4),
      e9:size(4),
      e10:size(4),
      e11:size(4),
      e12:size(4),
    >> ->
      <<
        e(a1),
        e(a2),
        e(a3),
        e(a4),
        e(a5),
        e(a6),
        e(a7),
        e(a8),
        45,
        e(b1),
        e(b2),
        e(b3),
        e(b4),
        45,
        e(c1),
        e(c2),
        e(c3),
        e(c4),
        45,
        e(d1),
        e(d2),
        e(d3),
        e(d4),
        45,
        e(e1),
        e(e2),
        e(e3),
        e(e4),
        e(e5),
        e(e6),
        e(e7),
        e(e8),
        e(e9),
        e(e10),
        e(e11),
        e(e12),
      >>
      |> bit_string.to_string()
      |> result.replace_error(
        "Error: BitString could not be converted to String.",
      )

    _other -> Error("Error: Raw UUID is malformed.")
  }
}

fn e(n: Int) -> Int {
  case n {
    0 -> 48
    1 -> 49
    2 -> 50
    3 -> 51
    4 -> 52
    5 -> 53
    6 -> 54
    7 -> 55
    8 -> 56
    9 -> 57
    10 -> 97
    11 -> 98
    12 -> 99
    13 -> 100
    14 -> 101
    15 -> 102
  }
}
