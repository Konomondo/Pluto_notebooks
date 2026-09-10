# Interactive number guessing notebook

`notebooks/number_guessing_game.jl` uses PlutoUI.CounterButton for reset and a
HypertextLiteral custom @bind widget for the 10 by 10 grid. The notebook declares
its dependencies in PLUTO_PROJECT_TOML_CONTENTS; Pluto resolves the manifest.

The secret is generated only when the reset counter changes. Browser submissions
carry a round identifier and cumulative guess history. Julia's pure score_game
function enforces the inclusive 1:100 range, six turns, and stopping at the first
correct guess. Selecting a button does not submit. While Julia is evaluating,
the widget locks input; a round-specific result event releases or finishes it.
The window listener is removed through Pluto's invalidation promise.

Reference notebooks: annika_gihan.jl for PlutoUI/HypertextLiteral and
function_analyzer.jl for the exported @bind fallback.
API reference: https://plutojl.org/en/docs/javascript-api/

Validation: Node VM with a simulated DOM checked selection, endpoints 1 and 100,
double submission, stale acknowledgments, six-turn limit, win lock, fresh state,
and listener cleanup. Cell IDs/order and CRLF were checked.
Julia/Pluto runtime and visual browser checks remain unverified: the installed
julia command points to an inaccessible Windows app alias.

Compatibility fix: PlutoUI.Details is unavailable in the resolved PlutoUI 0.7.83.
Use native HTML details/summary via @htl with interpolated Markdown for disclosure content.

Python presentation: an expanded native disclosure contains a focusable scroll region capped at 32rem. Scoped CSS preserves preformatted lines and allows both scroll axes without truncating the source.

GitHub attachment images: use an explicit img via @htl for extensionless URLs when Resource does not render them as images. The introduction uses responsive 500px sizing. Remote reachability was not verified because network requests failed.

Keep the image @htl triple-quoted expression in its own cell. The attempted nested expression in md triple quotes produced an extra-tokens syntax error. On subsequent fixes, reread the file: the old inline expression has reappeared during active Pluto editing.

Current image source: https://cloud.konomondo.at/s/FjWKQHCWdeewyWw/download (GET verified HTTP 200, image/jpeg). Use this direct image endpoint, rather than the share preview page. It replaces the GitHub attachment which returned 404.

Python listing now preserves the full supplied original, including invalid-input elif/else branches. Do not condense these branches: the user wants to present the original code. The disclosure explains the original exclusive range and ends with an explicit end marker. Python break statements are display text and cannot truncate rendering.
