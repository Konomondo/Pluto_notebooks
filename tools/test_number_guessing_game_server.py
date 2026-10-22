"""End-to-end test against a running local PlutoSliderServer (default port 1234)."""
import os, pathlib, re, subprocess, sys, urllib.request
import msgpack
from playwright.sync_api import sync_playwright
sys.stdout.reconfigure(encoding='utf-8')
base=pathlib.Path(__file__).resolve().parents[1]
os.environ.setdefault('JULIA_DEPOT_PATH',str(base/'.local/julia-depot'))
os.environ.setdefault('JULIA_PROJECT',str(base/'slider-server-environment'))
os.environ.setdefault('JULIA_LOAD_PATH','@;@stdlib' if os.name=='nt' else '@:@stdlib')
os.environ.setdefault('PLAYWRIGHT_BROWSERS_PATH',str(base/'.local/browsers'))
url=sys.argv[1] if len(sys.argv)>1 else 'http://127.0.0.1:1234/number_guessing_game.html'
backend=subprocess.Popen([os.environ.get('PLUTO_TEST_JULIA','julia'),'--startup-file=no',str(base/'tools/test_number_guessing_game.jl'),'--bridge'],stdin=subprocess.PIPE,stdout=subprocess.PIPE,text=True,encoding='utf-8')
while True:
 line=backend.stdout.readline()
 if line.strip()=='READY': break
 if backend.poll() is not None: raise RuntimeError(line)
def secret_for(payload):
 backend.stdin.write(payload['round_id']+';\n'); backend.stdin.flush()
 return int(backend.stdout.readline().strip().split(';')[-1])
def payload(page): return page.locator('.number-game').evaluate('(root)=>root.value')
def ready(page):
 page.wait_for_function("window.editor_state?.slider_server?.interactive === true",timeout=60000)
 page.wait_for_function("Object.values(window.editor_state.notebook.cell_results).some(c => typeof c.output?.body === 'string' && c.output.body.includes(document.querySelector('.number-game').value.round_id))",timeout=60000)

def guess(page,n):
 turns=len(payload(page)['guesses'])+1
 page.locator(f'.number-game [data-number="{n}"]').click()
 page.locator('.number-game .check').click()
 page.wait_for_function("turns => document.querySelector('section[aria-label=\"Game feedback\"]').textContent.includes(turns + ' / 6')",arg=turns,timeout=45000)
 page.wait_for_function("!document.querySelector('.number-game .selection').textContent.startsWith('Checking')",timeout=45000)
 assert page.locator('.number-game .check').inner_text()!='Retry'
def feedback(page): return page.locator('section[aria-label="Game feedback"]').inner_text()
with sync_playwright() as p:
 browser=p.chromium.launch(headless=True)
 context=browser.new_context()
 page=context.new_page()
 requests=[]; errors=[]
 page.on('response',lambda r: requests.append(r) if '/staterequest/' in r.url else None)
 page.on('pageerror',lambda e: errors.append(str(e)))
 page.goto(url,wait_until='domcontentloaded',timeout=60000)
 page.wait_for_function("document.querySelector('.number-game')?.value?.round_id",timeout=60000)
 page.wait_for_function("document.querySelector('.number-game .selection').textContent==='Choose a number.'",timeout=60000)
 ready(page)
 secret=secret_for(payload(page)); wrong=1 if secret!=1 else 2
 guess(page,wrong)
 assert '1 / 6' in feedback(page),feedback(page)
 last_response=requests[-1]
 assert last_response.status==200
 first_url=last_response.url
 assert 'max-age' in last_response.headers.get('cache-control','')
 other=browser.new_context().new_page()
 other.goto(url,wait_until='domcontentloaded',timeout=60000)
 other.wait_for_function("document.querySelector('.number-game')?.value?.round_id",timeout=60000)
 assert payload(other)['round_id']!=payload(page)['round_id']
 other.wait_for_function("document.querySelector('.number-game .selection').textContent==='Choose a number.'",timeout=60000)
 ready(other)
 guess(other,secret_for(payload(other)))
 assert 'instantly' in feedback(other)
 for _ in range(5): guess(page,wrong)
 assert 'You lost' in feedback(page),feedback(page)
 assert page.locator('.number-game [data-number]:disabled').count()==100
 # Replay a cacheable request after other clients and rounds changed server state.
 with urllib.request.urlopen(first_url,timeout=30) as response:
  data=msgpack.unpackb(response.read(),raw=False,strict_map_key=False)
 bodies=[p.get('value','') for p in data['patches'] if p.get('path',[])[-2:]==['output','body']]
 assert any(isinstance(b,str) and '1 / 6' in b for b in bodies),str(bodies)
 old=payload(page)['round_id']; page.get_by_role('button',name='New game',exact=True).click()
 page.wait_for_function('(old)=>document.querySelector(".number-game")?.value?.round_id!==old',arg=old,timeout=30000)
 page.wait_for_function("document.querySelector('.number-game .selection').textContent==='Choose a number.'",timeout=30000)
 secret=secret_for(payload(page)); wrong=1 if secret!=1 else 2
 for _ in range(5): guess(page,wrong)
 guess(page,secret)
 assert 'won in 6 turns' in feedback(page),feedback(page)
 assert all(r.status==200 for r in requests)
 print('PASS: real PlutoSliderServer + Chromium: high/low feedback, isolated browsers, six-turn loss, cached replay, reset, sixth-turn win.')
 print('Game state requests:',len(requests),'Page errors:',errors)
 browser.close()
backend.stdin.close(); backend.wait(timeout=10)
