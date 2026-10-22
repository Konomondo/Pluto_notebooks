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


## Plot legend LaTeX (2026-10-22)

Use Symbolics.latexify(symbolic_formula; env=:raw) when embedding the converted
formula in a plot label. The default symbolic conversion wraps it in a full
begin/end equation environment, which GR cannot render inside the legend.
Construct the complete label with latexstring(prefix, equation); multiplying or
concatenating the pieces returns a plain String and loses the LaTeXString type.
The equation cell defines formula_label and the plot uses it directly.
The existing raw formula also feeds the standalone colored formula display.

Reproduced the old plain-string/equation-block label locally; the corrected plot
was inspected in Chromium for the default polynomial and changed sine/polynomial
formulas. Screenshots are .local/analyzer-latex-default.png,
.local/analyzer-latex-sine.png and .local/analyzer-latex-polynomial.png.
The local analyzer-only preview is http://127.0.0.1:17892/function_analyzer.html.
Integration tests check the actual plot series label remains a LaTeXString with
one pair of math delimiters and no begin/end environment, including after HTTP
formula changes and invalid-input recovery. Keep temporary test variables scoped
inside let: Pluto imports prior workspace globals, preventing later reassignment.

Official output environment documentation:
https://korsbo.github.io/Latexify.jl/stable/

Latest focused analyzer integration: 44/44 assertions pass, including the plot
label regressions. Chromium screenshots visually verified; no package changes.


## Optional simplification (2026-10-22)

Simplify formula is an unchecked PlutoUI CheckBox by default. The equation cell
latexifies formula_input.ast directly in raw mode when unchecked: term order,
fractions and repeated terms stay in the entered expression's parsed structure.
Whitespace and redundant parentheses follow mathematical typesetting rather than
literal character reproduction. Checked mode uses Symbolics.simplify on the
symbolic expression. Both the plotted label and standalone formula use this
selection. Numeric samples, point value and derivative calculations use the same
validated original formula regardless of the checkbox.

The checkbox is a real bound value, so include simplify_formula in co-dependent
slider payloads. HTTP regression tests toggle x+x to 2x and back, checking that
numeric y_val samples remain identical and the plot label keeps its LaTeX type.
Chromium checks the checkbox starts off, toggles both ways and updates the visible
formula. Screenshots: .local/analyzer-original-formula.png and
.local/analyzer-simplified-formula.png. The refreshed preview remains at port 17892.

Latest focused analyzer suite: 57/57 assertions pass with simplification toggles.
Chromium checkbox/graph/rejection/recovery test passes. Notebook now has 47 cells.
