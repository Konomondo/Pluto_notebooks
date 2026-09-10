### A Pluto.jl notebook ###
# v0.20.28

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    #! format: off
    return quote
        local iv = try Base.loaded_modules[Base.PkgId(Base.UUID("6e696c72-6542-2067-7265-42206c756150"), "AbstractPlutoDingetjes")].Bonds.initial_value catch; b -> missing; end
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : iv(el)
        el
    end
    #! format: on
end

# ╔═╡ 2d5de768-13e9-4cca-bf55-70a6b8ff10f3
begin
    using PlutoUI
    using HypertextLiteral
    using Random
end

# ╔═╡ aec26320-ad06-11f1-9088-ff519a790689
md"""
# Number guessing game
by [Luis Schwarzl](https://www.linkedin.com/in/luis-schwarzl/)


powered by [edventureStudios](https://konomondo.com)

Welcome! Find the secret number between **1 and 100** in **six turns**.
Choose a number below, then press **Check**. Changing your selection is free.
After each guess, you will learn whether it was too low or too high.
"""

# ╔═╡ d2d5447e-5e7d-4609-98aa-cc0f102dc3db
@bind new_game PlutoUI.CounterButton("New game")

# ╔═╡ 39614601-d29e-4aff-a148-f2f3c7aecfe8
# A pure function: rerunning a cell cannot accidentally consume another turn.
function score_game(secret, guesses)
    history = NamedTuple{(:guess, :hint), Tuple{Int, String}}[]
    won = false
    for guess in guesses
        length(history) == 6 && break
        guess isa Integer && 1 <= guess <= 100 || continue
        hint = guess == secret ? "Correct!" : guess < secret ? "Too low" : "Too high"
        push!(history, (guess = Int(guess), hint = hint))
        if guess == secret
            won = true
            break
        end
    end
    turns = length(history)
    finished = won || turns == 6
    message = if won
        turns == 1 ? "Wow, you got lucky! You guessed the number instantly!" :
            "Congratulations! You won in $(turns) turns!"
    elseif finished
        "No guesses left. You lost! The secret number was $(secret)."
    elseif turns == 0
        "You have six attempts to guess the secret number."
    else
        "$(last(history).hint)! Try again."
    end
    (; history, turns, attempts_left = 6 - turns, won, finished, message)
end

# ╔═╡ 87fb556f-640d-443b-a476-e6a96f52922c
# Only New game changes this cell, so submitting a guess never changes the secret.
game_round = let
    new_game
    (id = string(rand(UInt128), base = 16), secret = rand(1:100))
end;

# ╔═╡ 7c5f6954-0910-4acc-a33a-907bbf5dd89d
@htl("""
<img src="https://cloud.konomondo.at/s/FjWKQHCWdeewyWw/download"
     alt="Number guessing game illustration"
     width="500" style="max-width: 50%; height: auto;">
""")

# ╔═╡ 55ea27fd-8fa4-4195-8cdd-4121dff17d83
md"""
## From Python to interactive Julia

Python's `random.randint(1, 100)` becomes Julia's `rand(1:100)`.
Instead of blocking with `input()` inside a `while` loop, Pluto's `@bind` sends
submitted guesses to Julia. The `score_game` function evaluates them and Pluto updates the feedback.
The browser handles selection and submission; Julia decides whether each guess is correct.

**Both endpoints count:** Python's `range(1, 100)` excludes 100. This version uses
Julia's inclusive `1:100`, so every button is valid. A correct sixth guess still wins.
Use **New game** to clear all guesses and draw another random secret (which may repeat).

The grid follows Pluto's [custom JavaScript widget API](https://plutojl.org/en/docs/javascript-api/).
Open this notebook in a running Pluto session for interactive Julia feedback.
"""

