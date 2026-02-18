# PRD - Davi: O Ungido
### Jogo Side-Scrolling AFK para iOS (SpriteKit/Swift)

---

## 1. Visão Geral

**Nome:** Davi: O Ungido
**Gênero:** Side-Scrolling AFK RPG
**Plataforma:** iOS (SpriteKit + Swift)
**Estilo Visual:** Cartoon estilizado (semi-realista, cores vibrantes)
**Monetização:** Free-to-Play (Ouro + Rubis + Ads opcionais)

**Idiomas:** Português (BR) e Inglês (seleção na primeira abertura + configurações)
**Autenticação:** Google Auth (Firebase Authentication)
**Save:** Progresso salvo automaticamente na nuvem (Firestore)

**Premissa:** O jogador controla Davi, desde jovem pastor até rei de Israel, atravessando 7 mapas bíblicos com batalhas progressivas, equipamentos colecionáveis e combate automático estratégico. Ao completar mapas, personagens alternativos podem ser desbloqueados na loja.

---

## 2. Core Gameplay

### 2.1 Mecânica Principal
- **Side-scrolling automático**: Davi corre da esquerda para a direita automaticamente
- **Auto-ataque**: Ao chegar próximo ao inimigo, Davi ataca automaticamente
- **Habilidades ativas**: O jogador ativa habilidades especiais tocando botões na HUD (até 3 slots)
- **Progressão por equipamento**: A força do Davi depende dos itens equipados
- **Loot e Loja**: Inimigos dropam ouro e itens; loja oferece equipamentos melhores

### 2.2 Fluxo de Batalha
1. Jogador seleciona uma batalha no mapa
2. Davi entra no cenário correndo da esquerda
3. Inimigos aparecem sequencialmente (até 4 por batalha)
4. Davi auto-ataca; jogador usa habilidades e comidas de cura
5. Ao derrotar todos os inimigos, recebe recompensas (ouro, XP, chance de loot)
6. Ao final de cada batalha, escolhe 1 de 3 cartas de bônus temporário (válido para o mapa atual)

### 2.3 Atributos do Personagem
| Atributo | Descrição |
|---|---|
| **HP** | Pontos de vida |
| **Dano** | Dano base por ataque (min-max) |
| **Chance Crítica** | % de chance de acerto crítico |
| **Dano Crítico** | Multiplicador do dano crítico |
| **Armadura** | Redução de dano recebido |
| **Esquiva Corpo a Corpo** | % de chance de esquivar ataques melee |
| **Esquiva à Distância** | % de chance de esquivar projéteis |
| **Velocidade de Ataque** | Intervalo entre ataques |
| **Velocidade de Corrida** | Velocidade de deslocamento |
| **Roubo de Vida** | % do dano convertido em HP |

---

## 3. Estrutura dos Mapas

### Visão Geral (7 Mapas)
| Mapa | Tema | Nº Batalhas | Boss Final | Unlock |
|---|---|---|---|---|
| 1 | Campos de Belém | 3 + Boss | Leão | Início |
| 2 | Vale de Elá | 3 + Boss | Golias | Completar Mapa 1 |
| 3 | Corte de Saul | 3 + Boss | Saul Enlouquecido | Completar Mapa 2 |
| 4 | Deserto de En-Gedi | 3 + Boss | General de Saul | Completar Mapa 3 |
| 5 | Terra dos Filisteus | 3 + Boss | Príncipe Filisteu | Completar Mapa 4 |
| 6 | Cerco de Jerusalém | 3 + Boss | Comandante Jebuseu | Completar Mapa 5 |
| 7 | Trono de Israel | 3 + Boss | Absalão | Completar Mapa 6 |

### 3.1 MAPA 1 — Campos de Belém
**Cenário:** Campos verdes com colinas, ovelhas ao fundo, céu dourado de entardecer.
**Narrativa:** Davi é um jovem pastor protegendo seu rebanho de animais selvagens.
**Arma inicial:** Cajado de Madeira de Pastor

#### Batalha 1.1 — Alcateia dos Campos
| Inimigo | HP | Dano | Tipo | Habilidade |
|---|---|---|---|---|
| Lobo Cinzento | 30 | 5-8 | Melee | Mordida (dano + sangramento leve) |
| Lobo Cinzento | 30 | 5-8 | Melee | Mordida |
| Lobo Alfa | 50 | 8-12 | Melee | Uivo (buff ataque aliados +20%) |
| — | — | — | — | — |
**Recompensa:** 50 Ouro, 20 XP, chance de drop: Sandálias de Couro

#### Batalha 1.2 — Invasores Noturnos
| Inimigo | HP | Dano | Tipo | Habilidade |
|---|---|---|---|---|
| Raposa Raivosa | 25 | 4-7 | Melee | Esquiva natural (+15% esquiva) |
| Chacal Faminto | 35 | 6-9 | Melee | Ataque duplo (2 hits rápidos) |
| Javali Selvagem | 60 | 10-14 | Melee | Investida (dano em área, stun 1s) |
| Serpente Venenosa | 20 | 3-5 | Ranged | Veneno (DoT 3s) |
**Recompensa:** 80 Ouro, 30 XP, chance de drop: Faixa de Cabeça Simples

#### Batalha 1.3 — A Trilha da Montanha
| Inimigo | HP | Dano | Tipo | Habilidade |
|---|---|---|---|---|
| Águia Caçadora | 25 | 7-10 | Ranged | Mergulho (ataque aéreo, ignora armadura) |
| Escorpião Gigante | 40 | 6-9 | Melee | Ferrão (veneno + slow) |
| Hiena Matilheira | 35 | 5-8 | Melee | Invoca 1 Hiena Filhote (15 HP) |
| Hiena Matilheira | 35 | 5-8 | Melee | Invoca 1 Hiena Filhote (15 HP) |
**Recompensa:** 100 Ouro, 40 XP, chance de drop: Cajado Reforçado

#### BOSS 1.4 — O Leão de Belém 🦁
| Atributo | Valor |
|---|---|
| **HP** | 250 |
| **Dano** | 15-25 |
| **Armadura** | 10 |
| **Velocidade** | Rápida |
| **Fase 1 (100%-50% HP)** | Patada (dano normal), Rugido (reduz ataque do Davi -15% por 5s) |
| **Fase 2 (50%-0% HP)** | Fúria do Leão (velocidade ataque +50%), Salto Mortal (dano massivo, precisa esquivar) |
**Recompensa:** 300 Ouro, 100 XP, **drop garantido:** Pele de Leão (couraça especial, +8 Armadura, +5% Esquiva Melee)

---

### 3.2 MAPA 2 — Vale de Elá
**Cenário:** Vale rochoso com rio ao centro, acampamento israelita de um lado, filisteu do outro.
**Narrativa:** Davi vai ao acampamento levar comida aos irmãos e acaba enfrentando o desafio de Golias.

