# defend_the_donut

Everyone knows donuts are the most precious things in the Universe. However, our despicable enemies from the Empire are seeking to destroy such a beloved treasure. It's up to you to defend your donut from the Empire's ships. How long can you keep up?

<p align="center">
    <img width="50%" alt="image" src="https://github.com/user-attachments/assets/1cda6e43-1cd4-465f-8182-8b1a316f9554" />
</p>

## How to play

* Move the ship with WASD
* Move the camera with the mouse
* Left click to shoot (generates heat)
* Shift to boost (consumes energy)
* (TODO): locking
* (TODO): look around

## Setup

In order to run, you will need to follow [the pre-requisites for setting up flame_3d](https://github.com/flame-engine/flame/tree/main/packages/flame_3d#prerequisites); notably:

Enable Impeller by adding the following key to `/macos/Runner/Info.plist`:

```xml
<dict>
    ...
 <key>FLTEnableImpeller</key>
 <true/>
</dict>
```

And then run with:

```bash
flutter run -d macos --enable-flutter-gpu
```

## Credits

* Speeder/Enemy Ships from [Kenney's Space Kit](https://kenney-assets.itch.io/space-kit)
* Donuts from [Donut 1](https://poly.pizza/m/UQRRrsP3wj) | [Donut 2](https://poly.pizza/m/7_-6fUJOawi) | [Donut 3](https://poly.pizza/m/bn3ArZAOcpo) | [Donut 4](https://poly.pizza/m/8KY9R5UDV_M) | [Donut 5](https://poly.pizza/m/b8vyIvgJ705) (TODO download and import other donuts)
* SFX from [200+ Space Sound Effects](https://gamesupply.itch.io/200-space-sound-effects)
* The amazing [pointer_lock](https://github.com/helgoboss/pointer_lock) package by [Helgoboss](https://github.com/helgoboss)
