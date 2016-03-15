\version "2.18.2"

\header {
title = "An Untitled Canon."
composer = "Anon."}
{
<<
\new Staff \with {
instrumentName = #"Saw"
}
{
\tempo 4 = 70
\transpose e e {
\clef treble
\time 3/4
\key e \minor
e'4 d'8 d'8 g'4 c''16 a'16 c''16 e''16 d''8 c''8 b'4 e''4 b'8 b'8 g'4 c''16 c''16 c''16 d''16 d''8 b'8 e''4 a''4 b''8 g''8 g''4 e''16 g''16 e''16 b'16 d''8 b'8 e''4 R2. }
}
\new Staff \with {
instrumentName = #"Pulse"
}
{
\tempo 4 = 70
\transpose e e {
\clef treble
\time 3/4
\key e \minor
R2. e'4 d'8 d'8 g'4 c''16 a'16 c''16 e''16 d''8 c''8 b'4 e''4 b'8 b'8 g'4 c''16 c''16 c''16 d''16 d''8 b'8 e''4 a''4 b''8 g''8 g''4 e''16 g''16 e''16 b'16 d''8 b'8 e''4 }
}

>>
}