# ╔═╡ e59a28c7-3e1d-44e0-a012-adb445b20ef5
let
    python_code = Markdown.parse(raw"""

The complete original Python script is shown below, including all final branches.
Only the indentation has been normalized. In this original version, `range(1, 100)`
excludes 100; the interactive Julia game above accepts both 1 and 100.

```python
import random
print("\nWelcome to the number guessing game!")
print("You have six attempts to guess the secret number.")

attempts_left = 6
secret_number = random.randint(1,100)
while attempts_left > 0:
    user_input = (input("Guess a number between 0 and 100: "))

    try:
        guess = int(user_input)
    except ValueError:
        print("Type in a number between 1 and 100 to guess again!")
        print("You still have ", attempts_left, "attempts left.\n")
        continue

    attempts_left -= 1

    if guess == secret_number:
        if attempts_left == 5:
            print("\033[33mWow, you got lucky! You guessed the number instantly!\033[0m")
        else:
            print("\033[32mCongratulations! You won in",6 - attempts_left, "turns!\033[0m")
        break

    elif guess < secret_number and guess in range(1,100):
        print("Your guess was \033[31m too low!\033[0m")
        if attempts_left > 0:
            print("Try again!", attempts_left, "attempt(s) left.\n")
        else:
            print("No guesses left. You lost!")
            print("The secret number was\033[33m", secret_number,"!\033[0m")

    elif guess > secret_number and guess in range(1,100):
        print("Your guess was\033[34m too high!\033[0m")
        if attempts_left > 0:
            print("Try again!", attempts_left, "attempt(s) left.\n")
        elif attempts_left <= 0:
            print("No guesses left. You lost!")
            print("The secret number was\033[33m", secret_number,"\033[0m!")

    elif guess not in range(1,100):
        attempts_left += 1
        print("You didn't type in an eligible number. Try again!")
        print("You still have ", attempts_left, "attempt(s) left.\n")

    else:
        attempts_left += 1
        print("Type in a number between 1 and 100 to guess again!")
        print("You still have ", attempts_left, "attempts left.\n")
```

**End of Python script.**
""")
    @htl("""
    <details class="python-example" open>
        <summary>Complete original Python script</summary>
        <style>
            .python-example .python-scroll {
                max-height: 32rem;
                max-width: 100%;
                overflow: auto;
                scrollbar-gutter: stable;
            }
            .python-example .python-scroll pre {
                width: max-content;
                min-width: 100%;
                max-width: none;
                max-height: none;
                box-sizing: border-box;
                overflow: visible;
            }
            .python-example .python-scroll pre,
            .python-example .python-scroll pre code {
                white-space: pre;
                overflow-wrap: normal;
                word-break: normal;
            }
            .python-example .python-scroll:focus-visible {
                outline: 2px solid currentColor;
                outline-offset: 2px;
            }
        </style>
        <div class="python-scroll" tabindex="0" role="region" aria-label="Complete Python code; scroll vertically and horizontally">
            $(python_code)
        </div>
    </details>
    """)
end

# ╔═╡ c2306335-cca2-481f-9ef1-d5e6bac5ddab
function number_grid(round_id)
    @htl("""
    <div class="number-game">
        <style>
            .number-game { max-width: 620px; padding: 18px; border: 1px solid #8092a6;
                border-radius: 16px; background: #f5f8fc; color: #172b46; }
            .number-game .number-grid { display: grid; grid-template-columns: repeat(10, minmax(0, 1fr)); gap: 5px; }
            .number-game button { font: inherit; cursor: pointer; }
            .number-game .number-grid button { min-width: 0; min-height: 40px; padding: 4px 0;
                border: 1px solid #8297b0; border-radius: 7px; background: white; color: #172b46; }
            .number-game .number-grid button[aria-pressed="true"] { background: #244fb1; color: white; border-color: #244fb1; }
            .number-game button:focus-visible { outline: 3px solid #b65700; outline-offset: 2px; }
            .number-game button:disabled { opacity: 0.5; cursor: default; }
            .number-game .controls { display: flex; flex-wrap: wrap; align-items: center; gap: 16px; margin-top: 16px; }
            .number-game .check { background: #244fb1; color: white; border: 0; border-radius: 8px; padding: 10px 24px; }
            @media (max-width: 450px) { .number-game { padding: 8px; } .number-game .number-grid { gap: 3px; } }
        </style>
        <div class="number-grid" role="group" aria-label="Choose a number from 1 to 100">
            $([@htl("<button type='button' data-number=$(n) aria-pressed='false'>$(n)</button>") for n in 1:100])
        </div>
        <div class="controls">
            <button type="button" class="check" disabled>Check</button>
            <span class="selection" role="status">Choose a number.</span>
        </div>
        <script>
            const root = currentScript.parentElement;
            const buttons = Array.from(root.querySelectorAll('[data-number]'));
            const check = root.querySelector('.check');
            const selection = root.querySelector('.selection');
            const eventName = 'number-game-result-' + $(round_id);
            let selected = null;
            let pending = false;
            let finished = false;
            let guesses = [];
            root.value = {round_id: $(round_id), guesses: []};

            function refresh() {
                buttons.forEach(button => {
                    button.disabled = pending || finished;
                    button.setAttribute('aria-pressed', String(Number(button.dataset.number) === selected));
                });
                check.disabled = selected === null || pending || finished;
            }
            buttons.forEach(button => button.addEventListener('click', () => {
                if (pending || finished) return;
                selected = Number(button.dataset.number);
                selection.textContent = 'Selected: ' + selected;
                refresh();
            }));
            check.addEventListener('click', () => {
                if (selected === null || pending || finished || guesses.length >= 6) return;
                guesses = [...guesses, selected];
                pending = true;
                selection.textContent = 'Checking ' + selected + '...';
                refresh();
                root.value = {round_id: $(round_id), guesses: [...guesses]};
                root.dispatchEvent(new CustomEvent('input'));
            });
            const receiveResult = event => {
                if (event.detail.turns !== guesses.length) return;
                pending = false;
                finished = event.detail.finished;
                selected = null;
                selection.textContent = finished ? 'Game over. Press New game to play again.' : 'Choose a number.';
                refresh();
            };
            window.addEventListener(eventName, receiveResult);
            invalidation.then(() => window.removeEventListener(eventName, receiveResult));
        </script>
    </div>
    """)
