# **FAQs**

### 1. Why some files are zipped
compressed original scattered files to avoid booming the repo

~~and raw bmp files are headaches.~~

nvm. just converted to LOSSLESS PNG **(Compression Ratio 2.67%)**

just decompress right in the place (tbh idk what u need these for, maybe just to admire some worst coding possible on earth)

```dataextraction/*/map/originaldata.zip```

### 2. Why a 'flip' folder in data extraction folder

you can say thats math. svg and godot engines run different coorinate systems, which has opposite y axis directions. 

so for the sanity of your coder's brain, we'll just flip the lookup texture vertically and do the whole thing again. (technically robust!)

### 3. What does each column in definition.csv mean? And why using csv?
- province id
- R
- G
- B
- type - land or sea
- isCostalprovince?
- terrain
- continent id

more at [hoi4 vanilla wiki](https://hoi4.paradoxwikis.com/Map_modding).

why using csv?

idk, maybe lurking us to learn 'how to use excel in python scripts'.

> ## **(fuck you paradox for your shitty code and data structures)**