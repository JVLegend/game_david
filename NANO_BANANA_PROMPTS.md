# Prompts Nano Banana - Davi: O Ungido
## Guia Otimizado para Geração de Assets

---

## DICAS IMPORTANTES ANTES DE USAR

### Problemas comuns e como resolver:

**1. Gera só 1 imagem ao invés de sprite sheet:**
- Adicione "sprite sheet, multiple frames, grid layout, 4x2 grid" no prompt
- Se ainda não funcionar, gere cada frame separado (idle, walk1, walk2, attack1, attack2)

**2. Personagem olhando para lado errado:**
- Sempre inclua "facing right, side view from left to right"
- No jogo podemos espelhar (flip horizontal) via código

**3. Frames incompletos:**
- Gere em lotes menores: primeiro "idle + walk" depois "attack"
- Ou gere 1 pose por vez e monte o sprite sheet depois

**4. Background quadrado ao invés de panorâmico:**
- Use "ultra wide panoramic, aspect ratio 4:1, horizontal banner"
- Ou gere 3-4 seções separadas e emende no jogo (parallax tiles)

**5. Estilo inconsistente entre gerações:**
- Sempre repita o estilo exato: "cartoon stylized semi-realistic, vibrant colors, thick outlines, 2D game art"

---

## ESTRATÉGIA RECOMENDADA

Em vez de gerar sprite sheets completos (que falham frequentemente), gere **cada pose individualmente** e monte o sprite sheet depois. Isso dá muito mais controle.

Para cada personagem/inimigo, gere:
1. Pose IDLE (parado)
2. Pose WALK (2 frames: perna esquerda frente / perna direita frente)
3. Pose ATTACK (2 frames: vento / impacto)
4. Pose HIT (tomando dano)
5. Pose DEATH (caindo)

Para backgrounds, gere **tiles separados** que se encaixam:
1. Tile de chão (repetível horizontalmente)
2. Camada de fundo distante (montanhas/céu) - panorâmico
3. Camada intermediária (árvores/objetos)
4. Elementos decorativos avulsos

---

## 1. PERSONAGEM PRINCIPAL - DAVI JOVEM

### 1.1 Davi - IDLE (parado)
```
Single character, 2D game art, young shepherd boy David age 16, facing right, side profile view, standing idle relaxed pose, tan olive skin, curly dark brown hair, wearing simple brown wool tunic with rope belt, leather sandals, holding wooden shepherd staff in right hand, cartoon stylized semi-realistic style, thick clean outlines, vibrant warm colors, solid white background, full body visible head to toe, game asset, centered in frame
```

### 1.2 Davi - WALK frame 1
```
Single character, 2D game art, young shepherd boy David age 16, facing right, side profile view, walking pose left leg forward right leg back, tan olive skin, curly dark brown hair, wearing simple brown wool tunic with rope belt, leather sandals, holding wooden shepherd staff in right hand, cartoon stylized semi-realistic style, thick clean outlines, vibrant warm colors, solid white background, full body visible, game asset
```

### 1.3 Davi - WALK frame 2
```
Single character, 2D game art, young shepherd boy David age 16, facing right, side profile view, walking pose right leg forward left leg back, tan olive skin, curly dark brown hair, wearing simple brown wool tunic with rope belt, leather sandals, holding wooden shepherd staff in right hand, cartoon stylized semi-realistic style, thick clean outlines, vibrant warm colors, solid white background, full body visible, game asset
```

### 1.4 Davi - ATTACK frame 1 (vento)
```
Single character, 2D game art, young shepherd boy David age 16, facing right, side profile view, attack wind-up pose, staff raised above head with both hands ready to strike, dynamic action pose, tan olive skin, curly dark brown hair, brown wool tunic, leather sandals, cartoon stylized semi-realistic style, thick clean outlines, vibrant warm colors, solid white background, full body visible, game asset
```

