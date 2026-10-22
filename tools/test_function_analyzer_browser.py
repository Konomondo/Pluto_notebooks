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
    print("PASS: Chromium math input, code rejection, real-domain message and graph recovery")
    browser.close()