#### Batalha 2.1 — Sub-Boss: O Urso das Montanhas 🐻
| Inimigo | HP | Dano | Tipo | Habilidade |
|---|---|---|---|---|
| Filhote de Urso | 40 | 6-9 | Melee | Arranhão |
| Filhote de Urso | 40 | 6-9 | Melee | Arranhão |
| **Urso Pardo (Sub-Boss)** | **180** | **12-20** | **Melee** | **Abraço de Urso (grab, dano contínuo 3s), Golpe de Garra (dano + reduz armadura -5)** |
**Recompensa:** 200 Ouro, 60 XP, chance de drop: Cinto de Pele de Urso (+10 HP, +3 Armadura)

#### Batalha 2.2 — Batedores Filisteus
| Inimigo | HP | Dano | Tipo | Habilidade |
|---|---|---|---|---|
| Batedor Filisteu (Lança) | 50 | 8-12 | Melee | Estocada (alcance médio) |
| Batedor Filisteu (Arco) | 35 | 6-10 | Ranged | Flecha Rápida (2 projéteis) |
| Batedor Filisteu (Escudo) | 70 | 5-8 | Melee | Bloqueio (+50% armadura temporária) |
| Batedor Filisteu (Lança) | 50 | 8-12 | Melee | Estocada |
**Recompensa:** 150 Ouro, 50 XP, chance de drop: Elmo de Bronze Filisteu

#### Batalha 2.3 — Guarda Avançada
| Inimigo | HP | Dano | Tipo | Habilidade |
|---|---|---|---|---|
| Soldado Filisteu | 60 | 10-14 | Melee | Golpe de Espada |
| Arqueiro Filisteu | 40 | 8-12 | Ranged | Flecha Flamejante (DoT 2s) |
| Soldado Filisteu Elite | 80 | 12-18 | Melee | Contra-Ataque (reflete 20% dano) |
| Curandeiro Filisteu | 45 | 4-6 | Ranged | Cura aliados (+15 HP a cada 5s) |
**Recompensa:** 200 Ouro, 70 XP, chance de drop: Espada de Bronze Curta

#### BOSS 2.4 — Golias, o Gigante ⚔️
| Atributo | Valor |
|---|---|
| **HP** | 500 |
| **Dano** | 25-40 |
| **Armadura** | 20 |
| **Velocidade** | Lenta |
| **Fase 1 (100%-60% HP)** | Lançamento de Lança (ranged, dano alto), Escudo Gigante (bloqueia próximo ataque) |
| **Fase 2 (60%-30% HP)** | Pisotão (AoE, stun 2s), Grito de Guerra (imune a CC por 5s) |
| **Fase 3 (30%-0% HP)** | Fúria do Gigante (dano +30%), Investida (corre até Davi, dano massivo) |
| **Mecânica Especial** | A cada 20% HP perdido, Davi pode usar a Funda (habilidade especial desbloqueada nesta luta) para causar dano bônus na cabeça |
**Recompensa:** 500 Ouro, 200 XP, 5 Rubis, **drop garantido:** Espada de Golias (arma 2 mãos, Dano 20-30, +10% Chance Crítica)

---

## 4. Sistema de Equipamentos

### 4.1 Slots de Equipamento (9 slots)
1. **Cabeça** (Capacete/Elmo)
2. **Corpo** (Couraça/Armadura)
3. **Pés** (Sandálias/Botas)
4. **Mão Principal** (Arma 1 mão)
5. **Mão Secundária** (Escudo) — incompatível com arma 2 mãos
6. **Duas Mãos** (Arma 2 mãos) — ocupa ambos os slots de mão
7. **Anel** (2 slots de anel)
8. **Colar**
9. **Luvas**

### 4.2 Raridade dos Itens
| Raridade | Cor | Nº Atributos Bônus | Chance Drop |
|---|---|---|---|
| Comum | Cinza | 0 | 60% |
| Incomum | Verde | 1 | 25% |
| Raro | Azul | 2 | 10% |
| Épico | Roxo | 3 | 4% |
| Lendário | Dourado | 4 | 1% |

### 4.3 Catálogo de Equipamentos (15 por slot)

#### CABEÇA (Capacetes / Elmos)
| # | Nome | Armadura | Bônus Principal | Bônus Secundário | Preço (Ouro) | Nível Min |
|---|---|---|---|---|---|---|
| 1 | Faixa de Pastor | 1 | +5 HP | — | 50 | 1 |
| 2 | Faixa de Cabeça Simples | 2 | +3% Esquiva Melee | — | 120 | 2 |
| 3 | Capuz de Couro | 3 | +8 HP | — | 250 | 3 |
| 4 | Elmo de Bronze Leve | 5 | +2 Armadura | +2% Esquiva Distância | 500 | 4 |
| 5 | Elmo de Bronze Filisteu | 7 | +12 HP | +5% Chance Crítica | 800 | 5 |
| 6 | Capacete de Ferro Simples | 9 | +4 Armadura | — | 1.200 | 7 |
| 7 | Elmo do Deserto | 8 | +10 HP | +5% Esquiva Distância | 1.500 | 8 |
| 8 | Coroa de Bronze | 10 | +5% Chance Crítica | +3% Roubo de Vida | 2.000 | 10 |
| 9 | Elmo do Guerreiro | 12 | +6 Armadura | +15 HP | 3.000 | 12 |
| 10 | Capacete Real de Prata | 14 | +8% Esquiva Melee | +5% Dano Crítico | 4.500 | 15 |
| 11 | Elmo da Fé | 11 | +20 HP | +8% Esquiva Distância | 5.500 | 17 |
| 12 | Coroa de Ferro Ungido | 16 | +10% Chance Crítica | +5 Armadura | 7.000 | 20 |
| 13 | Elmo de Golias (Adaptado) | 18 | +8 Armadura | +10 HP, -5% Vel. Corrida | 9.000 | 22 |
| 14 | Capacete Serafim | 15 | +25 HP | +10% Esquiva Melee, +5% Roubo de Vida | 12.000 | 25 |
| 15 | Coroa do Ungido de Deus | 20 | +12% Chance Crítica | +10 Armadura, +30 HP | 18.000 | 30 |

