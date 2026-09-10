# Number guessing game Pluto notebook

Implement the existing notebooks/number_guessing_game.jl starter, preserving its credits.
References: notebooks/annika_gihan.jl (PlutoUI and HypertextLiteral),
notebooks/function_analyzer.jl (@bind fallback), and Pluto's JavaScript API documentation.

- Use PlutoUI for New game and HypertextLiteral for a keyboard-accessible 10 by 10 button grid.
- Generate a Julia secret in 1:100 once per round; allow six submitted guesses.
- Keep selection local until Check; submit cumulative history so reactive reruns do not consume turns.
- Evaluate guesses in Julia, show high/low hints and history, lock after win/loss, reset fully.
- Explain the Julia translation and include the supplied Python code as presentation material.
- Declare notebook packages; remove the starter's empty manifest so Pluto can resolve dependencies.
- Validate notebook structure, game edge cases and widget behavior where available; verify CRLF.

Validation limitation found during inspection: the julia command is an inaccessible Windows app alias.

## Outcome
Implementation complete. Node widget checks and notebook structure/CRLF checks passed.
Julia scoring execution and live Pluto rendering could not be tested because the Julia launcher is inaccessible.
Reusable implementation notes promoted to ../knowledge/number-guessing-game.md and INDEX.md.

## Fix Python disclosure cell
Replace unavailable PlutoUI.Details with native HTML details/summary through HypertextLiteral; retain the Python Markdown body. Verify no Details references remain and preserve CRLF and the current Pluto-generated environment.

## Scrollable Python presentation
Keep the complete existing Python example and render it in an expanded disclosure with a bounded, keyboard-focusable scroll area. Scope CSS to this example, preserve code whitespace, and allow horizontal and vertical scrolling. Verify the Python body is unchanged and touched files use CRLF.

## GitHub attachment image
Replace the reported failing Resource call in the introduction with an explicit HTML img via the existing HypertextLiteral import. Preserve 500px width with responsive sizing. Verify the replacement and CRLF; remote URL checks are blocked by network access.

Follow-up image update: move the existing inline image into the first empty cell below the introduction, using a standalone @htl expression so it can be rerun directly. Preserve URL and sizing.

## Repair reappearing image syntax error
The current file again contains the inline nested triple-quoted image expression. Remove it and populate the existing empty image cell with standalone @htl. Verify introduction delimiters, unique image URL, cell IDs/order, and CRLF.

## Working cloud image share
Replace the dead GitHub attachment URL with https://cloud.konomondo.at/s/FjWKQHCWdeewyWw/download in the standalone image cell. The direct endpoint was verified with a GET request: HTTP 200, image/jpeg. Preserve responsive sizing and CRLF.

## Restore full supplied Python listing
Replace the earlier shortened presentation with the complete user-supplied Python script, including the final invalid-input branches. Preserve original behavior and explain that range(1, 100) excludes 100; Julia already fixes that. Retain scrolling and add a visible end-of-script marker so completeness is clear. Check final branches and CRLF.
