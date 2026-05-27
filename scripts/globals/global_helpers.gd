extends Node

func factor_to_db(factor: float) -> float:
    if factor <= 0: return -60
    if factor > 1: return 0
    return 20 * log(factor)

func play_audio(audio: AudioStreamPlayer2D, lower: float = 0, upper: float = 0, base_volume: float = 0):
    audio.volume_db = factor_to_db(OPTIONS.SFX) + base_volume if OPTIONS.SFX > 0 else factor_to_db(OPTIONS.SFX)
    lower = audio.pitch_scale if lower == 0 else lower
    upper = audio.pitch_scale if upper == 0 else upper

    if upper == lower: audio.play()
    else:
        var original_pitch = audio.pitch_scale
        audio.pitch_scale = randf_range(lower, upper)
        audio.play()
        audio.pitch_scale = original_pitch