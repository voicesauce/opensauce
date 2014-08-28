time_step = 0.005
min_pitch = 50
max_pitch = 500
silence_thres = 0.03
voice_thres = 0.45
octave_cost = 0.01
octave_jump_cost = 0.35
vucost = 0.14
kill_octave_jumps = 0
smooth = 0
smooth_bandwidth = 5
interpolate = 0
method$ = "cc"

wavfile$ = "/Users/kate/speech-tech/voice-sauce/VoiceSauce/sounds/hmong_f4_40_a.wav"
Read from file... 'wavfile$'

soundname$ = selected$("Sound", 1)

To Pitch (ac)... 'time_step' 'min_pitch' 15 no 'silence_thres' 'voice_thres' 'octave_cost' 'octave_jump_cost' 'vucost' 'max_pitch'

Down to PitchTier

resultfile$ = "'wavfile$'.praatcc"

if fileReadable (resultfile$)
filedelete 'resultfile$'
endif

Write to headerless spreadsheet file... 'resultfile$'