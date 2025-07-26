# oGlow TBC Classic (2.5.2)

A reverse-engineered and ported version of the original [oGlow](https://github.com/haste/oGlow) addon, adapted for the 2.5.2 TBC Classic client. This project revives the glow system for item quality across various UI frames.

> ⚠️ LUA is new to me — I'm primarily a web developer — so this is a learning project. That said, it's working well on two test machines!

## ✨ Features

- ✅ Merchant frame
- ✅ Inspect frame
- ✅ Character frame
- ✅ Bank frame
- ✅ Bags frame
- ✅ Trade window
- ❓ Guild bank — untested, help appreciated!

## 🔧 Modified Modules

| File          | Status                          |
|---------------|----------------------------------|
| `bags.lua`    | Working, confirmed up to epic quality |
| `char.lua`    | Working, confirmed up to epic quality |
| `inspect.lua` | Working, confirmed up to epic quality |
| `mail.lua`    | Works with rare items, needs retesting |
| `craft.lua`   | Rare items glow properly, more testing needed |
| `tradeskill.lua` | Partial success, similar to `craft.lua` |

## 📸 Screenshots

HDR was accidentally enabled — sorry! Not retaking them 😅

## 🛠️ Notes

- Original credit to [Haste](https://github.com/haste/oGlow)
- Edits and porting notes included in each module
- Feedback and contributions welcome via Issues or Pull Requests

## 🧪 Recent Fixes

- Bags module now places glow on correct bag slot ✅
- Inspect module now queries correctly on repeated inspections ✅

## 📦 Installation

1. Download or clone this repo
2. Place the `oGlow` folder in your `Interface/AddOns` directory
3. Restart WoW or reload UI

## 📄 License

This project is licensed under the **MIT License** — a permissive license that allows reuse, modification, and distribution with attribution. See [`LICENSE`](LICENSE) for details.