#### CORPO (Couraças / Armaduras)
| # | Nome | Armadura | Bônus Principal | Bônus Secundário | Preço | Nível |
|---|---|---|---|---|---|---|
| 1 | Túnica de Pastor | 1 | +8 HP | — | 60 | 1 |
| 2 | Veste de Couro Curtido | 3 | +12 HP | — | 200 | 2 |
| 3 | Couraça de Couro Reforçado | 5 | +3 Armadura | +5 HP | 400 | 3 |
| 4 | Pele de Leão (drop boss M1) | 8 | +5% Esquiva Melee | +10 HP | Drop | 4 |
| 5 | Cota de Malha Leve | 7 | +5 Armadura | — | 900 | 5 |
| 6 | Couraça de Bronze | 10 | +20 HP | +3% Esquiva Distância | 1.500 | 7 |
| 7 | Armadura de Escamas | 12 | +7 Armadura | +5% Esquiva Melee | 2.200 | 9 |
| 8 | Cota de Malha Filisteia | 14 | +8 Armadura | +10 HP | 3.200 | 11 |
| 9 | Couraça do Deserto | 13 | +25 HP | +5% Roubo de Vida | 4.000 | 13 |
| 10 | Armadura Real de Bronze | 16 | +10 Armadura | +5% Chance Crítica | 5.500 | 16 |
| 11 | Couraça de Ferro Forjado | 18 | +12 Armadura | +15 HP | 7.000 | 18 |
| 12 | Peitoral da Aliança | 15 | +30 HP | +8% Esquiva Melee, +5% Esquiva Dist. | 9.000 | 21 |
| 13 | Armadura do General | 20 | +15 Armadura | +20 HP | 11.500 | 24 |
| 14 | Couraça do Arcanjo | 22 | +10% Roubo de Vida | +35 HP, +10 Armadura | 14.000 | 27 |
| 15 | Manto Sagrado do Rei | 25 | +40 HP | +15 Armadura, +10% Esquiva Melee | 20.000 | 30 |

#### PÉS (Sandálias / Botas)
| # | Nome | Armadura | Bônus Principal | Bônus Secundário | Preço | Nível |
|---|---|---|---|---|---|---|
| 1 | Sandálias de Pastor | 0 | +5% Vel. Corrida | — | 40 | 1 |
| 2 | Sandálias de Couro | 1 | +3% Esquiva Melee | +3% Vel. Corrida | 150 | 2 |
| 3 | Botas de Trilha | 2 | +8% Vel. Corrida | — | 350 | 3 |
| 4 | Sandálias Reforçadas | 2 | +5% Esquiva Melee | +5 HP | 600 | 5 |
| 5 | Botas de Couro Curtido | 3 | +10% Vel. Corrida | +2% Esquiva Distância | 900 | 6 |
| 6 | Grevas de Bronze | 4 | +3 Armadura | +5% Vel. Corrida | 1.400 | 8 |
| 7 | Botas do Mensageiro | 2 | +15% Vel. Corrida | +5% Esquiva Melee | 1.800 | 10 |
| 8 | Botas de Ferro Leve | 5 | +5 Armadura | +3% Vel. Corrida | 2.500 | 12 |
| 9 | Sandálias do Deserto | 3 | +8% Esquiva Distância | +10% Vel. Corrida | 3.200 | 14 |
| 10 | Grevas de Ferro | 6 | +7 Armadura | +5 HP | 4.500 | 16 |
| 11 | Botas do Explorador | 4 | +12% Vel. Corrida | +8% Esquiva Melee | 5.800 | 19 |
| 12 | Grevas Reais | 7 | +8 Armadura | +8% Vel. Corrida | 7.500 | 22 |
| 13 | Botas Aladas | 5 | +20% Vel. Corrida | +10% Esquiva Melee, +5% Esquiva Dist. | 10.000 | 25 |
| 14 | Grevas do Arcanjo | 8 | +10 Armadura | +10% Vel. Corrida | 13.000 | 27 |
| 15 | Sandálias do Ungido | 6 | +15% Vel. Corrida | +12% Esquiva Melee, +10 HP | 17.000 | 30 |

#### MÃO PRINCIPAL (Armas 1 Mão)
| # | Nome | Dano | Bônus Principal | Bônus Secundário | Preço | Nível |
|---|---|---|---|---|---|---|
| 1 | Cajado de Pastor (inicial) | 2-4 | — | — | Grátis | 1 |
| 2 | Cajado Reforçado | 3-6 | +3% Chance Crítica | — | 200 | 2 |
| 3 | Faca de Tosquia | 4-7 | +5% Vel. Ataque | — | 400 | 3 |
| 4 | Porrete de Madeira | 5-9 | +5 HP | +5% Chance Crítica | 650 | 4 |
| 5 | Adaga de Bronze | 6-10 | +8% Vel. Ataque | +5% Chance Crítica | 1.000 | 5 |
| 6 | Espada de Bronze Curta | 8-13 | +5% Chance Crítica | +2% Roubo de Vida | 1.600 | 7 |
| 7 | Maça de Ferro | 10-15 | +10% Dano Crítico | — | 2.400 | 9 |
| 8 | Espada Filisteia | 11-17 | +8% Chance Crítica | +5% Vel. Ataque | 3.500 | 11 |
| 9 | Cimitarra do Deserto | 13-19 | +10% Vel. Ataque | +3% Roubo de Vida | 4.800 | 13 |
| 10 | Espada de Ferro | 15-22 | +10% Chance Crítica | +15% Dano Crítico | 6.500 | 16 |
| 11 | Lâmina do Capitão | 17-25 | +12% Chance Crítica | +8% Vel. Ataque | 8.500 | 19 |
| 12 | Espada Real de Prata | 19-28 | +5% Roubo de Vida | +20% Dano Crítico | 11.000 | 22 |
| 13 | Espada do Juramento | 22-32 | +15% Chance Crítica | +10% Vel. Ataque | 14.000 | 25 |
| 14 | Lâmina Serafim | 25-35 | +8% Roubo de Vida | +25% Dano Crítico | 17.000 | 27 |
| 15 | Espada do Rei Davi | 28-40 | +18% Chance Crítica | +30% Dano Crítico, +5% Roubo de Vida | 22.000 | 30 |

#### ESCUDO (Mão Secundária)
| # | Nome | Armadura | Bônus Principal | Bônus Secundário | Preço | Nível |
|---|---|---|---|---|---|---|
| 1 | Escudo de Madeira | 2 | +5 HP | — | 80 | 1 |
| 2 | Escudo de Couro | 3 | +8 HP | +2% Esquiva Melee | 250 | 2 |
| 3 | Escudo Redondo de Bronze | 5 | +3 Armadura | +5 HP | 500 | 4 |
| 4 | Escudo de Tábuas | 4 | +10 HP | +5% Esquiva Distância | 700 | 5 |
| 5 | Broquel de Ferro | 6 | +5 Armadura | — | 1.100 | 6 |
| 6 | Escudo de Bronze Filisteu | 8 | +15 HP | +3% Esquiva Melee | 1.700 | 8 |
| 7 | Escudo do Sentinela | 9 | +6 Armadura | +5% Esquiva Distância | 2.600 | 10 |
| 8 | Escudo de Ferro | 11 | +8 Armadura | +10 HP | 3.800 | 12 |
| 9 | Escudo do Deserto | 10 | +20 HP | +8% Esquiva Melee | 5.000 | 14 |
| 10 | Escudo Real de Bronze | 13 | +10 Armadura | +5% Esquiva Distância | 6.500 | 17 |
| 11 | Escudo do General | 15 | +12 Armadura | +15 HP | 8.500 | 19 |
| 12 | Escudo Torre de Ferro | 18 | +15 Armadura | +5% Esquiva Melee, +10 HP | 11.000 | 22 |
| 13 | Escudo do Pacto | 14 | +25 HP | +10% Esquiva Melee, +8% Esquiva Dist. | 13.500 | 25 |
| 14 | Escudo Seráfico | 17 | +20 HP | +12 Armadura, +5% Roubo de Vida | 16.000 | 27 |
| 15 | Escudo da Arca Sagrada | 20 | +30 HP | +15 Armadura, +10% Esquiva Melee | 20.000 | 30 |