end

# ╔═╡ d0375bcd-3fba-4dd7-b6b6-da114e7c8a1e
@bind submitted number_grid(game_round.id)

# ╔═╡ 3f25c2e3-1328-4db1-9533-5acaee5cdca4
result = let
    # A round identifier rejects any old browser input arriving during a reset.
    guesses = if submitted isa AbstractDict && get(submitted, "round_id", nothing) == game_round.id
        get(submitted, "guesses", [])
    else
        []
    end
    score_game(game_round.secret, guesses)
end;

# ╔═╡ c3c43c07-f611-4556-b5c6-2a2fac459a2c
let
    color = result.won ? "#17653a" : result.finished ? "#a12c24" : "#244fb1"
    @htl("""
    <section aria-label="Game feedback" aria-live="polite" aria-atomic="true">
        <p style=$("font-weight: bold; color: " * color)>$(result.message)</p>
        <p><strong>$(result.attempts_left)</strong> attempts left · $(result.turns) / 6 turns used</p>
        $(isempty(result.history) ? "" : @htl("""
            <table>
                <caption>Guess history</caption>
                <thead><tr><th scope="col">Turn</th><th scope="col">Guess</th><th scope="col">Answer</th></tr></thead>
                <tbody>$([@htl("<tr><td>$(i)</td><td>$(entry.guess)</td><td>$(entry.hint)</td></tr>") for (i, entry) in enumerate(result.history)])</tbody>
            </table>
        """))
        <script>
            window.dispatchEvent(new CustomEvent('number-game-result-' + $(game_round.id), {
                detail: {turns: $(result.turns), finished: $(result.finished)}
            }));
        </script>
    </section>
    """)
end

# ╔═╡ 00000000-0000-0000-0000-000000000001
PLUTO_PROJECT_TOML_CONTENTS = """
[deps]
HypertextLiteral = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
PlutoUI = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
Random = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"

[compat]
HypertextLiteral = "~1.0.0"
PlutoUI = "~0.7.83"
"""

