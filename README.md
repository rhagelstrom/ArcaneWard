
# Arcane Ward

[![Build FG Extension](https://github.com/rhagelstrom/ArcaneWard/actions/workflows/create-release.yml/badge.svg)](https://github.com/rhagelstrom/ArcaneWard/actions/workflows/create-release.yml) [![Luacheckrc](https://github.com/rhagelstrom/ArcaneWard/actions/workflows/luacheck.yml/badge.svg)](https://github.com/rhagelstrom/ArcaneWard/actions/workflows/luacheck.yml) [![Markdownlint](https://github.com/rhagelstrom/ArcaneWard/actions/workflows/markdownlint.yml/badge.svg)](https://github.com/rhagelstrom/ArcaneWard/actions/workflows/markdownlint.yml)

**Current Version:** ~dev-version~ \
**Updated:** ~date~

Arcane Ward is Fantasy Grounds extension for 5E that automates the School of Abjuration trait Arcane Ward. Also mostly automates legacy NPCs with the trait Arcane Ward. This extension also helps automate and track spell/pact slot usage. This extension is useful even if no one in the party is an Abjuration Wizard.

- An Actor can use their own arcane ward to protect another Actor with the effect ARCANEWARD
- You can upcast your spell or cast it as a ritual by holding shift and clicking the cast/arcane ward button
- Holding control and clicking the cast/arcane ward button will switch between Spell Slots and Pact Magic Slots. Must have Spellcasting and Pact Magic Features.

**Notes:**

- A PC character must have the feature "spellcasting" for the cast buttons to appear.
- A Warlock must have the feature "pact magic" for the cast buttons to appear for pact magic.
- An Abjuration Wizard must have both features "spellcasting" and "arcane ward".
- If a character has the feature "arcane ward", the cast powers buttons will always be enabled regardless of the option settings.

## Options

| Name| Default | Options | Notes |
|---|---|---|---|
|Default: Use Pact Magic Slots First| off| off/on| When on, will default spell powers to use Pact Magic spell slots first. Must have both Pact Magic and Spellcasting Features for this option to have any effect|
|Sheet: Show Cast Powers| off| off/on| When on, will add a button to spell powers will spell slots. When the button is pushed it will print an announcement message and use a spell slot|
|Sheet: Show Cast Powers All (GM)| off| off/on| When on, will force all players to have the spell powers button on their character sheet|
