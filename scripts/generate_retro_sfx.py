import wave
import math
import struct
import random
import os

os.makedirs("assets/audio", exist_ok=True)
SAMPLE_RATE = 22050

def save_wav(filename, samples):
    with wave.open(filename, 'w') as wf:
        wf.setnchannels(1)        # mono
        wf.setsampwidth(2)        # 16-bit
        wf.setframerate(SAMPLE_RATE)
        packed = b''.join([struct.pack('<h', max(-32767, min(32767, int(s * 32760)))) for s in samples])
        wf.writeframes(packed)
    print(f"Generated {filename}")

def gen_slash():
    # Frequency sweep 700Hz -> 120Hz with soft white noise
    duration = 0.12
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = (1.0 - t / duration) ** 1.5
        freq = 700.0 * (1.0 - t / duration) + 120.0
        wave_val = math.sin(2 * math.pi * freq * t)
        noise = (random.random() * 2.0 - 1.0) * 0.35
        samples.append((wave_val * 0.65 + noise) * env * 0.8)
    return samples

def gen_hit():
    # Punch impact: rapid pitch drop 280Hz -> 45Hz + crunchy noise burst
    duration = 0.14
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 28.0)
        freq = 280.0 * (1.0 - t / duration) + 45.0
        wave_val = math.copysign(1.0, math.sin(2 * math.pi * freq * t)) * 0.5  # square wave punch
        noise = (random.random() * 2.0 - 1.0) * 0.5
        samples.append((wave_val + noise) * env * 0.85)
    return samples

def gen_skill():
    # Earth Shatter / Heavy Explosion: low rumbling sweep + distorted crunch
    duration = 0.35
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.exp(-t * 8.0)
        freq = 160.0 * (1.0 - t / duration) + 35.0
        sub_freq = 60.0
        wave_val = math.sin(2 * math.pi * freq * t) + 0.6 * math.sin(2 * math.pi * sub_freq * t)
        noise = (random.random() * 2.0 - 1.0) * 0.45
        sample = (wave_val + noise) * env * 0.9
        samples.append(max(-1.0, min(1.0, sample * 1.3))) # soft overdrive clipping
    return samples

def gen_potion():
    # 4-note ascending chime: C5, E5, G5, C6
    notes = [523.25, 659.25, 783.99, 1046.50]
    samples = []
    note_dur = 0.06
    n_note = int(SAMPLE_RATE * note_dur)
    for freq in notes:
        for i in range(n_note):
            t = i / SAMPLE_RATE
            env = math.exp(-t * 12.0)
            wave_val = math.sin(2 * math.pi * freq * t) + 0.25 * math.sin(4 * math.pi * freq * t)
            samples.append(wave_val * env * 0.6)
    return samples

def gen_dialog():
    # Subtle 25ms chirp for typewriter blip
    duration = 0.025
    n = int(SAMPLE_RATE * duration)
    samples = []
    freq = 620.0
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / duration))
        samples.append(math.sin(2 * math.pi * freq * t) * env * 0.3)
    return samples

def gen_roar():
    # Low beast roar
    duration = 0.55
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / duration)) ** 0.5
        freq = 95.0 + 35.0 * math.sin(2 * math.pi * 7.0 * t)
        wave_val = math.sin(2 * math.pi * freq * t)
        noise = (random.random() * 2.0 - 1.0) * 0.4
        samples.append((wave_val * 0.6 + noise * 0.4) * env * 0.8)
    return samples

save_wav("assets/audio/sfx_slash.wav", gen_slash())
save_wav("assets/audio/sfx_hit.wav", gen_hit())
save_wav("assets/audio/sfx_skill.wav", gen_skill())
save_wav("assets/audio/sfx_potion.wav", gen_potion())
save_wav("assets/audio/sfx_dialog.wav", gen_dialog())
save_wav("assets/audio/sfx_roar.wav", gen_roar())
