import os, pathlib, re, subprocess, sys
from playwright.sync_api import sync_playwright
sys.stdout.reconfigure(encoding='utf-8')
base=pathlib.Path(__file__).resolve().parents[1]
os.environ.setdefault('JULIA_DEPOT_PATH',str(base/'.local/julia-depot'))
os.environ.setdefault('JULIA_PROJECT',str(base/'slider-server-environment'))
os.environ.setdefault('JULIA_LOAD_PATH','@;@stdlib' if os.name=='nt' else '@:@stdlib')
os.environ.setdefault('PLAYWRIGHT_BROWSERS_PATH',str(base/'.local/browsers'))
backend=subprocess.Popen([os.environ.get('PLUTO_TEST_JULIA','julia'),'--startup-file=no',str(base/'tools/test_number_guessing_game.jl'),'--bridge'],stdin=subprocess.PIPE,stdout=subprocess.PIPE,text=True,encoding='utf-8')
while True:
 line=backend.stdout.readline()
 if line.strip()=='READY': break
 if backend.poll() is not None: raise RuntimeError('Julia bridge failed: '+line)
 print(line.rstrip())
def score(payload):
 backend.stdin.write(payload['round_id']+';'+','.join(map(str,payload['guesses']))+'\n'); backend.stdin.flush()
 turns,finished,message,secret=backend.stdout.readline().strip().split(';')
 return dict(turns=int(turns),finished=finished=='true',message=message,secret=int(secret))
source=(base/'notebooks/number_guessing_game.jl').read_text(encoding='utf-8')
script=re.search(r'<script>(.*?)</script>',source.split('function number_grid(reset_count)',1)[1],re.S)[1]
with sync_playwright() as p:
 browser=p.chromium.launch(headless=True)
 page=browser.new_page()
 page.expose_function('score',score)
 page.set_content('<button id="new">New game</button><div id="mount"></div><p id="feedback"></p>')
 page.evaluate('''script => {
  window.reply=true;
  window.mount=()=>{
   if(window.dispose) window.dispose();
   const root=document.createElement('div');
   root.innerHTML='<div>'+Array.from({length:100},(_,i)=>'<button data-number="'+(i+1)+'">'+(i+1)+'</button>').join('')+'</div><button class="check" disabled>Check</button><span class="selection"></span>';
   document.querySelector('#mount').replaceChildren(root);
   const invalidation=new Promise(resolve=>window.dispose=resolve);
   new Function('currentScript','invalidation',script)({parentElement:root},invalidation);
   root.addEventListener('input',async()=>{
    if(!window.reply) return;
    const payload=root.value;
    const result=await window.score(payload);
    document.querySelector('#feedback').textContent=result.message;
    window.dispatchEvent(new CustomEvent('number-game-result-'+payload.round_id,{detail:result}));
   });
   window.root=root;
  };
  document.querySelector('#new').onclick=window.mount;
  window.mount();
 }''',script)
 secret=score(page.evaluate('root.value'))['secret']; wrong=1 if secret!=1 else 2
 page.locator(f'[data-number="{wrong}"]').click()
 assert page.evaluate('root.value.guesses.length')==0
 for turn in range(6):
  if turn: page.locator(f'[data-number="{wrong}"]').click()
  page.locator('.check').click()
  page.wait_for_function("!document.querySelector('.selection').textContent.startsWith('Checking')")
  assert page.evaluate('root.value.guesses.length')==turn+1
  assert score(page.evaluate('root.value'))['turns']==turn+1
 assert 'You lost' in page.locator('#feedback').inner_text()
 assert page.locator('[data-number]:disabled').count()==100
 old_id=page.evaluate('root.value.round_id'); page.locator('#new').click()
 assert page.evaluate('root.value.round_id')!=old_id
 assert page.evaluate('root.value.guesses.length')==0
 secret=score(page.evaluate('root.value'))['secret']
 page.locator(f'[data-number="{secret}"]').click(); page.locator('.check').click()
 page.wait_for_function("document.querySelector('.selection').textContent.startsWith('Game over')")
 assert 'instantly' in page.locator('#feedback').inner_text()
 page.locator('#new').click(); page.evaluate('window.reply=false'); page.clock.install()
 page.locator('[data-number="100"]').click(); page.locator('.check').click()
 page.clock.fast_forward(31000)
 assert page.locator('.check').inner_text()=='Retry'
 page.evaluate('window.reply=true'); page.locator('.check').click()
 page.wait_for_function("!document.querySelector('.selection').textContent.startsWith('Checking')")
 assert page.evaluate('root.value.guesses.length')==1
 assert page.evaluate('root.value.request_id')==2
 print('PASS: Chromium + Julia: selection, feedback, replay, six turns, loss, reset, win, timeout and idempotent retry.')
 browser.close()
backend.stdin.close(); backend.wait(timeout=10)