#### ARMAS DE 2 MÃOS
| # | Nome | Dano | Bônus Principal | Bônus Secundário | Preço | Nível |
|---|---|---|---|---|---|---|
| 1 | Cajado Grande de Cedro | 4-8 | +5 HP | — | 150 | 1 |
| 2 | Lança de Madeira | 6-10 | +5% Chance Crítica | +3% Vel. Ataque | 400 | 3 |
| 3 | Arco Simples + Flechas | 5-12 | Ataque à Distância | — | 600 | 4 |
| 4 | Lança de Bronze | 9-15 | +8% Chance Crítica | +10% Dano Crítico | 1.000 | 5 |
| 5 | Machado de Lenhador | 12-18 | +15% Dano Crítico | +5 HP | 1.800 | 7 |
| 6 | Espada de Golias (drop boss M2) | 20-30 | +10% Chance Crítica | +20% Dano Crítico | Drop | 8 |
| 7 | Arco Composto de Guerra | 10-20 | Ataque à Distância | +10% Vel. Ataque | 3.000 | 10 |
| 8 | Alabarda de Ferro | 18-26 | +12% Chance Crítica | +15% Dano Crítico | 4.500 | 12 |
| 9 | Lança do Deserto | 20-30 | +10% Vel. Ataque | +5% Roubo de Vida | 6.000 | 15 |
| 10 | Machado de Guerra | 24-35 | +20% Dano Crítico | +8% Chance Crítica | 8.000 | 18 |
| 11 | Arco Longo Real | 16-30 | Ataque à Distância | +15% Chance Crítica, +15% Vel. Ataque | 10.000 | 20 |
| 12 | Espada Bastarda de Ferro | 28-40 | +15% Chance Crítica | +25% Dano Crítico | 13.000 | 23 |
| 13 | Lança do Juízo | 30-44 | +12% Roubo de Vida | +18% Chance Crítica | 16.000 | 25 |
| 14 | Machado Divino | 34-48 | +30% Dano Crítico | +15% Chance Crítica | 19.000 | 28 |
| 15 | Cajado de Moisés (Lendário) | 38-55 | +20% Chance Crítica | +35% Dano Crítico, +10% Roubo de Vida | 25.000 | 30 |

#### ANEL (2 slots disponíveis)
| # | Nome | Bônus Principal | Bônus Secundário | Preço | Nível |
|---|---|---|---|---|---|
| 1 | Anel de Cobre Simples | +3 HP | — | 100 | 1 |
| 2 | Anel de Osso | +3% Chance Crítica | — | 250 | 3 |
| 3 | Anel de Bronze | +5 HP | +2% Esquiva Melee | 500 | 5 |
| 4 | Anel do Pastor | +5% Vel. Corrida | +5 HP | 750 | 6 |
| 5 | Anel de Ferro | +5% Chance Crítica | +5% Dano Crítico | 1.200 | 8 |
| 6 | Anel de Prata | +8 HP | +3% Roubo de Vida | 1.800 | 10 |
| 7 | Anel da Aliança | +3 Armadura | +5% Esquiva Distância | 2.500 | 12 |
| 8 | Anel do Valente | +8% Chance Crítica | +10% Dano Crítico | 3.500 | 14 |
| 9 | Anel do Deserto | +10 HP | +5% Vel. Ataque | 4.500 | 16 |
| 10 | Anel Real | +5 Armadura | +5% Esquiva Melee, +5% Esquiva Dist. | 6.000 | 18 |
| 11 | Anel do Profeta | +5% Roubo de Vida | +10% Chance Crítica | 8.000 | 21 |
| 12 | Anel de Ouro Puro | +15 HP | +8% Chance Crítica | 10.000 | 23 |
| 13 | Anel do Trono | +8 Armadura | +10% Esquiva Melee | 13.000 | 25 |
| 14 | Anel Angelical | +8% Roubo de Vida | +12% Chance Crítica, +15% Dano Crítico | 16.000 | 28 |
| 15 | Anel do Pacto Eterno | +20 HP | +10 Armadura, +15% Chance Crítica | 20.000 | 30 |

#### COLAR
| # | Nome | Bônus Principal | Bônus Secundário | Preço | Nível |
|---|---|---|---|---|---|
| 1 | Cordão de Lã | +5 HP | — | 80 | 1 |
| 2 | Pingente de Pedra | +5% Dano Crítico | — | 200 | 2 |
| 3 | Colar de Dentes de Lobo | +3% Chance Crítica | +3% Esquiva Melee | 450 | 4 |
| 4 | Amuleto de Bronze | +8 HP | +2% Roubo de Vida | 700 | 5 |
| 5 | Colar de Contas | +5% Vel. Ataque | +5% Chance Crítica | 1.100 | 7 |
| 6 | Pingente da Fé | +12 HP | +5% Esquiva Distância | 1.700 | 9 |
| 7 | Colar de Prata | +3 Armadura | +8% Dano Crítico | 2.500 | 11 |
| 8 | Amuleto do Guerreiro | +10% Chance Crítica | +5% Vel. Ataque | 3.500 | 13 |
| 9 | Colar do Deserto | +15 HP | +5% Roubo de Vida | 4.800 | 15 |
| 10 | Pingente Real | +5 Armadura | +8% Chance Crítica, +10% Dano Crítico | 6.500 | 17 |
| 11 | Colar da Unção | +8% Roubo de Vida | +12 HP | 8.500 | 20 |
| 12 | Amuleto de Ouro | +8% Esquiva Melee | +8% Esquiva Distância | 11.000 | 22 |
| 13 | Colar do Profeta Samuel | +12% Chance Crítica | +20% Dano Crítico | 14.000 | 25 |
| 14 | Pingente Seráfico | +20 HP | +10% Roubo de Vida, +5 Armadura | 17.000 | 28 |
| 15 | Colar da Arca da Aliança | +10 Armadura | +15% Chance Crítica, +25% Dano Crítico | 22.000 | 30 |