### 1.5 Davi - ATTACK frame 2 (impacto)
```
Single character, 2D game art, young shepherd boy David age 16, facing right, side profile view, attack strike pose, staff swung down forward at impact moment, dynamic action pose with motion lines, tan olive skin, curly dark brown hair, brown wool tunic, leather sandals, cartoon stylized semi-realistic style, thick clean outlines, vibrant warm colors, solid white background, full body visible, game asset
```

### 1.6 Davi - HIT (tomando dano)
```
Single character, 2D game art, young shepherd boy David age 16, facing right, side profile view, hurt flinching pose, leaning back slightly with pain expression, one arm raised defensively, tan olive skin, curly dark brown hair, brown wool tunic, leather sandals, cartoon stylized semi-realistic style, thick clean outlines, vibrant warm colors, solid white background, full body visible, game asset
```

### 1.7 Davi com Funda (para boss Golias)
```
Single character, 2D game art, young shepherd boy David age 16, facing right, side profile view, spinning a sling weapon overhead with right arm, determined fierce expression, tan olive skin, curly dark brown hair, wearing lion skin draped over brown tunic as armor, leather sandals, dynamic action pose, cartoon stylized semi-realistic style, thick clean outlines, vibrant warm colors, solid white background, full body visible, game asset
```

---

## 2. BigJ

### 2.1 BigJ - IDLE
```
Single character, 2D game art, young modern guy age 20, facing right, side profile view, standing confident idle pose with arms slightly apart, light skin, short dark hair, wearing dark charcoal grey crew neck t-shirt, medium blue denim bermuda shorts knee length, light grey flat cap beret, white sneakers, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible head to toe, game asset
```

### 2.2 BigJ - WALK frame 1
```
Single character, 2D game art, young modern guy age 20, facing right, side profile view, walking pose left leg forward, light skin, short dark hair, dark charcoal grey t-shirt, blue denim bermuda shorts, light grey flat cap beret, white sneakers, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game asset
```

### 2.3 BigJ - ATTACK frame 1
```
Single character, 2D game art, young modern guy age 20, facing right, side profile view, attack punch pose with right fist forward, aggressive dynamic stance, light skin, short dark hair, dark charcoal grey t-shirt, blue denim bermuda shorts, light grey flat cap beret, white sneakers, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game asset
```

### 2.4 BigJ - ATTACK frame 2
```
Single character, 2D game art, young modern guy age 20, facing right, side profile view, attack kick pose with right leg extended forward, dynamic action pose, light skin, short dark hair, dark charcoal grey t-shirt, blue denim bermuda shorts, light grey flat cap beret, white sneakers, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game asset
```

---

## 3. INIMIGOS - MAPA 1

