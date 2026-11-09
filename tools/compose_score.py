"""Original modular stereo score and ambience. CodeRabbit-assisted composition.
Requires numpy and FFmpeg. No samples or external recordings are used.
"""
import pathlib,subprocess,numpy as np
ROOT=pathlib.Path(__file__).resolve().parents[1]/'game/assets/enrichment/audio';ROOT.mkdir(parents=True,exist_ok=True)
RATE=48000
SCORES={'main':(62,84,'strings'),'death':(45,66,'bells'),'beauty':(69,76,'flute'),'prosperity':(57,100,'plucks'),'combat':(50,124,'drums'),'boss':(38,132,'drums'),'explore':(64,80,'flute'),'story':(57,62,'strings'),'village':(62,92,'plucks'),'dungeon':(38,56,'bells')}
def encode(name,seconds,fun):
 p=subprocess.Popen(['ffmpeg','-v','error','-y','-f','f32le','-ar',str(RATE),'-ac','2','-i','pipe:0','-c:a','libvorbis','-q:a','6',str(ROOT/(name+'.ogg'))],stdin=subprocess.PIPE)
 for start in range(0,seconds,2):
  t=np.arange(start*RATE,min((start+2)*RATE,seconds*RATE),dtype=np.float64)/RATE
  l,r=fun(t);fade=np.minimum(1,np.minimum(t/2,(seconds-t)/2));a=np.clip(np.column_stack((l*fade,r*fade)),-.95,.95).astype('<f4');p.stdin.write(a.tobytes())
 p.stdin.close();assert p.wait()==0
 print(name,flush=True)
for name,(key,bpm,voice) in SCORES.items():
 def music(t,key=key,bpm=bpm,voice=voice):
  beat=t*bpm/60;chord=np.array([0,5,3,7,0,8,5,7])[(beat//8).astype(int)%8]
  melody=np.array([0,7,12,10,7,3,5,2,0,3,7,14,12,7,5,3])[(beat//.5).astype(int)%16]
  f=440*2**((key+chord+melody-69)/12);ph=beat%.5;env=np.sin(np.pi*ph/.5)**2
  lead=np.sin(2*np.pi*f*t+np.sin(t*5)*.02)*env*.12
  if voice in ['bells','plucks']:lead+=(np.sin(2*np.pi*f*2.003*t)*.06+np.sin(2*np.pi*f*3.01*t)*.025)*np.exp(-ph*12)
  bassf=440*2**((key-24+chord-69)/12)
  pad=np.zeros_like(t)
  for interval in [0,7,12]:pad+=np.sin(2*np.pi*bassf*2**(interval/12)*t)*.035
  pad*=.8+.2*np.sin(t*.35)
  kick=np.sin(2*np.pi*(55*(beat%1)-18*(beat%1)**2))*np.exp(-(beat%1)*16)*(.2 if voice=='drums' else .035)
  return lead+pad+kick,lead*.88+pad+kick+np.sin(2*np.pi*f*1.002*t)*env*.025
 encode(name,96,music)
for n,name in enumerate(['forest','water','rain','wind','village_ambience','dungeon_ambience','fire','birds']):
 rng=np.random.default_rng(1300+n)
 def ambience(t,n=n):
  noise=rng.normal(0,.12,len(t));filtered=np.convolve(noise,np.ones(12)/12,mode='same')
  if n in [0,7]:tone=np.sin(2*np.pi*(1700*t+120*np.sin(t*3)))*np.maximum(0,np.sin(t*1.8))**18*.07
  elif n==4:tone=np.sin(2*np.pi*170*t)*np.maximum(0,np.sin(t*.9))**8*.03
  else:tone=np.sin(t*(60+n*10))*np.sin(t*.7)*.012
  left=filtered*(.4+.3*np.sin(t*.2)**2)+tone
  return left,left*.85+np.roll(filtered,100)*.15
 encode(name,32,ambience)
