# Archimista San

**NOTA: modulo in lavorazione**

Archimista San è un plugin per Archimista che consente l'esportazione di metadati in formato SAN (Sistema Archivistico Nazionale).

## Installazione

TODO: Archimista 1 / Archimista 2

Creare il file di configurazione archimista_san/lib/config.rb, copiando il contenuto del file config-example.rb.
Modificare i valori dei parametri secondo le proprie esigenze.

## Utilizzo

Qui o in pagina wiki.

Metadati relativi a risorse archivistiche:
```
rake build_xml[records]
```

Metadati relativi a oggetti digitali:
```
rake build_mets[fond_id]
```

## Crediti

Archimista San è sviluppato da [Codex](http://www.codexcoop.it), su incarico dell'Istituto Centrale per gli Archivi.

## Licenza

Archimista San è rilasciato sotto licenza MIT.