### 3.1 Lobo Cinzento - IDLE
```
Single creature, 2D game art, grey wolf standing alert, facing left, side profile view, aggressive stance with slightly lowered head, baring teeth, grey fur with darker back, yellow piercing eyes, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 3.2 Lobo Cinzento - ATTACK
```
Single creature, 2D game art, grey wolf lunging to bite, facing left, side profile view, mouth wide open attacking, front paws off ground in mid-leap, grey fur, yellow eyes, dynamic attack pose, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 3.3 Lobo Alfa - IDLE
```
Single creature, 2D game art, large alpha wolf, facing left, side profile view, proud dominant stance, dark grey almost black fur, scars across face, glowing red eyes, larger and more muscular than normal wolf, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 3.4 Lobo Alfa - HOWLING
```
Single creature, 2D game art, large alpha wolf howling, facing left, side profile view, head tilted up howling at sky, mouth open, dark grey fur with scars, red eyes, glowing aura effect around body, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 3.5 Raposa Raivosa - IDLE
```
Single creature, 2D game art, rabid aggressive fox, facing left, side profile view, hunched attack stance, orange-red fur, foaming mouth, wild crazed eyes, bushy tail raised, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 3.6 Chacal Faminto - IDLE
```
Single creature, 2D game art, hungry thin jackal, facing left, side profile view, stalking low stance, sandy brown fur, visible ribs showing hunger, yellow predator eyes, large pointed ears, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 3.7 Javali Selvagem - IDLE
```
Single creature, 2D game art, large wild boar, facing left, side profile view, aggressive stance pawing at ground ready to charge, dark brown bristly fur, large curved tusks, small angry red eyes, muscular stocky body, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 3.8 Javali Selvagem - CHARGE ATTACK
```
Single creature, 2D game art, large wild boar charging, facing left, side profile view, full speed running charge attack, hooves off ground, dust clouds behind, tusks pointed forward, dark brown bristly fur, motion blur lines, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 3.9 Serpente Venenosa - IDLE
```
Single creature, 2D game art, venomous snake coiled, facing left, side profile view, upper body raised in S-curve strike position, hood slightly flared, bright green scales with yellow diamond pattern, forked tongue out, menacing eyes, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 3.10 Serpente Venenosa - ATTACK
```
Single creature, 2D game art, venomous snake striking, facing left, side profile view, head lunging forward fangs exposed, venom dripping from fangs, body uncoiled in strike motion, green scales with yellow pattern, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 3.11 Águia Caçadora - IDLE (voando)
```
Single creature, 2D game art, large hunting eagle in flight, facing left, side profile view, wings spread wide soaring, brown feathers with golden-white head, sharp yellow beak, fierce eyes, talons visible, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 3.12 Águia Caçadora - DIVE ATTACK
```
Single creature, 2D game art, hunting eagle in diving attack, facing left and downward at 45 degree angle, wings tucked back in dive bomb pose, talons extended forward to grab, brown feathers golden head, speed lines around body, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 3.13 Escorpião Gigante - IDLE
```
Single creature, 2D game art, giant scorpion size of a dog, facing left, side profile view, combat stance with claws raised and stinger tail curved overhead ready to strike, dark brown chitinous exoskeleton, eight legs, menacing pincers, glowing stinger tip, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 3.14 Hiena Matilheira - IDLE
```
Single creature, 2D game art, spotted hyena, facing left, side profile view, aggressive laughing stance with mouth open showing teeth, spotted brown and tan fur, rounded ears, hunched back typical hyena posture, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

---

## 4. BOSS MAPA 1 - LEÃO

### 4.1 Leão - IDLE
```
Single creature, 2D game art, majestic fierce male lion, facing left, side profile view, powerful proud standing pose, massive golden mane, muscular tawny body, intense amber eyes, tail swishing, large paws, much larger than other enemies scale 1.5x, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game boss asset, highly detailed
```

### 4.2 Leão - ROAR
```
Single creature, 2D game art, fierce male lion roaring, facing left, side profile view, head tilted slightly up, mouth wide open showing massive fangs, roaring with visible sound wave effect, golden mane flowing, muscular body tensed, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game boss asset
```

### 4.3 Leão - PAW SWIPE ATTACK
```
Single creature, 2D game art, male lion attacking with paw swipe, facing left, side profile view, right paw extended forward in powerful slash, claws fully extended, aggressive expression, golden mane, muscular body in attack lunge, motion lines on paw, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game boss asset
```

### 4.4 Leão - LEAP ATTACK
```
Single creature, 2D game art, male lion in mid-air leap attack, facing left, side profile view, all four paws off ground leaping forward, claws out, mouth open, golden mane flowing with motion, dynamic powerful pose, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game boss asset
```

### 4.5 Leão - PHASE 2 (Fúria - olhos vermelhos)
```
Single creature, 2D game art, enraged male lion, facing left, side profile view, aggressive low crouch attack stance, glowing red eyes, mane bristling and raised, red aura glow around body indicating fury mode, muscles more defined, larger appearance, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors with red tones, solid white background, full body visible, game boss asset
```

---

## 5. INIMIGOS - MAPA 2

