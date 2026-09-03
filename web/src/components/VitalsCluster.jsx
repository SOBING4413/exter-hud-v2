import React from 'react'
import { Heart, Shield, Drumstick, Droplets, Brain, Zap, Wind } from 'lucide-react'
import { useHud } from '../state/store'
import RadialStat from './RadialStat'
import Draggable from './Draggable'

export default function VitalsCluster() {
  const {
    health, armor, hunger, thirst, stress, stamina,
    underwater, oxygenSeconds, dynamicVisibility, theme,
  } = useHud((s) => s)

  const showOxygen = underwater || !dynamicVisibility.oxygenOnlyUnderwater
  const showStress = !dynamicVisibility.hideStressIfUnused || stress > 0

  return (
    <Draggable id="vitals" style={{ position: 'absolute', left: 20, bottom: 20, pointerEvents: 'auto' }}>
      <div style={{ display: 'flex', gap: 8 }}>
        <RadialStat value={health} icon={<Heart size={16} color={theme.dangerColor} />} color={health <= 25 ? theme.dangerColor : theme.successColor} critical={health <= 20} />
        {armor > 0 && <RadialStat value={armor} icon={<Shield size={16} color={theme.primaryColor} />} color={theme.primaryColor} />}
        <RadialStat value={hunger} icon={<Drumstick size={16} color={theme.warningColor} />} color={theme.warningColor} critical={hunger <= 15} />
        <RadialStat value={thirst} icon={<Droplets size={16} color={theme.primaryColor} />} color={theme.primaryColor} critical={thirst <= 15} />
        {showStress && <RadialStat value={stress} icon={<Brain size={16} color={theme.dangerColor} />} color={theme.dangerColor} critical={stress >= 80} />}
        <RadialStat value={stamina} icon={<Zap size={16} color={theme.successColor} />} color={theme.successColor} />
        {showOxygen && (
          <RadialStat
            value={oxygenSeconds != null ? Math.min(100, oxygenSeconds) : 100}
            icon={<Wind size={16} color={theme.primaryColor} />}
            color={theme.primaryColor}
            critical={oxygenSeconds != null && oxygenSeconds <= 10}
          />
        )}
      </div>
    </Draggable>
  )
}