#### LUVAS
| # | Nome | Armadura | Bônus Principal | Bônus Secundário | Preço | Nível |
|---|---|---|---|---|---|---|
| 1 | Faixas de Pano | 0 | +3% Vel. Ataque | — | 50 | 1 |
| 2 | Luvas de Couro Fino | 1 | +3% Chance Crítica | — | 180 | 2 |
| 3 | Luvas de Pastor | 1 | +5% Vel. Ataque | +3 HP | 350 | 3 |
| 4 | Braçais de Couro | 2 | +5% Chance Crítica | +5% Vel. Ataque | 600 | 5 |
| 5 | Luvas de Bronze | 3 | +2 Armadura | +5% Chance Crítica | 950 | 6 |
| 6 | Manoplas de Couro Reforçado | 2 | +8% Vel. Ataque | +8% Dano Crítico | 1.500 | 8 |
| 7 | Luvas do Arqueiro | 1 | +10% Vel. Ataque | +8% Chance Crítica | 2.200 | 10 |
| 8 | Manoplas de Ferro | 4 | +4 Armadura | +5% Vel. Ataque | 3.200 | 12 |
| 9 | Luvas do Deserto | 2 | +10% Chance Crítica | +10% Dano Crítico | 4.500 | 14 |
| 10 | Manoplas Reais | 5 | +6 Armadura | +8% Vel. Ataque | 6.000 | 17 |
| 11 | Luvas do Guerreiro | 3 | +12% Chance Crítica | +15% Dano Crítico | 8.000 | 19 |
| 12 | Manoplas de Ferro Forjado | 6 | +8 Armadura | +10% Vel. Ataque | 10.500 | 22 |
| 13 | Luvas do Campeão | 4 | +15% Chance Crítica | +5% Roubo de Vida | 13.000 | 25 |
| 14 | Manoplas Angélicas | 5 | +12% Vel. Ataque | +12% Chance Crítica, +20% Dano Crítico | 16.500 | 28 |
| 15 | Manoplas do Ungido | 7 | +10 Armadura | +15% Chance Crítica, +8% Roubo de Vida | 20.000 | 30 |

---

## 5. Personagens Jogáveis

### 5.1 Sistema de Personagens Alternativos
- O personagem padrão é **Davi** (gratuito)
- Ao **zerar um mapa**, o jogador desbloqueia a possibilidade de **comprar** personagens alternativos na Loja de Personagens
- Personagens alternativos possuem os **mesmos atributos base** e sistema de equipamento, mas com **visual e animações únicos**
- Todos os personagens compartilham o mesmo progresso de equipamentos e habilidades

### 5.2 Personagens Disponíveis

| # | Nome | Visual | Preço (Ouro) | Mapa Requerido | Bônus Passivo |
|---|---|---|---|---|---|
| 1 | **Davi** | Jovem pastor bíblico, túnica marrom, cabelo cacheado | Grátis | — | Nenhum (personagem base) |
| 2 | **BigJ** | Rapaz moderno, bermuda jeans, camisa cinza escuro, boina cinza claro | 10.000 | Completar Mapa 1 | +5% Chance Crítica |
| 3 | **Sansão** | Homem forte, cabelos longos, veste de couro, músculos enormes | 15.000 | Completar Mapa 2 | +10% Dano Corpo a Corpo |
| 4 | **Josué** | Guerreiro veterano, armadura de general israelita, espada e escudo | 25.000 | Completar Mapa 3 | +8% Armadura |
| 5 | **Débora** | Juíza guerreira, vestimenta real, arco e adaga | 30.000 | Completar Mapa 4 | +10% Vel. Ataque |
| 6 | **Elias** | Profeta, manto de pele de carneiro, cajado flamejante | 40.000 | Completar Mapa 5 | +8% Roubo de Vida |
| 7 | **Gideão** | Guerreiro com tocha e trombeta, armadura leve | 50.000 | Completar Mapa 6 | +12% Esquiva Melee |

### 5.3 Prompts Nano Banana — Personagens Alternativos

**BigJ:**
```
2D side-view game character sprite sheet, young modern guy, light skin, wearing dark grey t-shirt, denim bermuda shorts (jeans), light grey beret/flat cap, sneakers, confident stance, cartoon stylized art style, vibrant colors, white background, idle pose, walking animation frames, attack animation frames, game asset, clean lines
```

**Sansão:**
```
2D side-view game character sprite sheet, biblical Samson, extremely muscular man, very long dark hair, leather vest showing muscles, leather wrist bands, ancient sandals, carrying jawbone weapon, cartoon stylized art, vibrant colors, white background, idle and attack animation frames, game asset
```

**Josué:**
```
2D side-view game character sprite sheet, biblical Joshua warrior general, bronze armor with red cape, iron helmet, sword and round shield, battle-ready stance, Middle Eastern ancient general, cartoon stylized art, vibrant colors, white background, game asset
```

**Débora:**
```
2D side-view game character sprite sheet, biblical Deborah warrior judge, elegant armor dress, flowing dark hair, holding bow in one hand and dagger in other, golden headpiece, fierce expression, cartoon stylized art, vibrant colors, white background, game asset
```

**Elias:**
```
2D side-view game character sprite sheet, biblical prophet Elijah, sheepskin mantle cloak, long beard, holding flaming staff, intense eyes, sandals, cartoon stylized art, vibrant colors, white background, game asset
```

**Gideão:**
```
2D side-view game character sprite sheet, biblical Gideon warrior, light leather armor, holding torch in one hand and trumpet/shofar in other, determined expression, ancient Israelite warrior, cartoon stylized art, vibrant colors, white background, game asset
```

---

## 6. Sistema de Comidas (Cura em Batalha)

Em vez de poções, o jogador usa **comidas bíblicas** para se curar durante as batalhas. O jogador pode carregar até **3 comidas** por batalha.

### 6.1 Comidas Disponíveis
| # | Comida | Cura | Efeito Extra | Preço (Ouro) | Nível Min |
|---|---|---|---|---|---|
| 1 | **Pão de Cevada** | +15 HP | — | 20 | 1 |
| 2 | **Cacho de Uvas** | +25 HP | — | 40 | 1 |
| 3 | **Figos Secos** | +20 HP | Remove veneno/DoT | 50 | 3 |
| 4 | **Azeitonas em Azeite** | +10 HP | +5% Esquiva por 10s | 60 | 4 |
| 5 | **Pão com Mel** | +35 HP | — | 80 | 5 |
| 6 | **Romã** | +30 HP | +10% Vel. Ataque por 8s | 100 | 7 |
| 7 | **Queijo de Cabra** | +40 HP | +5 Armadura por 10s | 130 | 9 |
| 8 | **Tâmaras** | +25 HP | +8% Chance Crítica por 10s | 110 | 8 |
| 9 | **Lentilhas Cozidas** | +50 HP | — | 160 | 11 |
| 10 | **Peixe Assado** | +45 HP | +3% Roubo de Vida por 15s | 180 | 13 |
| 11 | **Bolo de Passas** | +60 HP | Remove debuffs | 220 | 15 |
| 12 | **Cordeiro Assado** | +80 HP | +10% Dano por 10s | 300 | 18 |
| 13 | **Pão dos Anjos (Maná)** | +100 HP | +5% todos atributos por 10s | 500 | 22 |
| 14 | **Festa do Rei** | +120 HP | +15% Dano, +10 Armadura por 12s | 750 | 26 |
| 15 | **Banquete Celestial** | +150 HP | Cura completa + todos buffs por 8s | 1.000 | 30 |