### 5.1 Filhote de Urso - IDLE
```
Single creature, 2D game art, young brown bear cub, facing left, side profile view, standing on hind legs in clumsy combat stance, small claws visible, round fuzzy body, cute but slightly aggressive expression, brown fur, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 5.2 Urso Pardo (Sub-Boss) - IDLE
```
Single creature, 2D game art, massive brown bear standing on hind legs, facing left, side profile view, towering intimidating pose, arms spread wide showing huge claws, roaring mouth open, thick dark brown fur, muscular body, scars on chest, much larger than other enemies 1.5x scale, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game sub-boss asset, detailed
```

### 5.3 Urso Pardo - BEAR HUG ATTACK
```
Single creature, 2D game art, massive brown bear grabbing forward, facing left, side profile view, both arms reaching forward to grab and crush, mouth open roaring, dark brown fur, huge claws, aggressive lunging pose, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game sub-boss asset
```

### 5.4 Batedor Filisteu com Lança - IDLE
```
Single character, 2D game art, ancient Philistine scout soldier, facing left, side profile view, standing guard pose, holding bronze-tipped spear upright in right hand, wearing bronze pointed helmet, bronze chest plate over leather tunic, leather battle skirt, leather sandals with shin guards, muscular Middle Eastern warrior, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 5.5 Batedor Filisteu com Arco - IDLE
```
Single character, 2D game art, ancient Philistine archer, facing left, side profile view, aiming composite bow with arrow drawn, quiver of arrows on back, light bronze armor on chest, leather arm guards, bronze helmet, leather battle skirt, sandals, focused aiming expression, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 5.6 Batedor Filisteu com Escudo - IDLE
```
Single character, 2D game art, ancient Philistine shield bearer, facing left, side profile view, defensive stance with large round bronze shield held in left arm covering body, short bronze sword in right hand, heavy bronze armor, decorated helmet, leather battle skirt, sturdy build, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 5.7 Soldado Filisteu - IDLE
```
Single character, 2D game art, Philistine infantry soldier, facing left, side profile view, ready combat stance, bronze scale armor covering torso, iron sword in right hand, small round shield on left arm, feathered bronze helmet, red cloth under armor, leather battle skirt, sandals, battle-hardened expression, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 5.8 Soldado Filisteu Elite - IDLE
```
Single character, 2D game art, elite Philistine warrior officer, facing left, side profile view, proud combat stance, ornate decorated bronze armor with gold details, large iron sword, red flowing cape, elaborate helmet with red plume feather, leather battle skirt with metal studs, taller and more imposing than regular soldiers, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

### 5.9 Curandeiro Filisteu - IDLE
```
Single character, 2D game art, Philistine healer priest, facing left, side profile view, mystical casting pose with one hand raised glowing green, wearing dark purple robes with gold trim, holding wooden staff with glowing green crystal orb on top, hood partially covering face, mysterious expression, jewelry and amulets, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors with green glow effect, solid white background, full body visible, game enemy asset
```

### 5.10 Arqueiro Filisteu - IDLE
```
Single character, 2D game art, Philistine war archer, facing left, side profile view, aiming flaming arrow on composite bow, medium bronze chest armor, leather arm guards, quiver on back, bronze helmet, focused determined expression, flame on arrow tip glowing orange, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game enemy asset
```

---

## 6. BOSS MAPA 2 - GOLIAS

### 6.1 Golias - IDLE
```
Single character, 2D game art, Goliath the biblical giant warrior, facing left, side profile view, standing imposing pose, MASSIVE body 3 times taller than normal character, extremely muscular, full bronze scale mail armor covering entire torso, bronze greaves on legs, large bronze helmet with nose guard, carrying enormous iron-tipped spear in right hand, huge round bronze shield on back, heavy leather battle skirt with metal plates, fierce intimidating scowling face with thick black beard, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible head to toe, game final boss asset, highly detailed
```

### 6.2 Golias - SPEAR THROW
```
Single character, 2D game art, Goliath giant warrior throwing spear, facing left, side profile view, right arm pulled back in throwing position about to launch massive spear, left foot forward in throwing stance, enormous muscular body, bronze armor, bronze helmet, fierce expression, dynamic powerful throw pose, motion lines, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game boss asset
```

