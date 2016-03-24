\version "2.18.2"

\header {
title = "Untitled"
composer = "06"}
{
<<
\new Staff \with {
instrumentName = #"Beep"
}
{
\tempo 4 = 70
\transpose e e {
\clef treble
\time 3/4
\key e \minor
e'4 d'8 c'16 d'16 g16 g16 g8 g,4 b,4 g,4 g4 b4 b,4 e,4 fis8 d8 g16 b16 d'16 b16 g'4 d''4 d''8 e''8 b'4 e'8 d'8 e8 b16 e16 b4 b,4 b,8 g,8 g4 c'8 b8 b'4 b'4 b8 c'8 g4 g,8 b,8 b,4 b4 e16 b16 e8 d'8 e'8 b'4 e''8 d''8 d''4 g'4 b16 d'16 b16 g16 d8 fis8 e,4 b,4 b4 g4 g,4 b,4 g,4 g8 g16 g16 d'16 c'16 d'8 e'4 R2. R2. R2. R2. }
}
\new Staff \with {
instrumentName = #"Saw"
}
{
\tempo 4 = 70
\transpose e e {
\clef treble
\time 3/4
\key e \minor
R2. R2. e'4 d'8 c'16 d'16 g16 g16 g8 g,4 b,4 g,4 g4 b4 b,4 e,4 fis8 d8 g16 b16 d'16 b16 g'4 d''4 d''8 e''8 b'4 e'8 d'8 e8 b16 e16 b4 b,4 b,8 g,8 g4 c'8 b8 b'4 b'4 b8 c'8 g4 g,8 b,8 b,4 b4 e16 b16 e8 d'8 e'8 b'4 e''8 d''8 d''4 g'4 b16 d'16 b16 g16 d8 fis8 e,4 b,4 b4 g4 g,4 b,4 g,4 g8 g16 g16 d'16 c'16 d'8 e'4 R2. R2. }
}
\new Staff \with {
instrumentName = #"Pretty_bell"
}
{
\tempo 4 = 70
\transpose e e {
\clef treble
\time 3/4
\key e \minor
R2. R2. R2. R2. e'4 d'8 c'16 d'16 g16 g16 g8 g,4 b,4 g,4 g4 b4 b,4 e,4 fis8 d8 g16 b16 d'16 b16 g'4 d''4 d''8 e''8 b'4 e'8 d'8 e8 b16 e16 b4 b,4 b,8 g,8 g4 c'8 b8 b'4 b'4 b8 c'8 g4 g,8 b,8 b,4 b4 e16 b16 e8 d'8 e'8 b'4 e''8 d''8 d''4 g'4 b16 d'16 b16 g16 d8 fis8 e,4 b,4 b4 g4 g,4 b,4 g,4 g8 g16 g16 d'16 c'16 d'8 e'4 }
}

>>
}
