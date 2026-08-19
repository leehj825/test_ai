export const POVS = ['kael', 'riena', 'damian', 'sein', 'rohar'] as const;
export type Pov = (typeof POVS)[number];

interface PovTheme {
  label: string;
  accent: string;
  accentSoft: string;
}

export const POV_THEME: Record<Pov, PovTheme> = {
  kael: { label: 'Kael', accent: '#3b82f6', accentSoft: '#eff6ff' },
  riena: { label: 'Riena', accent: '#e11d48', accentSoft: '#fff1f2' },
  damian: { label: 'Damian', accent: '#d97706', accentSoft: '#fffbeb' },
  sein: { label: 'Sein', accent: '#059669', accentSoft: '#ecfdf5' },
  rohar: { label: 'Rohar', accent: '#7c3aed', accentSoft: '#f5f3ff' },
};
