\version "2.18.2"

\header {
title = "Canon Four"
composer = "Canon Creator: 18726129"}
{
<<
\new Staff \with {
instrumentName = #"Beep"
}
{
\tempo 4 = 60
\transpose gis gis {
\clef treble
\time 3/4
\key gis \minor
dis8 fis8 fis16 ais16 fis8 gis4 b4 dis'8 e'16 dis'16 gis'4 b'4 fis'16 cis'16 fis'8 dis'4 gis'8 dis'8 dis'8 ais8 b4 gis4 fis4 gis4 b16 gis16 b16 e'16 dis'4 gis'4 R2. }
}
\new Staff \with {
instrumentName = #"Pretty_bell"
}
{
\tempo 4 = 60
\transpose gis gis {
\clef treble
\time 3/4
\key gis \minor
R2. dis8 fis8 fis16 ais16 fis8 gis4 b4 dis'8 e'16 dis'16 gis'4 b'4 fis'16 cis'16 fis'8 dis'4 gis'8 dis'8 dis'8 ais8 b4 gis4 fis4 gis4 b16 gis16 b16 e'16 dis'4 gis'4 }
}

>>
}
