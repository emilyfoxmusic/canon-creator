\version "2.18.2"

\header {
title = "Untitled"
composer = "02"}
{
<<
\new Staff \with {
instrumentName = #"Saw"
}
{
\tempo 4 = 80
\transpose des des {
\clef treble
\time 4/4
\key des \major
aes'4 f'4 bes'4 f'4 ees'4 aes'8 bes'8 ees'4 aes'4 f'16 ges'16 f'16 aes'16 bes'16 ges'16 bes'16 f'16 f'4 des'4 c'8 aes16 c'16 aes4 ees8 bes8 aes4 f4 bes4 des'4 f'4 aes'4 f'8 f'8 c'4 des'4 aes16 aes16 aes16 ges16 f16 aes16 f16 ges16 des4 f4 ees16 ges16 ees8 des4 c8 des8 des4 R1 R1 }
}
\new Staff \with {
instrumentName = #"Pretty_bell"
}
{
\tempo 4 = 80
\transpose des des {
\clef treble
\time 4/4
\key des \major
R1 R1 aes'4 f'4 bes'4 f'4 ees'4 aes'8 bes'8 ees'4 aes'4 f'16 ges'16 f'16 aes'16 bes'16 ges'16 bes'16 f'16 f'4 des'4 c'8 aes16 c'16 aes4 ees8 bes8 aes4 f4 bes4 des'4 f'4 aes'4 f'8 f'8 c'4 des'4 aes16 aes16 aes16 ges16 f16 aes16 f16 ges16 des4 f4 ees16 ges16 ees8 des4 c8 des8 des4 }
}

>>
}