### 6.3 Golias - STOMP ATTACK
```
Single character, 2D game art, Goliath giant warrior stomping ground, facing left, side profile view, right foot raised high about to slam down, both arms raised, ground cracking beneath, shockwave dust effect around feet, enormous muscular body, bronze armor, bronze helmet, angry roaring expression, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game boss asset
```

### 6.4 Golias - SHIELD BLOCK
```
Single character, 2D game art, Goliath giant warrior blocking with huge shield, facing left, side profile view, crouched behind enormous bronze round shield held in left arm covering most of body, only eyes visible above shield edge, defensive stance, bronze armor, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors, solid white background, full body visible, game boss asset
```

### 6.5 Golias - PHASE 3 (Fúria)
```
Single character, 2D game art, Goliath giant warrior in rage mode, facing left, side profile view, charging forward in aggressive running pose, shield discarded, swinging spear like club with both hands, red glowing eyes, red aura around body, veins visible on arms, bronze armor partially damaged showing battle wear, furious screaming expression, cartoon stylized semi-realistic style, thick clean outlines, vibrant colors with red rage tones, solid white background, full body visible, game boss asset
```

---

## 7. BACKGROUNDS (Gerar como TILES separados)

### IMPORTANTE: Gere cada camada separadamente para montar parallax no jogo

### 7.1 Mapa 1 - Campos de Belém

#### Camada 3 (fundo distante - céu e montanhas)
```
2D game background layer, distant mountains and golden sunset sky, biblical ancient Israel landscape, rolling soft purple-blue mountains on horizon, warm golden orange sunset sky with soft clouds, NO ground NO trees NO objects in foreground, only sky and distant mountains, ultra wide panoramic horizontal image, aspect ratio 4 to 1 very wide, seamless tileable left to right edges match, cartoon stylized art, vibrant warm colors, game parallax background layer, clean
```

#### Camada 2 (meio - colinas e árvores)
```
2D game background layer, middle ground hills with olive trees, biblical Bethlehem countryside, gentle rolling green hills with scattered olive trees and cypress trees, ancient low stone walls, a few sheep grazing small in distance, NO sky NO close ground, transparent or simple gradient top and bottom, ultra wide panoramic horizontal image, aspect ratio 4 to 1 very wide, seamless tileable left to right, cartoon stylized art, vibrant warm green and golden colors, game parallax middle layer
```

#### Camada 1 (frente - chão onde personagem anda)
```
2D game ground platform layer, biblical countryside dirt path with grass, horizontal ground surface, brown dirt path in center, green grass patches on sides, small wildflowers, scattered pebbles, flat walking surface for side-scrolling game character, ultra wide panoramic horizontal image, aspect ratio 6 to 1 very wide, seamless tileable left to right edges match perfectly, cartoon stylized art, vibrant earthy colors, game foreground ground layer, transparent above ground line
```

### 7.2 Mapa 2 - Vale de Elá

#### Camada 3 (fundo distante)
```
2D game background layer, dramatic rocky mountains and cloudy sky, biblical Valley of Elah landscape, jagged brown-grey rocky mountains, dramatic grey and dark clouds, some sunlight breaking through clouds, tense atmospheric battlefield sky, NO ground NO objects, only sky and distant mountains, ultra wide panoramic horizontal image, aspect ratio 4 to 1 very wide, seamless tileable left to right, cartoon stylized art, muted dramatic colors, game parallax background layer
```

#### Camada 2 (meio - acampamentos)
```
2D game background layer, ancient military encampment, biblical era tents and banners on both sides, left side Israelite camp with brown tents and blue banners, right side Philistine camp with darker tents and red banners, rocky terrain between, dry riverbed with stones in middle, NO sky NO close ground, ultra wide panoramic horizontal image, aspect ratio 4 to 1 very wide, seamless tileable left to right, cartoon stylized art, earthy muted colors with tent color accents, game parallax middle layer
```