### 6.2 Prompts Nano Banana — Comidas
```
2D game item icons set, biblical food collection for healing items, barley bread loaf, purple grape bunch, dried figs, green olives in oil bowl, bread with honey, pomegranate cut open, goat cheese wheel, dates, cooked lentils bowl, roasted fish, raisin cake, roasted lamb leg, glowing manna bread, royal feast platter, celestial golden banquet plate, clean icon style on transparent background, cartoon stylized art, warm appetizing colors, game asset
```

---

## 7. Sistema de Cartas de Bônus (Pós-Batalha)

Ao final de cada batalha (exceto boss), o jogador escolhe 1 de 3 cartas aleatórias. Os bônus são **temporários** (duram até o fim do mapa atual).

### Cartas Disponíveis
| Carta | Efeito | Raridade |
|---|---|---|
| Benção de Força | +15% Dano | Comum |
| Escudo da Fé | +10 Armadura | Comum |
| Pés Ligeiros | +20% Vel. Corrida | Comum |
| Mãos Ágeis | +15% Vel. Ataque | Comum |
| Olho de Águia | +10% Chance Crítica | Incomum |
| Golpe Certeiro | +25% Dano Crítico | Incomum |
| Pele de Bronze | +20 HP Max | Incomum |
| Sombra do Vento | +10% Esquiva Melee | Incomum |
| Esquiva Divina | +10% Esquiva Distância | Incomum |
| Vampirismo | +5% Roubo de Vida | Raro |
| Fúria Sagrada | +25% Dano, -10% HP Max | Raro |
| Comida Aleatória | 26% chance de reabastecer 1 comida | Raro |
| As Fontes Reparam | Restaura armadura ao máximo | Raro |
| Punhalada Letal | +25% dano (+260% dano) a inimigos <50% HP | Épico |
| Benção do Ungido | +10% todos os atributos | Épico |
| Anjo Guardião | Revive com 30% HP (1 vez) | Épico |

---

## 8. Interface / Telas

### 8.1 Tela de Idioma (Primeira Abertura)
- Aparece apenas na **primeira vez** que o jogador abre o jogo
- Duas opções: **Português (BR)** | **English**
- Após seleção, salva a preferência localmente e no perfil da nuvem
- Pode ser alterado a qualquer momento em **Configurações > Idioma**
- Todos os textos do jogo (menus, nomes de itens, diálogos, descrições) são traduzidos

### 8.2 Tela de Login
- Após selecionar idioma, apresenta tela de login
- **Login via Google Auth** (Firebase Authentication)
- Botão "Entrar com Google" estilizado no tema do jogo
- Após login, carrega progresso salvo automaticamente da nuvem
- Se primeiro acesso, cria perfil novo com Davi nível 1

### 8.3 Menu Principal
- **Continuar Jornada** (vai para o mapa atual)
- **Inventário / Personagem**
- **Loja** (inclui aba de Personagens)
- **Conquistas**
- **Ranking** (público, global)
- **PvP** (desbloqueado após Mapa 3)
- **Clãs** (desbloqueado após Mapa 3)
- **Desafios Semanais**
- **Configurações** (idioma, som, notificações, conta)

### 8.4 Tela de Mapa (Overworld)
- Estilo ilha/região com nós de batalha conectados por caminhos
- Cada nó mostra: número da batalha, estrelas conquistadas (1-3), indicador de boss
- Botões de acesso rápido: PvP, Clãs, Loja, Inventário, Conquistas, Ranking

### 8.5 HUD de Batalha
- **Canto superior esquerdo:** Ouro coletado na batalha
- **Canto superior centro:** Barra de progresso do mapa (ícones dos inimigos)
- **Canto inferior esquerdo:** Painel de stats (Ataque, Defesa, Esquiva)
- **Canto inferior direito:** Botões de habilidades ativas (até 3) + botão de comida
- **Centro inferior:** Barra de HP do personagem + barra de XP
- **Sobre inimigos:** Nome + barra de HP

### 8.6 Tela de Inventário
- Avatar do personagem selecionado ao centro com slots de equipamento ao redor
- Stats completos à esquerda
- Lista de inventário à direita com filtros por tipo
- Nível, XP, botões de "Arte" e "Habilidades"
- Seletor de personagem ativo (troca entre personagens desbloqueados)

### 8.7 Tela da Loja
- Abas: Comprar | Vender | Baús | **Personagens**
- Grid de itens com preço em ouro
- Preview do item ao selecionar com comparação do equipado
- Nível da loja (sobe conforme progressão, libera itens melhores)
- Timer de reabastecimento do estoque
- Aba **Personagens**: mostra todos os personagens, preço, mapa requerido, bônus passivo

### 8.8 Tela de Ranking (Público)
- Ranking global com posição, nome, nível, power score, mapa atual
- Filtros: Global | Semanal | Clã | Amigos
- Perfil público ao tocar em um jogador (nível, equipamento, personagem, conquistas)

---

## 9. Progressão e Economia

### 9.1 Nível do Personagem
- XP obtido em batalhas
- Cada nível: +5 HP base, +1 Dano base, desbloqueio de equipamentos

### 9.2 Moedas
| Moeda | Obtenção | Uso |
|---|---|---|
| **Ouro** | Batalhas, venda de itens, desafios | Comprar equipamentos, comidas, personagens |
| **Rubis** | Boss kills, conquistas, compra real ($) | Baús premium, reviver em batalha, acelerar timers |

### 9.3 Estrelas por Batalha (1-3)
- ⭐ Completar a batalha
- ⭐⭐ Completar sem usar comida
- ⭐⭐⭐ Completar com HP acima de 50%

---

## 10. Ranking Público

### 10.1 Categorias de Ranking
| Ranking | Critério | Atualização |
|---|---|---|
| **Power Score** | Soma de todos os atributos + nível + equipamento | Tempo real |
| **Progresso** | Mapa atual + estrelas totais coletadas | Tempo real |
| **PvP** | Vitórias em arena + rating ELO | Semanal |
| **Clã** | Soma do power score de todos membros | Semanal |
| **Semanal** | Ouro ganho + inimigos derrotados na semana | Reset toda segunda |

