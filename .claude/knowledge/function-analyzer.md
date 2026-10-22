# Function analyzer: mathematical input

The active notebook is notebooks/function_analyzer.jl. User formula text must
never reach eval, include, dynamic function lookup, macros or code generation.
MathFormulas.jl in slider-server-environment parses text as data, validates the
complete tree, then interprets approved operations directly for both numeric
plotting and symbolic derivatives. The notebook includes this helper from the
same shared environment directory on Windows, Linux and Docker.

Allowed language:
- Variables x and b; constants pi, the Unicode pi symbol, and e.
- Finite decimal numbers with magnitude at most 1000000.
- Arithmetic +, -, *, /; literal integer exponents -8 through 8.
- Single-argument sin, cos, tan, exp, log and sqrt.
- Parentheses and implicit multiplication accepted by Julia's parser.

No assignments, properties, indexing, modules, arbitrary function calls, macros,
strings, commands, interpolation, tuples, arrays or blocks are accepted. Parsing
never evaluates code. Source is bounded to 256 UTF-8 bytes, trees to 64 nodes and
12 levels, and nested powers to two. Numeric calculations use floating point to
avoid silent integer overflow. Mathematical singularities/out-of-domain points
are omitted from plots. An entirely invalid real domain gets a clear message.
Rejected syntax shows an Invalid formula message; a later valid submission
recovers the graph. No fallback formula is silently substituted.

Tests:
- tools/test_math_formulas.jl --symbolic: 153 assertions across math values,
  programming/oversized-input rejection, no file-write side effect and symbolic
  derivatives checked against finite differences.
- tools/test_notebooks.jl: 56 assertions across all four notebooks, including real
  formula submissions to PlutoSliderServer, rejected code, real-domain handling,
  recovery and shared worker environment checks.
- tools/test_function_analyzer_browser.py: Chromium passes validation of actual
  text/Confirm controls, rejection messages and recovery of the plotted graph.

Actions and the Linux Docker build run the formula tests before notebook tests.
The new helper is copied by Docker's existing slider-server-environment/*.jl rule.
No package/manifest changes are needed. Existing container isolation requirements
still apply; this change removes the analyzer's user-text code execution path,
without claiming that PlutoSliderServer provides a general security sandbox.

Source reference: https://docs.julialang.org/en/v1/manual/metaprogramming/

Local server restarted with this version at http://127.0.0.1:1234/. Current runtime
log: .local/server-restricted.log; browser result: .local/browser-formulas.log.