#### Camada 1 (frente - chão)
```
2D game ground platform layer, rocky battlefield terrain, horizontal ground surface, dry cracked earth with scattered smooth river stones, some dried grass patches, rock formations on edges, flat walking surface for side-scrolling game, ultra wide panoramic horizontal image, aspect ratio 6 to 1 very wide, seamless tileable left to right edges match perfectly, cartoon stylized art, dry brown and grey earthy colors, game foreground ground layer, transparent above ground line
```

---

## 8. MAPA OVERWORLD
```
2D game overworld map illustration, top-down bird eye view, biblical ancient Israel regions map, hand-drawn illustrated style, parchment paper background texture, green fields area labeled Bethlehem bottom left transitioning to rocky valley area labeled Valley of Elah center, dotted path connecting 8 circular battle nodes, small illustrated icons at each node showing the battle type, decorative compass rose in corner, ornate border frame, warm aged parchment colors with green brown and gold, cartoon stylized art, game map asset, 16 by 9 aspect ratio wide
```

---

## 9. ÍCONES DE ITENS

### DICA: Gere cada grupo de 4-6 itens por vez para manter consistência

### 9.1 Armas - Grupo 1 (iniciais)
```
2D game item icons, 4 weapon icons arranged in 2x2 grid on white background, each icon separate and clean: top-left wooden shepherd staff with leather grip, top-right reinforced wooden staff with metal bands, bottom-left small bronze shearing knife, bottom-right rough wooden club with nails, each item on its own with clear separation, cartoon stylized art, thick outlines, vibrant colors, transparent background, game asset icons, 512x512 pixels
```

### 9.2 Armas - Grupo 2 (bronze)
```
2D game item icons, 4 weapon icons arranged in 2x2 grid on white background, each icon separate: top-left bronze dagger with leather handle, top-right short bronze sword with crossguard, bottom-left iron mace with wooden handle, bottom-right curved Philistine sword with decorations, clean separated icons, cartoon stylized art, thick outlines, vibrant colors, transparent background, game asset icons
```

### 9.3 Armas - Grupo 3 (avançadas)
```
2D game item icons, 4 weapon icons arranged in 2x2 grid on white background, each icon separate: top-left ornate iron sword with gold pommel, top-right elegant silver royal sword with gems, bottom-left glowing seraph blade with holy light, bottom-right magnificent golden King David sword with ruby, clean separated icons, cartoon stylized art, thick outlines, vibrant colors with glow effects on legendary items, transparent background, game asset icons
```

### 9.4 Armas 2 Mãos - Grupo 1
```
2D game item icons, 4 two-handed weapon icons arranged in 2x2 grid on white background, each icon separate: top-left large cedar wood staff, top-right bronze-tipped wooden spear, bottom-left simple wooden bow with arrows, bottom-right large lumberjack axe with wooden handle, clean separated icons, cartoon stylized art, thick outlines, vibrant colors, transparent background, game asset icons
```

### 9.5 Armas 2 Mãos - Grupo 2 (especiais)
```
2D game item icons, 4 legendary weapon icons arranged in 2x2 grid on white background, each icon separate: top-left MASSIVE Goliath sword enormous blade with bronze handle, top-right ornate war bow with gold details, bottom-left glowing divine battle axe with holy light, bottom-right legendary Moses staff with golden serpent and light glow, clean separated icons, cartoon stylized art, thick outlines, vibrant colors with golden glow effects, transparent background, game asset icons
```

### 9.6 Armaduras - Grupo 1
```
2D game item icons, 4 armor icons arranged in 2x2 grid on white background, each icon separate: top-left simple brown wool shepherd tunic, top-right tanned leather vest, bottom-left lion skin draped armor with mane visible, bottom-right bronze chain mail shirt, clean separated icons, cartoon stylized art, thick outlines, vibrant colors, transparent background, game asset icons
```

### 9.7 Armaduras - Grupo 2
```
2D game item icons, 4 armor icons arranged in 2x2 grid on white background, each icon separate: top-left iron scale armor, top-right ornate royal bronze plate armor with gold trim, bottom-left glowing archangel breastplate with wing motifs, bottom-right magnificent golden sacred king mantle with holy glow, clean separated icons, cartoon stylized art, thick outlines, vibrant colors, transparent background, game asset icons
```

