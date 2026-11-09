"""Original synthesized score and effect source. Python standard library only."""
from pathlib import Path
import wave, math, struct
root = Path(__file__).resolve().parents[1] / 'game/assets/audio'
for land, notes in enumerate([[110,130.81,164.81,146.83],[146.83,196,220,293.66],[130.81,164.81,196,261.63]]):
    with wave.open(str(root / f'land{land}.wav'), 'wb') as w:
        w.setparams((1,2,22050,0,'NONE','not compressed'))
        data = bytearray()
        for i in range(22050*16):
            t=i/22050; beat=t%2; n=notes[int(t/2)%4]; env=math.sin(math.pi*beat/2)**2
            s=.12*math.sin(2*math.pi*n*t)*env+.07*math.sin(2*math.pi*n/2*t)+.035*math.sin(2*math.pi*n*1.5*t)*env
            s*=min(1,t*2,(16-t)*2)
            data+=struct.pack('<h',int(s*32767))
        w.writeframes(data)
with wave.open(str(root / 'impact.wav'), 'wb') as w:
    w.setparams((1,2,22050,0,'NONE','not compressed'))
    w.writeframes(b''.join(struct.pack('<h',int(12000*math.exp(-i/900)*math.sin(i*.09+i*i*.00001))) for i in range(5000)))
# Additional original cues and combat layers for the v0.2 release.
for name,length,freq in [('step',.12,120),('spell',.55,600),('creature',.7,65),('boss',1.2,48)]:
    with wave.open(str(root / (name+'.wav')), 'wb') as w:
        w.setparams((1,2,22050,0,'NONE','not compressed'))
        w.writeframes(b''.join(struct.pack('<h',int(13000*math.exp(-i/(22050*length*.3))*math.sin(2*math.pi*freq*(i/22050)+(i/22050)**2*freq*3))) for i in range(int(22050*length))))
with wave.open(str(root/'combat.wav'),'wb') as w:
    w.setparams((1,2,22050,0,'NONE','not compressed'))
    data=bytearray()
    for i in range(22050*16):
        t=i/22050; phase=t%.5
        drum=math.sin(2*math.pi*(65*phase-30*phase*phase))*math.exp(-phase*18)
        tone=math.sin(2*math.pi*[110,130.81,146.83,98][int(t/2)%4]*t)*.18
        data+=struct.pack('<h',int(15000*(drum*.5+tone)))
    w.writeframes(data)
