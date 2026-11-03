import { useEffect, useState } from 'react';
import { createRoot } from 'react-dom/client';
import { isBrowser, nui, useKeys, useNuiMessage } from '../shared/nui';
import '../shared/cine.css';

interface Btn { label: string; action: string }
interface Open {
  server: string;
  buttons: Btn[];
  player: { name: string; job: string; grade?: string; cash: number; bank: number; id: number };
  online?: number;
  max?: number;
}

const money = (n: number) => '$' + Math.round(n).toLocaleString('en-US');
const DEMO: Open = {
  server: 'Project07',
  buttons: [{ label: 'Resume', action: 'resume' }, { label: 'Map', action: 'map' }, { label: 'Settings', action: 'settings' }, { label: 'Quit', action: 'quit' }],
  player: { name: 'Nimal Perera', job: 'Mechanic', grade: 'Lead', cash: 1250, bank: 48210, id: 12 },
  online: 38, max: 64,
};

function App() {
  const [data, setData] = useState<Open | null>(null);
  const [sel, setSel] = useState(0);
  const [armed, setArmed] = useState(false);
  const [clock, setClock] = useState(() => new Date());

  useNuiMessage((m) => {
    if (m.action === 'open') { setData(m.data as Open); setSel(0); setArmed(false); }
    else if (m.action === 'close') setData(null);
  });
  useEffect(() => { if (isBrowser) { document.body.classList.add('demo-bg'); setData(DEMO); } }, []);
  useEffect(() => { const id = setInterval(() => setClock(new Date()), 15000); return () => clearInterval(id); }, []);

  const run = (b: Btn) => {
    if (b.action === 'quit' && !armed) return setArmed(true);
    void nui('action', { action: b.action });
  };
  const close = () => { setData(null); void nui('close'); };
  useKeys((e) => {
    if (!data) return;
    if (e.key === 'Escape' || e.key === 'p' || e.key === 'P') close();
    else if (e.key === 'ArrowDown') { setSel((s) => Math.min(data.buttons.length - 1, s + 1)); setArmed(false); }
    else if (e.key === 'ArrowUp') { setSel((s) => Math.max(0, s - 1)); setArmed(false); }
    else if (e.key === 'Enter') run(data.buttons[sel]);
  });

  if (!data) return null;
  const p = data.player;
  return (
    <div className="cine">
      <div className="bar top"><small>{data.server}</small><small className="mono">{clock.toLocaleTimeString('en-GB', { hour: '2-digit', minute: '2-digit' })}</small></div>
      <div className="side">
        <div className="eyebrow">Paused</div>
        <div className="meta">
          <b>{p.name}</b>
          <span>{p.job}{p.grade ? ` · ${p.grade}` : ''} · ID {p.id}</span>
          <span>{money(p.cash)} cash · {money(p.bank)} bank</span>
        </div>
        <div className="list">
          {data.buttons.map((b, i) => (
            <button key={b.action + i} className={`item ${i === sel ? 'on' : ''}`} onMouseEnter={() => { setSel(i); if (b.action !== 'quit') setArmed(false); }} onClick={() => run(b)}>
              <span className="n">{String(i + 1).padStart(2, '0')}</span>
              <b>{b.action === 'quit' && armed ? 'Press again to quit' : b.label}</b>
            </button>
          ))}
        </div>
      </div>
      <div className="bar bottom">
        <small>{data.online != null ? `${data.online} / ${data.max} online` : ' '}</small>
        <div className="keys"><span className="key"><kbd>↑ ↓</kbd>Choose</span><span className="key"><kbd>Enter</kbd>Open</span><span className="key"><kbd>Esc</kbd>Resume</span></div>
      </div>
    </div>
  );
}

createRoot(document.getElementById('root')!).render(<App />);
