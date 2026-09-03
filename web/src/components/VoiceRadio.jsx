import React from 'react'
import { Mic, MicOff, Radio } from 'lucide-react'
import { useHud } from '../state/store'
import Draggable from './Draggable'

const MODE_LABEL = { muted: 'Muted', normal: 'Normal', shout: 'Shout', whisper: 'Whisper' }

export default function VoiceRadio() {
  const { voice, theme, dynamicVisibility } = useHud((s) => s)

  const showRadio = voice.radioActive || !dynamicVisibility.radioOnlyWhenActive

  if (!voice.talking && !showRadio) return null

  return (
    <Draggable id="voice" style={{ position: 'absolute', left: 20, top: 20, pointerEvents: 'auto' }}>
      <div className="panel fade-in" style={{ padding: '6px 10px', display: 'flex', alignItems: 'center', gap: 8 }}>
        {voice.mode === 'muted' ? <MicOff size={14} color={theme.dangerColor} /> : <Mic size={14} color={voice.talking ? theme.successColor : 'var(--text-muted)'} />}
        <span className="label">{MODE_LABEL[voice.mode] || 'Normal'}</span>
        {showRadio && (
          <>
            <Radio size={14} color={theme.primaryColor} />
            <span className="label">{voice.radioChannel ? `CH ${voice.radioChannel}` : 'Radio'}</span>
          </>
        )}
      </div>
    </Draggable>
  )
}