### 10.2 Perfil Público do Jogador
- Nome, nível, personagem ativo, mapa atual
- Power score total
- Equipamento visualizável (mas não copiável)
- Conquistas exibidas (até 3 selecionadas pelo jogador)
- Clã atual
- Ranking em cada categoria

### 10.3 Tela de Ranking
- Top 100 global por categoria
- Posição do jogador destacada (mesmo fora do top 100)
- Filtros: Global | Regional | Clã | Amigos
- Busca por nome de jogador

---

## 11. PvP (Desbloqueado após Mapa 3)

### 11.1 Arena
- Matchmaking baseado em nível + power score dos equipamentos
- Formato: personagem do jogador vs personagem do oponente (auto-batalha)
- Rankings semanal com recompensas
- Temporadas de 4 semanas

### 11.2 Recompensas PvP
| Rank | Recompensa Semanal |
|---|---|
| Bronze | 500 Ouro |
| Prata | 1.000 Ouro + 5 Rubis |
| Ouro | 2.500 Ouro + 15 Rubis |
| Diamante | 5.000 Ouro + 30 Rubis + Item Exclusivo |
| Lendário | 10.000 Ouro + 50 Rubis + Item Lendário Exclusivo |

---

## 12. Clãs (Desbloqueado após Mapa 3)

- Criar ou entrar em um Clã (até 30 membros)
- **Chat de Clã**
- **Boss de Clã semanal:** Membros contribuem dano contra um boss gigante (ex: Dragão de Bronze)
- **Doações:** Membros doam ouro para melhorar a loja do Clã
- **Perks de Clã:** Bônus passivos (+5% XP, +5% Ouro, etc.)

---

## 13. Desafios Semanais

Renovam toda segunda-feira. 5 desafios por semana.

| Exemplo | Recompensa |
|---|---|
| Derrotar 50 inimigos | 300 Ouro |
| Completar 10 batalhas sem morrer | 500 Ouro + 3 Rubis |
| Causar 5.000 de dano crítico | 5 Rubis |
| Comprar 3 itens na loja | 200 Ouro |
| Vencer 5 batalhas PvP | 10 Rubis |

---

## 14. Habilidades Ativas

Desbloqueiam conforme progressão. Jogador equipa até 3 simultâneas.

| Habilidade | Nível Unlock | Cooldown | Efeito |
|---|---|---|---|
| Golpe do Cajado | 1 | 8s | Dano 150% + stun 1s |
| Pedrada (Funda) | 3 | 10s | Dano ranged 200% + chance stun 20% |
| Grito de Guerra | 5 | 15s | +20% Dano por 5s |
| Esquiva Rápida | 7 | 12s | Invulnerável por 2s + reposiciona |
| Golpe do Pastor | 10 | 10s | Dano 180% + sangramento 3s |
| Pedra Certeira (Funda) | 13 | 12s | Dano ranged 300% (dano garantido, ignora esquiva) |
| Salmo de Cura | 16 | 20s | Cura 25% HP Max |
| Fúria de Davi | 20 | 18s | +50% Vel. Ataque por 5s |
| Investida do Leão | 24 | 15s | Avança e causa 250% dano + knockback |
| Unção Divina (Ultimate) | 30 | 60s | +30% todos atributos por 10s + cura 20% HP |

---

## 15. Prompts para Nano Banana (Geração de Sprites)

### 15.1 Personagem Principal — Davi

**Davi Jovem (Mapas 1-2):**
```
2D side-view game character sprite sheet, young biblical shepherd boy David, age 16, tan skin, curly brown hair, wearing simple brown wool tunic and leather sandals, holding a wooden shepherd staff, cartoon stylized art style, vibrant colors, white background, idle pose, walking animation frames, attack animation frames, game asset, clean lines, no outlines bleed
```

**Davi com Funda (Boss Golias):**
```
2D side-view game character sprite sheet, young biblical David with sling weapon, age 16, tan skin, curly brown hair, wearing lion skin armor over tunic, leather sandals, swinging a sling overhead, cartoon stylized art, vibrant colors, white background, attack animation frames, game asset
```

### 15.2 Inimigos — Mapa 1

**Lobo Cinzento:**
```
2D side-view game enemy sprite, grey wolf, aggressive stance, baring teeth, cartoon stylized art, vibrant colors, white background, idle and attack animation frames, game asset, clean lines
```

**Lobo Alfa:**
```
2D side-view game enemy sprite, large alpha wolf, dark grey fur with scars, red eyes, howling pose, cartoon stylized art, vibrant colors, white background, idle and attack frames, game asset
```

**Raposa Raivosa:**
```
2D side-view game enemy sprite, rabid fox, foaming mouth, aggressive, orange-red fur, cartoon stylized art, white background, game asset sprite sheet
```

**Chacal Faminto:**
```
2D side-view game enemy sprite, hungry jackal, thin body, yellow eyes, desert wild dog, cartoon stylized art, white background, game asset
```

**Javali Selvagem:**
```
2D side-view game enemy sprite, wild boar, large tusks, charging pose, brown bristly fur, cartoon stylized art, white background, game asset
```

**Serpente Venenosa:**
```
2D side-view game enemy sprite, venomous snake, coiled and striking pose, green scales with yellow pattern, cartoon stylized art, white background, game asset
```

**Águia Caçadora:**
```
2D side-view game enemy sprite, hunting eagle, diving attack pose, brown feathers with golden head, spread wings, cartoon stylized art, white background, game asset
```

**Escorpião Gigante:**
```
2D side-view game enemy sprite, giant scorpion, raised stinger tail, dark brown exoskeleton, menacing claws, cartoon stylized art, white background, game asset
```

**Hiena Matilheira:**
```
2D side-view game enemy sprite, spotted hyena, laughing aggressive pose, brown spotted fur, cartoon stylized art, white background, game asset
```

**Leão (Boss Mapa 1):**
```
2D side-view game boss sprite sheet, majestic fierce lion, large golden mane, muscular body, roaring pose, attack animations including paw swipe and leap, cartoon stylized art, vibrant colors, white background, game asset, detailed
```

### 15.3 Inimigos — Mapa 2

**Filhote de Urso:**
```
2D side-view game enemy sprite, young brown bear cub, standing on hind legs, small claws, cartoon stylized art, white background, game asset
```

**Urso Pardo (Sub-Boss):**
```
2D side-view game boss sprite sheet, large brown bear, standing upright, massive claws, roaring, muscular build, attack animations including bear hug and claw swipe, cartoon stylized art, vibrant colors, white background, game asset
```

**Batedor Filisteu (Lança):**
```
2D side-view game enemy sprite, ancient Philistine scout soldier, bronze armor, leather skirt, holding spear, pointed helmet, Middle Eastern ancient warrior, cartoon stylized art, white background, game asset
```

