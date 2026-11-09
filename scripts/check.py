import os,subprocess,tempfile,shutil,pathlib,json,ast,tomllib
repo=pathlib.Path(__file__).resolve().parents[1]
chez=shutil.which('chezmoi')
assert chez, 'chezmoi is required'
for desktop in (False,True):
 with tempfile.TemporaryDirectory(prefix='thinkpad-test-') as d:
  root=pathlib.Path(d);home=root/'home';home.mkdir();src=root/'source';shutil.copytree(repo,src,ignore=shutil.ignore_patterns('.git'))
  env=os.environ.copy();env.update(HOME=str(home),XDG_CONFIG_HOME=str(home/'.config'),XDG_DATA_HOME=str(home/'.local/share'),XDG_STATE_HOME=str(home/'.local/state'),XDG_CACHE_HOME=str(home/'.cache'),PATH=str(pathlib.Path(chez).parent)+':'+env['PATH'])
  def run(*args):
   return subprocess.run(args,env=env,text=True,check=True,capture_output=True)
  run('git','-C',str(src),'init','-b','main')
  run('git','-C',str(src),'config','user.name','Test')
  run('git','-C',str(src),'config','user.email','test@example.invalid')
  run('git','-C',str(src),'add','.')
  run('git','-C',str(src),'commit','-m','Initial')
  remote=root/'remote.git'
  run('git','init','--bare','--initial-branch=main',str(remote))
  run('git','-C',str(src),'remote','add','origin',str(remote))
  run('git','-C',str(src),'push','-u','origin','main')
  run(chez,'--source',str(src),'init','--promptBool',f'Synchronizovat aj Hyprland s HyDE (Lua konfiguracia)?={str(desktop).lower()}')
  cfg=tomllib.loads((home/'.config/chezmoi/chezmoi.toml').read_text());assert cfg['data']['hydeDesktop']==desktop
  local=home/'.config/fish/aliases.local.fish';local.parent.mkdir(parents=True);local.write_text('alias localtest="echo keep"\n')
  run(chez,'apply','--force');run(chez,'verify');assert local.read_text()=='alias localtest="echo keep"\n'
  managed=run(chez,'managed','--include=files').stdout.splitlines()
  assert ('.config/hypr/hyprland.lua' in managed)==desktop
  assert not any('local.' in p or 'monitors' in p for p in managed)
  for p in home.rglob('*.fish'):run('fish','--no-config','--no-execute',str(p))
  for p in home.rglob('*.lua'):run('luac','-p',str(p))
  for p in (home/'.local/bin').iterdir():
   if p.read_text().startswith('#!/usr/bin/env bash'):run('bash','-n',str(p))
   else:ast.parse(p.read_text())
  if desktop:
   pypr=tomllib.loads((home/'.config/pypr/config.toml').read_text());assert pypr['pyprland']['plugins_paths']==[str(home/'.config/pypr/plugins')]
  run('python3',str(src/'scripts/backup.py'))
  backups=list((home/'.local/state/thinkpadSync/backups').iterdir());assert len(backups)==1
  assert (backups[0]/'.config/fish/aliases.fish').is_file()
  # Local destination edits must block setup-pull before any network activity.
  with (home/'.config/fish/aliases.fish').open('a') as f:f.write('alias testchanged="echo changed"\n')
  result=subprocess.run([str(home/'.local/bin/setup-pull')],env=env,capture_output=True,text=True)
  assert result.returncode!=0 and 'Máš lokálne zmeny' in result.stderr
  run(str(home/'.local/bin/setup-push'),'Test outgoing alias')
  assert 'testchanged' in run('git','--git-dir',str(remote),'show','main:dot_config/fish/aliases.fish').stdout
  # Simulate an incoming commit from the other notebook.
  other=root/'other'
  run('git','clone',str(remote),str(other))
  target=other/'dot_config/fish/aliases.fish'
  target.write_text(target.read_text()+'alias incoming="echo incoming"\n')
  run('git','-C',str(other),'add','.')
  run('git','-C',str(other),'-c','user.name=Test','-c','user.email=test@example.invalid','commit','-m','Incoming')
  run('git','-C',str(other),'push')
  run(str(home/'.local/bin/setup-pull'))
  assert 'alias incoming=' in (home/'.config/fish/aliases.fish').read_text()
  run(chez,'verify')
  print('PASS', 'HyDE' if desktop else 'shell', 'render, syntax, local exclusions, backup, pull protection, push and incoming pull')
