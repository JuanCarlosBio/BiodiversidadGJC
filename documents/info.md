# INFORMACIÓN sobre el Woekflow

## FOTOGRAFÍAS DE LAS ESPECIES

La siguiente información de las especies se han obtenido principalmente del buscador [***"Biota"***](https://www.biodiversidadcanarias.es/biota/)

Las fotografías en formato JPG están nombradas con la información de las especies, mediante el uso guiones altos ("```-```") para separar la información, que se procesarán en los programas. 

* Las imágenes de invertebrados tienen la siguiente información: 

```
ID-Especie-Autor-Nombre común-Familia-Orden-Clase-Filo-Reino Metazoa-Género Endémico (Canarias)-Especie Endémica (Canarias)-Subespecie Endémica (Canarias)-Origen-Categoría (especie protegida o invasora)
``` 

* La información de la flora y vegetación: 

```
ID-Especie-Autor-Nombre común-Familia-Orden-Clase-Subdivisión-División-Reino Plantae-Género Endémico (Canarias)-Especie Endémica (Canarias)-Subespecie Endémica (Canarias)-Origen-Categoría (especie protegida o invasora)
``` 

* Ejemplo de una de especie:

```
FV0022-Pinus canariensis-C. Sm. ex DC.in Buch-Pino canario-pinaceae-pinales-pinopsida-coniferophytina-spermatophyta-plantae-eg_no-ee_si--ns-ep.jpg
```

### **Aclaraciones:** 

- En caso de no identificar un parámetro en concreto no se añade nada entre los guiones (ej. AI0001 no tiene nombre común identificado: ```FV0022-...--...```).

- En caso de no identificarse la especie se anota como: ```"Su ID"-NO CLASIFICADO.jpg```.

- Las variables **género, especie y subespecie endémicas** se tratan de variables binarias:

  |         **Variable**           | **Endémico**    | **NO Endémico** | 
  | ------------------------------ | --------------- | --------------- |
  | Género Endémico (Canarias)     |      eg_si      |   eg_no         | 
  | Especie Endémica (Canarias)    |      ee_si      |   ee_no         |
  | Subespecie Endémica (Canarias) |      es_si      |   es_no         |

- La variable **origen** tiene los sigientes valores:

  | **Valor**  |  **Significado**               | 
  | ---------- | ------------------------------ |
  | ns         | Nativo Seguro                  | 
  | np         | Nativo Probable                |
  | isi        | Introdicido seguro invasor     |
  | isn        | Introducido seguro no invasor  |
  | ip         | Introducido probable           |

- La variable **Categoría** explica como está catalogada la especie.

  | **Valor**  |  **Significado**               | 
  | ---------- | ------------------------------ |
  | ep         | **Especie protegida**          | 
  | ei         | **Especie invasora**           |

- En caso de tildes, el software utilizado no es capaz de leerlos, en ese caso de haber alguna palabra con tilde se deberá escribir la sílaba entre dos _ y una t (ejemplo: `_ta_` = tilde en la a, `á`). Similar con la ñ (`_enie_` = `ñ`). Otro tipo de carácter especial como `¨` está en vías de desarrollo, por el momento no lo pongo en los nombres de las imágenes.

  | `á`       | `é`       | `í`       | `ó`       | `ú`       | `ñ`       | 
  | -------   | -------   | -------   | -------   | -------   | -------   |
  | `_ta_`    | `_te_`    | `_ti_`    | `_to_`    | `_tu_`    | `_enie_`  | 