### 9.8 Escudos
```
2D game item icons, 4 shield icons arranged in 2x2 grid on white background, each icon separate: top-left rough wooden round shield with metal rim, top-right bronze round shield with boss center, bottom-left large iron tower shield rectangular, bottom-right ornate golden Ark sacred shield with angel wings motif and holy glow, clean separated icons, cartoon stylized art, thick outlines, vibrant colors, transparent background, game asset icons
```

### 9.9 Capacetes
```
2D game item icons, 4 helmet icons arranged in 2x2 grid on white background, each icon separate: top-left simple cloth head band, top-right leather hood cap, bottom-left bronze Philistine pointed helmet, bottom-right ornate golden crown of the anointed with gems and holy glow, clean separated icons, cartoon stylized art, thick outlines, vibrant colors, transparent background, game asset icons
```

### 9.10 Acessórios (Anéis + Colares)
```
2D game item icons, 4 accessory icons arranged in 2x2 grid on white background, each icon separate: top-left simple copper ring, top-right gold ring with blue gem, bottom-left wool cord necklace with bone pendant, bottom-right golden ornate Ark covenant necklace with holy glow, clean separated icons, cartoon stylized art, thick outlines, vibrant colors, transparent background, game asset icons
```

### 9.11 Botas e Luvas
```
2D game item icons, 4 equipment icons arranged in 2x2 grid on white background, each icon separate: top-left simple leather sandals, top-right bronze greaves leg armor, bottom-left cloth hand wraps, bottom-right ornate golden gauntlets with holy glow, clean separated icons, cartoon stylized art, thick outlines, vibrant colors, transparent background, game asset icons
```

---

## 10. COMIDAS (Itens de cura)

### 10.1 Comidas - Grupo 1 (básicas)
```
2D game item icons, 4 biblical food icons arranged in 2x2 grid on white background, each icon separate and appetizing: top-left round barley bread loaf golden brown crusty, top-right bunch of purple grapes on vine, bottom-left plate of dried brown figs, bottom-right small bowl of green olives in golden olive oil, clean separated icons, cartoon stylized art, thick outlines, vibrant warm appetizing colors, transparent background, game food item icons
```

### 10.2 Comidas - Grupo 2 (intermediárias)
```
2D game item icons, 4 biblical food icons arranged in 2x2 grid on white background, each icon separate and appetizing: top-left bread loaf drizzled with golden honey, top-right cut open red pomegranate showing seeds, bottom-left round wheel of white goat cheese, bottom-right cluster of brown sweet dates, clean separated icons, cartoon stylized art, thick outlines, vibrant warm appetizing colors, transparent background, game food item icons
```

### 10.3 Comidas - Grupo 3 (avançadas)
```
2D game item icons, 4 biblical food icons arranged in 2x2 grid on white background, each icon separate and appetizing: top-left clay bowl of brown cooked lentils steaming, top-right whole roasted fish on plate with herbs, bottom-left small decorated raisin cake, bottom-right large roasted lamb leg on platter with garnish, clean separated icons, cartoon stylized art, thick outlines, vibrant warm appetizing colors, transparent background, game food item icons
```

### 10.4 Comidas - Grupo 4 (lendárias)
```
2D game item icons, 3 biblical legendary food icons on white background, each icon separate: left glowing white heavenly manna bread with divine golden light aura, center magnificent royal feast platter with multiple foods and golden goblet, right ethereal celestial banquet plate glowing with holy white and gold light surrounded by small stars, clean separated icons, cartoon stylized art, thick outlines, vibrant colors with holy glow effects, transparent background, game legendary food item icons
```

---

## 11. UI ELEMENTS

