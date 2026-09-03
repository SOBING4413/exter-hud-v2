import React from 'react'
import { Fuel, Lock, Unlock, Lightbulb, Gauge, ParkingCircle, Thermometer } from 'lucide-react'
import { useHud } from '../state/store'
import Draggable from './Draggable'

function Speedometer({ speed, rpm, gear, unit, color }) {
  const size = 128
  const r = 56
  const circumference = 2 * Math.PI * r
  const rpmPct = Math.max(0, Math.min(1, rpm))

  return (
    <div style={{ width: size, height: size, position: 'relative' }}>
      <svg width={size} height={size} style={{ position: 'absolute', transform: 'rotate(-90deg)' }}>
        <circle cx={size / 2} cy={size / 2} r={r} stroke="rgba(255,255,255,0.08)" strokeWidth="6" fill="none" />
        <circle
          cx={size / 2} cy={size / 2} r={r}
          stroke={color}
          strokeWidth="6"
          fill="none"
          strokeDasharray={circumference}
          strokeDashoffset={circumference * (1 - rpmPct)}
          strokeLinecap="round"
          style={{ transition: 'stroke-dashoffset 120ms linear' }}
        />
      </svg>
      <div style={{
        position: 'absolute', inset: 0, display: 'flex', flexDirection: 'column',
        alignItems: 'center', justifyContent: 'center',
      }}>
        <div className="value" style={{ fontSize: 30, lineHeight: 1 }}>{speed}</div>
        <div className="label">{unit.toUpperCase()}</div>
        <div className="label" style={{ marginTop: 4 }}>GEAR {gear === 0 ? 'R' : gear}</div>
      </div>
    </div>
  )
}

export default function VehicleHud() {
  const {
    inVehicle, speed, rpm, gear, fuel, engineHealth, bodyHealth,
    lightsOn, highBeams, locked, handbrake, seatbelt, cruiseControl,
    engineTemp, speedUnit, theme, dynamicVisibility,
  } = useHud((s) => s)

  if (dynamicVisibility.vehicleHudOnlyInVehicle && !inVehicle) return null

  const fuelColor = fuel <= 15 ? theme.dangerColor : theme.primaryColor
  const healthColor = engineHealth <= 25 ? theme.dangerColor : theme.successColor

  return (
    <Draggable id="vehicle" style={{ position: 'absolute', right: 20, bottom: 20, pointerEvents: 'auto' }}>
      <div className="panel fade-in" style={{ padding: 16, display: 'flex', alignItems: 'center', gap: 16 }}>
        <Speedometer speed={speed} rpm={rpm} gear={gear} unit={speedUnit} color={theme.primaryColor} />

        <div style={{ display: 'flex', flexDirection: 'column', gap: 6, minWidth: 96 }}>
          <Row icon={<Fuel size={14} color={fuelColor} />} label="Fuel" value={`${fuel}%`} />
          <Row icon={<Gauge size={14} color={healthColor} />} label="Engine" value={`${engineHealth}%`} />
          {engineTemp != null && <Row icon={<Thermometer size={14} color={theme.warningColor} />} label="Temp" value={`${Math.round(engineTemp)}°`} />}
          <Row icon={locked ? <Lock size={14} /> : <Unlock size={14} />} label="Lock" value={locked ? 'Locked' : 'Unlocked'} />
          <div style={{ display: 'flex', gap: 6, marginTop: 2 }}>
            <Badge active={lightsOn} label="Lights" />
            <Badge active={highBeams} label="Hi-Beam" />
            <Badge active={handbrake} label="Hbrake" />
            <Badge active={seatbelt} label="Belt" activeColor={theme.successColor} inactiveColor={theme.dangerColor} />
            <Badge active={cruiseControl} label="Cruise" />
          </div>
        </div>
      </div>
    </Draggable>
  )
}

function Row({ icon, label, value }) {
  return (
    <div style={{ display: 'flex', alignItems: 'center', gap: 6 }}>
      {icon}
      <span className="label" style={{ flex: 1 }}>{label}</span>
      <span className="value" style={{ fontSize: 12 }}>{value}</span>
    </div>
  )
}

function Badge({ active, label, activeColor, inactiveColor }) {
  return (
    <div style={{
      fontSize: 9,
      padding: '2px 6px',
      borderRadius: 6,
      background: active ? (activeColor || 'rgba(91,141,239,0.25)') : 'rgba(255,255,255,0.06)',
      color: active ? '#fff' : 'var(--text-muted)',
      border: `1px solid ${active ? (activeColor || 'var(--primary)') : 'transparent'}`,
    }}>
      {label}
    </div>
  )
}
