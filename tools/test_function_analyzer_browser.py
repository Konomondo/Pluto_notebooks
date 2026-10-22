"""Optional Chromium check against the running local restricted analyzer."""
import os
from pathlib import Path
import sys

from playwright.sync_api import sync_playwright

base = Path(__file__).resolve().parents[1]
os.environ.setdefault("PLAYWRIGHT_BROWSERS_PATH", str(base / ".local/browsers"))
url = sys.argv[1] if len(sys.argv) > 1 else "http://127.0.0.1:1234/function_analyzer.html"
status = 'pluto-cell[id="09a37561-fd16-4d4c-8963-82d7de82cccb"] pluto-output'
graph = 'pluto-cell[id="73bc4715-f9fd-4d79-bbe8-0bf77302eba4"] pluto-output'

with sync_playwright() as p:
    browser = p.chromium.launch(headless=True)
    page = browser.new_page()
    page.goto(url, wait_until="domcontentloaded", timeout=60000)
    page.wait_for_function("window.editor_state?.slider_server?.interactive === true", timeout=60000)
    page.locator(status).get_by_text("Formula accepted.", exact=False).wait_for(timeout=60000)
    field = page.locator('bond[def="text_equation"] input[type="text"]')
    submit = page.locator('bond[def="text_equation"] input[type="submit"]')
    for source, expected in [
        ("sin(x) + b*x^2", "Formula accepted."),
        ("run(`whoami`)", "Invalid formula:"),
        ("x = 1", "Invalid formula:"),
        ("sqrt(-1) + x", "outside the real-valued domain"),
        ("x^2 + b*x", "Formula accepted."),
    ]:
        field.fill(source)
        with page.expect_response(lambda r: "/staterequest/" in r.url, timeout=60000) as response:
            submit.click()
        assert response.value.status == 200
        page.wait_for_function(
            "([source, selector, expected]) => window.editor_state.notebook.bonds.text_equation.value === source && document.querySelector(selector).textContent.includes(expected) && Object.values(window.editor_state.notebook.cell_results).every(c => !c.running && !c.queued)",
            arg=[source, status, expected], timeout=60000,
        )
        assert page.evaluate("Object.values(window.editor_state.notebook.cell_results).every(c => !c.errored)")
    assert page.locator(graph).locator("img,svg").count() > 0
    checkbox = page.locator('bond[def="simplify_formula"] input[type="checkbox"]')
    assert not checkbox.is_checked()
    field.fill("x+x")
    with page.expect_response(lambda r: "/staterequest/" in r.url, timeout=60000) as response:
        submit.click()
    assert response.value.status == 200
    equation = 'pluto-cell[id="9188b13a-7f3a-4091-baa6-e37cedd65e64"] pluto-output'
    page.wait_for_function("selector => document.querySelector(selector).textContent.includes('+')",arg=equation,timeout=60000)
    screenshots = base / ".local"
    screenshots.mkdir(exist_ok=True)
    page.locator(graph).screenshot(path=str(screenshots / "analyzer-original-formula.png"))
    for enabled in [True, False]:
        with page.expect_response(lambda r: "/staterequest/" in r.url, timeout=60000) as response:
            checkbox.set_checked(enabled)
        assert response.value.status == 200
        page.wait_for_function(
            "([enabled, selector]) => window.editor_state.notebook.bonds.simplify_formula.value === enabled && Object.values(window.editor_state.notebook.cell_results).every(c => !c.running && !c.queued && !c.errored) && document.querySelector(selector).textContent.includes('+') !== enabled",
            arg=[enabled, equation], timeout=60000,
        )
        if enabled:
            page.locator(graph).screenshot(path=str(screenshots / "analyzer-simplified-formula.png"))
    print("PASS: Chromium formula entry/rejection/recovery and simplify checkbox x+x -> 2x -> x+x")
    browser.close()
