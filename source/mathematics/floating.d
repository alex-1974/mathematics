/** **/
module mathematics.floating;

debug import std.stdio;
import std.traits;

/** Relative epsilon comparison for equality **/
bool equal (T) (T a, T b, T epsilon = T.epsilon) if (isFloatingPoint!T) {
  import std.math: fabs;
    return fabs(a - b) <= ( (fabs(a) < fabs(b) ? fabs(b) : fabs(a)) * epsilon);
}
/** ditto **/
bool equal (T) (T a, T b) if (isIntegral!T) {
  return a == b;
}
/** **/
unittest {
  assert (2.0.equal(2.0));
}
/** Definitely greater than **/
bool gt (T) (T a, T b, T epsilon = T.epsilon) if (isFloatingPoint!T) {
  import std.math: fabs;
    return (a - b) > ( (fabs(a) < fabs(b) ? fabs(b) : fabs(a)) * epsilon);
}
/** ditto **/
bool gt (T) (T a, T b) if (isIntegral!T) {
  return a > b;
}
/** **/
unittest {
  assert (5.0.gt(4.0));
}
/** Definitely less than **/
bool lt (T) (T a, T b, T epsilon = T.epsilon) if (isFloatingPoint!T) {
  import std.math: fabs;
    return (b - a) > ( (fabs(a) < fabs(b) ? fabs(b) : fabs(a)) * epsilon);
}
/** ditto **/
bool lt (T) (T a, T b) if (isIntegral!T) {
  return a < b;
}
/** **/
unittest {
  assert (0.0.lt(1.0));
}
/** Greater or equal than **/
bool gtE (T) (T a, T b) {
  return a.equal(b) || a.gt(b);
}
/** Less or equal than **/
bool ltE (T) (T a, T b) {
  return a.equal(b) || a.lt(b);
}
/** **/
T max (T) (T[] t...) if (isFloatingPoint!T) {
  T result = t[0];
  foreach (u; t[1..$]) if (u.gt(result)) result = u;
  return result;
}
/** **/
unittest {
  assert([0.0,4.0,1.0,2.0,3.0].max.equal(4.0));
}
T max (T) (T[] t...) if (isIntegral!T) {
  import std.algorithm: max;
  return max(t);
}
/** **/
T min (T) (T[] t...) if (isFloatingPoint!T) {
  T result = t[0];
  foreach (u; t[1..$]) if (u.lt(result)) result = u;
  return result;
}
/** **/
unittest {
  assert([0.0,4.0,1.0,2.0,3.0].min.equal(0.0));
}

/** Improved Kahan–Babuška algorithm by Neumaier,
    which also covers the case when the next term to be added
    is larger in absolute value than the running sum,
    effectively swapping the role of what is large and what is small.

    See: https://en.wikipedia.org/wiki/Kahan_summation_algorithm
**/
T sum (T) (T[] input...) if (isFloatingPoint!T) {
    import std.math: fabs;
    T s = 0.0;
    T c = 0.0;                       // A running compensation for lost low-order bits.
    foreach (i; 0..input.length) {
        T t = s + input[i];
        if (s.fabs >= input[i].fabs)
            c += ((s - t) + input[i]); // If sum is bigger, low-order digits of input[i] are lost.
        else
            c += ((input[i] - t) + s); // Else low-order digits of sum are lost.
        s = t;
    }
    return s + c;
}
unittest {
  assert([1.0, 0x1p+100,1.0, -0x1p+100].sum.equal(2.0));  // Kahan's algorithm can yield 0.0 (correct 2.0)
  assert( 1.0.sum(1.0e10).sum(-1.0e10).equal(1.0.sum(1.0e10.sum(-1.0e10))) );
}
