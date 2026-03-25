# Bioavailability / Absorption Panel

## Research Sources

- Hurrell RF, Egli I. "Iron bioavailability and dietary reference values." Am J Clin Nutr. 2010;91(5):1461S-1467S
- WHO/FAO. "Human Vitamin and Mineral Requirements." 2001
- Weaver CM, Heaney RP. "Calcium in Human Health." 1999
- Schuchardt JP, Hahn A. "Intestinal Absorption and Factors Influencing Bioavailability of Magnesium." Curr Nutr Food Sci. 2017
- Levine M et al. "Vitamin C pharmacokinetics in healthy volunteers." PNAS. 1996
- Allen LH. "Causes of vitamin B12 and folate deficiency." Food Nutr Bull. 2008
- IZiNCG. "Assessment of the risk of zinc deficiency." Food Nutr Bull. 2004
- Dawson-Hughes B et al. "Vitamin D: Moving Forward to Address Emerging Science." 2005

## Absorption Rates by Nutrient

| Nutrient | Base Rate | High Context | Low Context |
|----------|-----------|-------------|-------------|
| Iron (heme) | 25% | 35% (with vit C) | 15% (with calcium) |
| Iron (non-heme) | 5% | 20% (with vit C + meat) | 2% (with phytates + tannins) |
| Calcium | 30% | 35% (with vit D) | 5% (high oxalate foods) |
| Zinc | 25% | 35% (animal source) | 15% (phytate-rich) |
| Vitamin D | 65% | 80% (with fat) | 50% (low fat meal) |
| Vitamin C | 80% | 90% (<200mg dose) | 50% (>1000mg dose) |
| B12 | 50% | 50% (normal IF) | 1.5% (high dose/no IF) |
| Folate | 50% | 60% (with vit C) | 30% (with alcohol) |
| Magnesium | 40% | 50% (with vit D) | 25% (phytate-rich) |
| Vitamin A | 75% | 80% (with fat) | 3-6% (beta-carotene conversion) |
| Vitamin E | 30% | 50% (with fat) | 10% (low fat) |
| Vitamin K | 20% | 40% (with fat) | 10% (low fat) |
| Potassium | 85% | 90% | 80% |
| Selenium | 80% | 90% | 70% |

## Enhancer/Inhibitor Rules

### Iron
- ENHANCER: Vitamin C in same meal → multiply non-heme absorption by 2-6x
- ENHANCER: Meat/fish/poultry in same meal → +50% non-heme absorption
- INHIBITOR: Tea/coffee within 1h → -60% non-heme absorption
- INHIBITOR: Calcium >300mg in same meal → -50% iron absorption
- INHIBITOR: Phytates (whole grains, legumes) → -50-80%

### Calcium
- ENHANCER: Vitamin D → +30% absorption
- ENHANCER: Lactose (dairy) → +10% absorption
- INHIBITOR: Oxalates (spinach, rhubarb) → -80% (spinach calcium is ~5% bioavailable)
- INHIBITOR: Phytates → -30%
- INHIBITOR: Excess sodium → increases urinary calcium loss

### Zinc
- ENHANCER: Animal protein → +40%
- INHIBITOR: Phytates → -50%
- INHIBITOR: Excess iron supplements → -30%
- INHIBITOR: Excess calcium → -20%

### Fat-soluble vitamins (A, D, E, K)
- ENHANCER: Dietary fat in same meal → +50-100% absorption
- Without fat: absorption can drop to 10-20%

## Implementation

On-device rules engine. For each nutrient consumed today:
1. Determine base absorption rate from source type (animal vs plant)
2. Check same-meal enhancers (vit C with iron, fat with ADEK)
3. Check same-meal inhibitors (calcium with iron, oxalates with calcium)
4. Compute estimated absorbed amount
5. Show as "Absorbed: ~Xmg of Ymg (Z%)" with tips