### 11.1 Botões de Madeira
```
2D game UI elements, set of wooden buttons for biblical themed game, 4 button styles: rectangular wood plank button with bronze nail corners, round wood button with bronze rim, small square icon button with bronze frame, long banner shaped button with ornate bronze decorations, all buttons warm brown wood texture with visible grain, bronze metal accents, each button separate on white background, cartoon stylized art, game UI asset
```

### 11.2 Painéis e Frames
```
2D game UI elements, set of panels and frames for biblical themed game, 3 panel styles: large rectangular panel with dark wood frame and parchment paper interior, small tooltip popup with bronze corners on dark background, inventory slot square with bronze border and dark interior, clean separated elements on white background, cartoon stylized art, warm brown and bronze colors, game UI asset
```

### 11.3 Barras (HP, XP, Progress)
```
2D game UI elements, set of status bars for biblical themed game, 4 bar styles: health bar red fill with dark frame and bronze end caps, XP bar golden fill with ornate frame, progress bar orange fill, mana-food bar green fill, each bar showing full and empty state, dark background frame with bronze decorations, clean separated elements on white background, cartoon stylized art, game UI asset
```

### 11.4 Ícones de Moeda
```
2D game UI elements, currency icons for biblical themed game, 2 icons: gold coin with Star of David embossed on face showing shine and depth, red ruby gem faceted and glowing with inner light, each icon separate large and detailed on white background, cartoon stylized art, vibrant metallic colors, game UI asset
```

### 11.5 Cartas de Bônus
```
2D game card designs, 3 bonus cards for biblical themed game arranged side by side: left card showing red healing potion bottle with mystical glow titled BLESSING, center card showing hammer and anvil with sparks titled REPAIR, right card showing glowing green dagger titled CRITICAL, each card has ornate bronze frame border with parchment interior, cartoon stylized art, vibrant colors with magical glow effects, dark background behind cards, game card asset
```

---

## CHECKLIST DE ASSETS NECESSÁRIOS

### Personagens (gerar cada pose separada):
- [ ] Davi: idle, walk x2, attack x2, hit, sling
- [ ] BigJ: idle, walk x2, attack x2, hit

### Inimigos Mapa 1 (idle + attack cada):
- [ ] Lobo Cinzento: idle, attack
- [ ] Lobo Alfa: idle, howl
- [ ] Raposa Raivosa: idle
- [ ] Chacal Faminto: idle
- [ ] Javali Selvagem: idle, charge
- [ ] Serpente Venenosa: idle, attack
- [ ] Águia Caçadora: idle, dive
- [ ] Escorpião Gigante: idle
- [ ] Hiena Matilheira: idle

### Boss Mapa 1:
- [ ] Leão: idle, roar, paw swipe, leap, phase 2 fury

### Inimigos Mapa 2 (idle cada):
- [ ] Filhote de Urso: idle
- [ ] Urso Pardo: idle, bear hug
- [ ] Batedor Filisteu Lança: idle
- [ ] Batedor Filisteu Arco: idle
- [ ] Batedor Filisteu Escudo: idle
- [ ] Soldado Filisteu: idle
- [ ] Soldado Elite: idle
- [ ] Curandeiro Filisteu: idle
- [ ] Arqueiro Filisteu: idle

### Boss Mapa 2:
- [ ] Golias: idle, spear throw, stomp, shield block, phase 3 fury

### Backgrounds (3 camadas cada):
- [ ] Mapa 1: céu, colinas, chão
- [ ] Mapa 2: céu, acampamentos, chão

### Overworld:
- [ ] Mapa ilustrado

### Ícones (grupos de 4):
- [ ] Armas grupo 1, 2, 3
- [ ] Armas 2 mãos grupo 1, 2
- [ ] Armaduras grupo 1, 2
- [ ] Escudos
- [ ] Capacetes
- [ ] Acessórios
- [ ] Botas e Luvas
- [ ] Comidas grupo 1, 2, 3, 4

### UI:
- [ ] Botões
- [ ] Painéis
- [ ] Barras
- [ ] Moedas
- [ ] Cartas de bônus

**Total estimado: ~70 gerações no Nano Banana**
