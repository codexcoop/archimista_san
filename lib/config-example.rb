# Esempio di file di configurazione
#
# 1. Creare il file di configurazione archimista_san/lib/config.rb, copiando il contenuto di questo file
# 2. Modificare i valori dei parametri secondo le proprie esigenze

# Directory di destinazione dei file xml generati.
# Il valore predefinito "." indica che i file verranno creati nella directory radice di Archimista.
DEST_DIR = "."

# Sistema aderente SAN.
PROVIDER = "ABC"

# Url base dei complessi archivistici.
FONDS_URL = "http://www.example.com/fonds"

# Url base dei soggetti produttori.
CREATORS_URL = "http://www.example.com/creators"

# Url base dei soggetti conservatori.
CUSTODIANS_URL = "http://www.example.com/custodians"

# Url base degli oggetti digitali.
DIGITAL_OBJECTS_URL = "http://www.example.com/digital_objects"

# Parametri forniti dalla redazione SAN per l'esportazione di oggetti digitali.
DL_SISTEMA_ADERENTE = "ABC"
DL_PROGETTO_DIGITALIZZAZIONE = "ABC:san.cat.prjDgt.000"
DL_CONSERVATORE = "san.cat.sogC.000"
DL_COMPLESSO = "san.cat.complArch.000"

