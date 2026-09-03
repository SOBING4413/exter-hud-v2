import React from 'react'

// A compact circular-progress stat used for health/armor/hunger/thirst/stress/stamina.
export default function RadialStat({ value, max = 100, icon, color, size = 46, critical }) {
  const pct = Math.max(0, Math.min(1, value / max))
  const r = (size - 6) / 2
  const circumference = 2 * Math.PI * r

  return (
    <div
      className={`panel ${critical ? 'critical' : ''}`}
      style={{
        width: size,
        height: size,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        position: 'relative',
      }}
      title={`${Math.round(value)}`}
    >
      <svg width={size} height={size} style={{ position: 'absolute', transform: 'rotate(-90deg)' }}>
        <circle cx={size / 2} cy={size / 2} r={r} stroke="rgba(255,255,255,0.10)" strokeWidth="3" fill="none" />
        <circle
          cx={size / 2}
          cy={size / 2}
          r={r}
          stroke={color}
          strokeWidth="3"
          fill="none"
          strokeDasharray={circumference}
          strokeDashoffset={circumference * (1 - pct)}
          strokeLinecap="round"
          style={{ transition: 'stroke-dashoffset 300ms ease' }}
        />
      </svg>
      <div style={{ fontSize: size * 0.4 }}>{icon}</div>
    </div>
  )
}
