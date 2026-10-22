### A Pluto.jl notebook ###
# v0.19.32

using Markdown
using InteractiveUtils

# ╔═╡ 744c848b-15ac-415d-aef6-5244be5ed981
md"""

### Die Vorbereitungen sind geschafft, jetzt kann die Reise 🧭 beginnen :)
$([Resource(michael, :width => 150), Resource(annika, :width => 150), Resource(gihan, :width => 150), Resource(gerhard, :width => 150)])
### Bewaffnet mit unserem Protoptyp gehen wir jetzt mit Schüler*innen in eine **Testphase** über
### **Testen Sie selbst** 🤠
"""

# ╔═╡ e6f067e1-c377-4885-9eab-a1a0403f7bf0
@htl("""
<table class="compasstable">
	
    <tbody>
        <tr> $(Resource(qr_code)) </tr>
		<td style="text-align:right">$(md"""# [https://tinyurl.com/Konomondo](https://tinyurl.com/Konomondo)
""") </td>
</tbody>
</table>
""")

# ╔═╡ 4f94136c-6dd3-4bb8-8a20-4a5a8162a74b
hide_everything_below

# ╔═╡ c06b5842-f0fb-4f6e-b3dd-c2afebb7961c
md"""
# [https://tinyurl.com/Konomondo](https://tinyurl.com/Konomondo)
"""

# ╔═╡ 4ea4fc64-b2f4-40a6-8b51-03a84f54f113
qr_code = "https://github.com/dorn-gerhard/workAdventure/raw/master/src/assets/Proto-QR.png"

# ╔═╡ 952acb68-4518-48c9-84a7-3f816ec55591
begin

annika = "https://github.com/dorn-gerhard/workAdventure/raw/master/Characters/annika_large.png"
	gihan = "https://github.com/dorn-gerhard/workAdventure/raw/master/Characters/gihan_large.png"
	gerhard = "https://raw.githubusercontent.com/dorn-gerhard/workAdventure/master/Characters/gerhard_large.png"
	michael = "https://github.com/dorn-gerhard/workAdventure/raw/master/Characters/michi_large.png"
end

# ╔═╡ 036a235a-c318-4270-a883-ea8164cdfdd9


# ╔═╡ 846d334a-e5ab-484a-832f-731c1290356f
begin
    import Pkg
    Pkg.activate(joinpath(@__DIR__, "..", "slider-server-environment"))
	using PlutoUI, HypertextLiteral
end

# ╔═╡ cd4d9216-5fc5-4bb3-a3f8-a0852a576866
begin
hide_everything_below =
	html"""
	<style>
	pluto-cell.hide_everything_below ~ pluto-cell {
		display: none;
	}
	</style>
	
	<script>
	const cell = currentScript.closest("pluto-cell")
	
	const setclass = () => {
		console.log("change!")
		cell.classList.toggle("hide_everything_below", true)
	}
	setclass()
	const observer = new MutationObserver(setclass)
	
	observer.observe(cell, {
		subtree: false,
		attributeFilter: ["class"],
	})
	
	invalidation.then(() => {
		observer.disconnect()
		cell.classList.toggle("hide_everything_below", false)
	})
	
	</script>
	""";
	
md"definition hide everything below"
end

# ╔═╡ 3d2991b0-f64a-11ec-20c7-912cad47a057


html"""
<style>
	body, main, pluto-notebook, nav.plutoui-toc.aside.indent {
		background-color: white
	}
</style>
"""

# ╔═╡ 366bbfb5-98eb-4036-b467-4ccc514e7371
md"""
$([Resource(michael, :width => 150), Resource(annika, :width => 150), Resource(gihan, :width => 150), Resource(gerhard, :width => 150)])
"""

# ╔═╡ Cell order:
# ╟─744c848b-15ac-415d-aef6-5244be5ed981
# ╟─e6f067e1-c377-4885-9eab-a1a0403f7bf0
# ╟─4f94136c-6dd3-4bb8-8a20-4a5a8162a74b
# ╠═c06b5842-f0fb-4f6e-b3dd-c2afebb7961c
# ╠═4ea4fc64-b2f4-40a6-8b51-03a84f54f113
# ╟─952acb68-4518-48c9-84a7-3f816ec55591
# ╠═036a235a-c318-4270-a883-ea8164cdfdd9
# ╠═846d334a-e5ab-484a-832f-731c1290356f
# ╠═cd4d9216-5fc5-4bb3-a3f8-a0852a576866
# ╠═3d2991b0-f64a-11ec-20c7-912cad47a057
# ╠═366bbfb5-98eb-4036-b467-4ccc514e7371