**Batedor Filisteu (Arco):**
```
2D side-view game enemy sprite, ancient Philistine archer, light bronze armor, holding bow with arrow drawn, quiver on back, cartoon stylized art, white background, game asset
```

**Batedor Filisteu (Escudo):**
```
2D side-view game enemy sprite, ancient Philistine shield bearer, heavy bronze armor, large round shield, short sword, defensive stance, cartoon stylized art, white background, game asset
```

**Soldado Filisteu:**
```
2D side-view game enemy sprite, Philistine infantry soldier, bronze scale armor, sword and small shield, feathered helmet, cartoon stylized art, white background, game asset
```

**Soldado Filisteu Elite:**
```
2D side-view game enemy sprite, elite Philistine warrior, ornate bronze armor, large sword, red cape, decorated helmet with plume, cartoon stylized art, white background, game asset
```

**Curandeiro Filisteu:**
```
2D side-view game enemy sprite, Philistine healer priest, dark robes, holding staff with glowing green orb, mystical appearance, cartoon stylized art, white background, game asset
```

**Arqueiro Filisteu:**
```
2D side-view game enemy sprite, Philistine war archer, medium bronze armor, composite bow, flaming arrow, cartoon stylized art, white background, game asset
```

**Golias (Boss Mapa 2):**
```
2D side-view game final boss sprite sheet, Goliath the giant biblical warrior, massive muscular body 3x taller than normal character, full bronze armor with scale mail, bronze helmet, carrying huge spear and large shield, intimidating pose, attack animations including spear throw and ground stomp and charge, cartoon stylized art, vibrant colors, white background, game asset, highly detailed
```

### 15.4 Backgrounds

**Mapa 1 — Campos de Belém:**
```
2D side-scrolling game background, biblical Bethlehem shepherding fields, rolling green hills, olive trees, sheep grazing in distance, golden sunset sky, ancient stone walls, wildflowers, parallax layers foreground midground background, cartoon stylized art, vibrant warm colors, game asset, seamless tileable
```

**Mapa 2 — Vale de Elá:**
```
2D side-scrolling game background, biblical Valley of Elah battlefield, rocky terrain, dry riverbed with stones, ancient military tents on both sides, mountains in background, dramatic cloudy sky, parallax layers, cartoon stylized art, vibrant colors, game asset, seamless tileable
```

**Mapa do Overworld:**
```
2D top-down game overworld map, biblical ancient Israel landscape, illustrated map style with paths connecting battle nodes, green fields transitioning to rocky valleys, small villages, rivers, mountains in distance, warm color palette, cartoon stylized art, game asset
```

### 15.5 Itens / Equipamentos

**Armas:**
```
2D game item icons set, ancient biblical weapons collection, wooden shepherd staff, bronze short sword, iron sword, sling weapon with stones, bronze spear, war bow, battle axe, ornate golden royal sword, clean icon style on transparent background, cartoon stylized art, game asset
```

**Armaduras e Escudos:**
```
2D game item icons set, ancient biblical armor collection, wool tunic, leather armor, lion skin vest, bronze chain mail, iron plate armor, royal golden armor, wooden shield, bronze round shield, iron tower shield, clean icon style on transparent background, cartoon stylized art, game asset
```

**Acessórios:**
```
2D game item icons set, ancient biblical accessories, copper ring, bone ring, gold ring with gem, wool cord necklace, bronze amulet, golden crown, leather gloves, bronze gauntlets, iron boots, leather sandals, clean icon style on transparent background, cartoon stylized art, game asset
```

### 15.6 UI Elements

**Botões e Painéis:**
```
2D game UI kit, ancient biblical theme, wooden frame panels, bronze decorated buttons, health bar red, XP bar gold, coin icon, ruby gem icon, parchment scroll background, star rating icons, cartoon stylized art, warm color palette, game asset
```

**Cartas de Bônus:**
```
2D game card design set, ancient biblical theme, three card types showing magical effects, potion bottle card, hammer repair card, dagger attack card, ornate bronze card frames, glowing effects, cartoon stylized art, game asset
```

---

## 16. Roadmap de Implementação

### Fase 1 — Fundação (Mapas 1-2)
1. Setup do projeto SpriteKit/Swift + Firebase
2. Sistema de idiomas (i18n PT-BR / EN)
3. Login via Google Auth + save automático na nuvem
4. Sistema de cenas e navegação entre telas
5. Personagem Davi: movimentação, animações, auto-ataque
6. Sistema de personagens alternativos
7. Sistema de inimigos: spawn, IA básica, morte
8. HUD de batalha
9. Sistema de HP, dano, atributos
10. Sistema de comidas (cura em batalha)
11. Mapa 1 completo (3 batalhas + boss Leão)
12. Mapa 2 completo (3 batalhas + boss Golias)
13. Sistema de equipamentos e inventário
14. Loja (equipamentos + personagens + comidas)
15. Sistema de cartas pós-batalha
16. Sistema de XP e níveis
17. Menu principal e navegação
18. Ranking público básico

### Fase 2 — Conteúdo (Mapas 3-5)
19. Mapas 3, 4 e 5 com inimigos e bosses
20. Habilidades ativas completas
21. Sistema de conquistas
22. Desafios semanais

### Fase 3 — Social (Mapas 6-7 + PvP)
23. Mapas 6 e 7
24. Sistema PvP (Arena)
25. Sistema de Clãs
26. Boss de Clã semanal
27. Rankings completos e temporadas

### Fase 4 — Polimento
28. Balanceamento de dificuldade
29. Efeitos sonoros e música
30. Tutorial interativo
31. Monetização (IAP para Rubis)
32. Analytics e crash reporting
33. TestFlight e App Store submission

---

## 17. Especificações Técnicas

| Item | Especificação |
|---|---|
| **Engine** | SpriteKit (nativo iOS) |
| **Linguagem** | Swift 5+ |
| **iOS Mínimo** | iOS 16.0 |
| **Orientação** | Landscape |
| **Resolução Base** | 1920x1080 (escalável) |
| **Persistência Local** | UserDefaults (preferências) + cache local |
| **Backend** | Firebase (Auth + Firestore + Cloud Functions) |
| **Autenticação** | Firebase Auth com Google Sign-In |
| **Save na Nuvem** | Firestore (auto-save a cada mudança de estado) |
| **Ranking** | Firestore + Cloud Functions (cálculo de ranking) |
| **i18n** | Localizable.strings (PT-BR + EN) |
| **Ads** | AdMob (rewarded videos) |
| **IAP** | StoreKit 2 |
| **Analytics** | Firebase Analytics |
| **Sprites** | Atlas de sprites (SKTextureAtlas) |
| **Áudio** | AVAudioEngine / SKAudioNode |
| **Animações** | SKAction sequences |

---

*Documento criado em: 18/02/2026*
*Versão: 2.0 — Atualizado com personagens alternativos, comidas, login Google, ranking público, i18n*