# ╔═╡ 00000000-0000-0000-0000-000000000002
PLUTO_MANIFEST_TOML_CONTENTS = """
# This file is machine-generated - editing it directly is not advised

julia_version = "1.12.7"
manifest_format = "2.0"
project_hash = "97f7a84dde8b2f8b34c3ed81cbf09e0be817f63a"

[[deps.AbstractPlutoDingetjes]]
git-tree-sha1 = "e71ee7b4aa06b045259a7d6101e1cb45ad140bce"
uuid = "6e696c72-6542-2067-7265-42206c756150"
version = "1.4.1"

[[deps.ArgTools]]
uuid = "0dad84c5-d112-42e6-8d28-ef12dabb789f"
version = "1.1.2"

[[deps.Artifacts]]
uuid = "56f22d72-fd6d-98f1-02f0-08ddc0907c33"
version = "1.11.0"

[[deps.Base64]]
uuid = "2a0f44e3-6c83-55bd-87e4-b1978d98bd5f"
version = "1.11.0"

[[deps.ColorTypes]]
deps = ["FixedPointNumbers", "Random"]
git-tree-sha1 = "b10d0b65641d57b8b4d5e234446582de5047050d"
uuid = "3da002f7-5984-5a60-b8a6-cbb66c0b333f"
version = "0.11.5"

[[deps.CompilerSupportLibraries_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "e66e0078-7015-5450-92f7-15fbd957f2ae"
version = "1.3.1+2"

[[deps.Dates]]
deps = ["Printf"]
uuid = "ade2ca70-3891-5945-98fb-dc099432e06a"
version = "1.11.0"

[[deps.Downloads]]
deps = ["ArgTools", "FileWatching", "LibCURL", "NetworkOptions"]
uuid = "f43a241f-c20a-4ad4-852c-f6b1247861c6"
version = "1.7.0"

[[deps.FileWatching]]
uuid = "7b1f6079-737a-58dc-b8bc-7a2ca5c1b5ee"
version = "1.11.0"

[[deps.FixedPointNumbers]]
deps = ["Random", "Statistics"]
git-tree-sha1 = "59af96b98217c6ef4ae0dfe065ac7c20831d1a84"
uuid = "53c48c17-4a7d-5ca2-90c5-79b7896eea93"
version = "0.8.6"

[[deps.Hyperscript]]
deps = ["Test"]
git-tree-sha1 = "179267cfa5e712760cd43dcae385d7ea90cc25a4"
uuid = "47d2ed2b-36de-50cf-bf87-49c2cf4b8b91"
version = "0.0.5"

[[deps.HypertextLiteral]]
deps = ["Tricks"]
git-tree-sha1 = "d1a86724f81bcd184a38fd284ce183ec067d71a0"
uuid = "ac1192a8-f4b3-4bfe-ba22-af5b92cd3ab2"
version = "1.0.0"

[[deps.IOCapture]]
deps = ["Logging", "Random"]
git-tree-sha1 = "0ee181ec08df7d7c911901ea38baf16f755114dc"
uuid = "b5f81e59-6552-4d32-b1f0-c071b021bf89"
version = "1.0.0"

[[deps.InteractiveUtils]]
deps = ["Markdown"]
uuid = "b77e0a4c-d291-57a0-90e8-8db25a27a240"
version = "1.11.0"

[[deps.JuliaSyntaxHighlighting]]
deps = ["StyledStrings"]
uuid = "ac6e5ff7-fb65-4e79-a425-ec3bc9c03011"
version = "1.12.0"

[[deps.LibCURL]]
deps = ["LibCURL_jll", "MozillaCACerts_jll"]
uuid = "b27032c2-a3e7-50c8-80cd-2d36dbcbfd21"
version = "0.6.4"

[[deps.LibCURL_jll]]
deps = ["Artifacts", "LibSSH2_jll", "Libdl", "OpenSSL_jll", "Zlib_jll", "nghttp2_jll"]
uuid = "deac9b47-8bc7-5906-a0fe-35ac56dc84c0"
version = "8.15.0+0"

[[deps.LibSSH2_jll]]
deps = ["Artifacts", "Libdl", "OpenSSL_jll"]
uuid = "29816b5a-b9ab-546f-933c-edad1886dfa8"
version = "1.11.3+1"

[[deps.Libdl]]
uuid = "8f399da3-3557-5675-b5ff-fb832c97cbdb"
version = "1.11.0"

[[deps.LinearAlgebra]]
deps = ["Libdl", "OpenBLAS_jll", "libblastrampoline_jll"]
uuid = "37e2e46d-f89d-539d-b4ee-838fcccc9c8e"
version = "1.12.0"

[[deps.Logging]]
uuid = "56ddb016-857b-54e1-b83d-db4d58db5568"
version = "1.11.0"

[[deps.MIMEs]]
git-tree-sha1 = "c64d943587f7187e751162b3b84445bbbd79f691"
uuid = "6c6e2e6c-3030-632d-7369-2d6c69616d65"
version = "1.1.0"

[[deps.Markdown]]
deps = ["Base64", "JuliaSyntaxHighlighting", "StyledStrings"]
uuid = "d6f4376e-aef5-505a-96c1-9c027394607a"
version = "1.11.0"

[[deps.MozillaCACerts_jll]]
uuid = "14a3606d-f60d-562e-9121-12d972cd8159"
version = "2025.11.4"

[[deps.NetworkOptions]]
uuid = "ca575930-c2e3-43a9-ace4-1e988b2c1908"
version = "1.3.0"

[[deps.OpenBLAS_jll]]
deps = ["Artifacts", "CompilerSupportLibraries_jll", "Libdl"]
uuid = "4536629a-c528-5b80-bd46-f80d51c5b363"
version = "0.3.29+0"

[[deps.OpenSSL_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "458c3c95-2e84-50aa-8efc-19380b2a3a95"
version = "3.5.6+0"

[[deps.PlutoUI]]
deps = ["AbstractPlutoDingetjes", "Base64", "ColorTypes", "Dates", "Downloads", "FixedPointNumbers", "Hyperscript", "HypertextLiteral", "IOCapture", "InteractiveUtils", "Logging", "MIMEs", "Markdown", "Random", "Reexport", "URIs", "UUIDs"]
git-tree-sha1 = "e189d0623e7ce9c37389bac17e80aac3b0302e75"
uuid = "7f904dfe-b85e-4ff6-b463-dae2292396a8"
version = "0.7.83"

[[deps.Printf]]
deps = ["Unicode"]
uuid = "de0858da-6303-5e67-8744-51eddeeeb8d7"
version = "1.11.0"

[[deps.Random]]
deps = ["SHA"]
uuid = "9a3f8284-a2c9-5f02-9a11-845980a1fd5c"
version = "1.11.0"

[[deps.Reexport]]
git-tree-sha1 = "45e428421666073eab6f2da5c9d310d99bb12f9b"
uuid = "189a3867-3050-52da-a836-e630ba90ab69"
version = "1.2.2"

[[deps.SHA]]
uuid = "ea8e919c-243c-51af-8825-aaa63cd721ce"
version = "0.7.0"

[[deps.Serialization]]
uuid = "9e88b42a-f829-5b0c-bbe9-9e923198166b"
version = "1.11.0"

[[deps.Statistics]]
deps = ["LinearAlgebra"]
git-tree-sha1 = "e2b53ce13a53367e96601081e33d34746b571bad"
uuid = "10745b16-79ce-11e8-11f9-7d13ad32a3b2"
version = "1.11.5"

    [deps.Statistics.extensions]
    SparseArraysExt = ["SparseArrays"]

    [deps.Statistics.weakdeps]
    SparseArrays = "2f01184e-e22b-5df5-ae63-d93ebab69eaf"

[[deps.StyledStrings]]
uuid = "f489334b-da3d-4c2e-b8f0-e476e12c162b"
version = "1.11.0"

[[deps.Test]]
deps = ["InteractiveUtils", "Logging", "Random", "Serialization"]
uuid = "8dfed614-e22c-5e08-85e1-65c5234f0b40"
version = "1.11.0"

[[deps.Tricks]]
git-tree-sha1 = "311349fd1c93a31f783f977a71e8b062a57d4101"
uuid = "410a4b4d-49e4-4fbc-ab6d-cb71b17b3775"
version = "0.1.13"

[[deps.URIs]]
git-tree-sha1 = "908fec9df6c5de98548ead82a468c95ccf6cd263"
uuid = "5c2747f8-b7ea-4ff2-ba2e-563bfd36b1d4"
version = "1.7.0"

[[deps.UUIDs]]
deps = ["Random", "SHA"]
uuid = "cf7118a7-6976-5b1a-9a39-7adc72f591a4"
version = "1.11.0"

[[deps.Unicode]]
uuid = "4ec0a83e-493e-50e2-b9ac-8f72acf5a8f5"
version = "1.11.0"

[[deps.Zlib_jll]]
deps = ["Libdl"]
uuid = "83775a58-1f1d-513f-b197-d71354ab007a"
version = "1.3.1+2"

[[deps.libblastrampoline_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850b90-86db-534c-a0d3-1478176c7d93"
version = "5.15.0+0"

[[deps.nghttp2_jll]]
deps = ["Artifacts", "Libdl"]
uuid = "8e850ede-7688-5339-a07c-302acd2aaf8d"
version = "1.64.0+1"
"""

# ╔═╡ Cell order:
# ╟─aec26320-ad06-11f1-9088-ff519a790689
# ╟─d2d5447e-5e7d-4609-98aa-cc0f102dc3db
# ╠═d0375bcd-3fba-4dd7-b6b6-da114e7c8a1e
# ╟─c3c43c07-f611-4556-b5c6-2a2fac459a2c
# ╟─39614601-d29e-4aff-a148-f2f3c7aecfe8
# ╟─3f25c2e3-1328-4db1-9533-5acaee5cdca4
# ╟─87fb556f-640d-443b-a476-e6a96f52922c
# ╟─2d5de768-13e9-4cca-bf55-70a6b8ff10f3
# ╟─7c5f6954-0910-4acc-a33a-907bbf5dd89d
# ╟─55ea27fd-8fa4-4195-8cdd-4121dff17d83
# ╟─e59a28c7-3e1d-44e0-a012-adb445b20ef5
# ╟─c2306335-cca2-481f-9ef1-d5e6bac5ddab
# ╟─00000000-0000-0000-0000-000000000001
# ╟─00000000-0000-0000-0000-000000000002
