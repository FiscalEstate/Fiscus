## Fiscal Estate in Medieval Italy: Continuity and Change (9th – 12th centuries)

This database, built with [EFES](https://github.com/EpiDoc/EFES), is the main output of the research project *FISCUS. Fiscal Estate in Medieval Italy: Continuity and Change (9th-12th Centuries)*. The project focused on the fiscal assets and the revenues managed by royal officials and ecclesiastical elites in the early and high Middle Ages.

EFES is licensed under the Apache 2.0 open software license,
and is copyright the University of London, King's College London,
and all [listed individual contributors](https://github.com/EpiDoc/EFES/wiki/About-the-project).

## Configurazione iniziale
1. Creare un account su GitHub https://github.com/ e inviare al proprio referente il proprio username per essere aggiunti come editor; nella email che arriverà, cliccare su ‘accetta invito’
2. Scaricare GitHub Desktop https://desktop.github.com/ e accedere con l'account appena creato

   2a. Se l’ultima versione di GitHub Desktop non è compatibile con il proprio sistema operativo, è possibile scaricare una versione precedente da https://github.en.uptodown.com/windows/versions o https://github.en.uptodown.com/mac/versions. Per disattivare gli aggiornamenti automatici:
    - Windows: eliminare il file Update.exe generato da GitHub https://www.thewindowsclub.com/what-is-update-exe-from-github
    - Mac: andare in Applicazioni, cliccare sul destro su ‘GitHub Desktop’, selezionare ‘Ottieni informazioni’ e mettere la spunta a ‘Bloccato’; quando chiederà di poter installare un update, negare il permesso. Oppure, su macOS 10.12: https://github.com/desktop/desktop/issues/3410#issuecomment-1143941309.
3. Scaricare la cartella generale https://github.com/FiscalEstate/Fiscus, cliccando su 'Code' e poi su 'Open with GitHub Desktop'. Nella schermata che appare non cambiare il 'Repository URL'; è possibile invece cambiare il 'Local Path', che è dove la cartella verrà salvata sul proprio computer; cliccare poi su 'Clone'
4. Scaricare una versione di Oxygen XML Editor compatibile con la licenza Oxygen in proprio possesso (https://www.oxygenxml.com/xml_editor/software_archive_editor.html) ed inserire la licenza.
5. Andare in Oxygen su Preferenze > Document Type Associations > Locations, selezionare 'Custom' e indicare la cartella 'fiscus_framework' all'interno della cartella appena scaricata (webapps/ROOT/content/fiscus_framework).

## Creazione schede
- webapps/ROOT/content/fiscus_framework/templates: template fiscus-template.xml
- webapps/ROOT/content/fiscus_framework/resources: places.xml, people.xml, estates.xml, juridical_persons.xml ('schede di II livello')
- webapps/ROOT/content/xml/epidoc: schede documento ('schede di I livello')

1. Per creare una scheda di I livello, creare una copia del template e salvarla in webapps/ROOT/content/xml/epidoc, rinominandola con il numero del documento che si sta creando (a ciascun collaboratore è assegnato un range di numeri da utilizzare per la numerazione delle proprie schede, indicato [qui](https://github.com/FiscalEstate/Fiscus/blob/master/Centinaia.md); NB: nel nome del file non devono esserci spazi)
2. Per creare una scheda di II livello, aprire il corrispondente file xml contenuto in webapps/ROOT/content/fiscus_framework/resources e crearla all'interno della propria sezione (a ciascun collaboratore è assegnata una sezione della lista, con il proprio nome nell'intestazione)
3. Per sincronizzare le proprie modifiche con la cartella online: https://github.com/FiscalEstate/Fiscus/blob/master/GitHub.md
4. Per visualizzare le proprie schede: https://fiscuslive.unibo.it/ (sito ad uso interno, contenente anche le schede in corso di lavorazione); https://fiscus.unibo.it/ (sito pubblico, contenente solo le schede ufficialmente pubblicate)

## Aggiunta di nuovi collaboratori
1. Aggiungere lo username in https://github.com/FiscalEstate/Fiscus/settings/access cliccando su 'Add people', assegnando il ruolo 'Write' (per poterlo fare è necessario avere il ruolo 'Admin' in GitHub: IV/LT)
2. Assegnare le centinaia (x5: documenti, places, people, estates, juridical persons) [qui](https://github.com/FiscalEstate/Fiscus/blob/master/Centinaia.md)
3. Aggiungere il nome del nuovo collaboratore in team.xml e fiscus.css e creare le sottoliste nelle schede di II livello (usando la modalità Text, non Author):

   3a. In webapps/ROOT/content/xml/tei/team.xml aggiungere 
   `<p xml:id="inizialenome+cognome"><emph><forename>Nome</forename> <surname>Cognome</surname></emph> università</p>` nella sezione dell’unità corrispondente (e.g. `<p xml:id="tlazzari"><emph><forename>Tiziana</forename> <surname>Lazzari</surname></emph> Università di Bologna</p>`); se il collaboratore era già inserito nella sezione nascosta (vedi sotto), toglierlo da lì. Se è ancora presto per far apparire ufficialmente il collaboratore nella pagina Team, è possibile aggiungerlo intanto nella sezione nascosta alla fine del file (`<div xml:id="hidden">/<head>Other collaborators</head></div>`) per poi spostarlo nelle sezioni visibili più avanti. 

   3b. Menu a tendina nelle schede di I livello: in webapps/ROOT/content/fiscus_framework/css/fiscus.css alle ll. 491-492 circa inserire nella lista dei 'values' l’id del collaboratore (iniziale nome + cognome, tutto attaccato e minuscolo, e.g. 'tlazzari'), mentre nella lista dei 'labels' il cognome e il nome, staccati e con la prima lettera maiuscola (e.g. 'Lazzari Tiziana'). NB: in entrambe le liste il nuovo inserimento deve rispettare l’ordine alfabetico per cognome; se la posizione del nuovo inserimento nella lista dei values non corrisponde alla posizione nella lista dei labels, salteranno tutte le associazioni fra id e nomi, e quando in una scheda di I livello verrà selezionato un nome dal menu a tendina verrà in realtà inserito un id diverso.

   3c. Nei 4 file delle schede di II livello in webapps/ROOT/content/fiscus_framework/resources/ aggiungere i seguenti blocchi placeholder, con 'Cognome Nome' del collaboratore dentro all’attributo `@n` nella prima linea, con 'XXX' come placeholder nella linea del nome della scheda (NB: deve essere proprio 'XXX', poiché il codice è stato impostato in modo da ignorare le schede aventi tale nome), e con in `<idno>` il primo numero del centinaio assegnato; il blocco deve essere inserito rispettando l’ordine alfabetico per cognome dei collaboratori (ogni lista inizia con la sezione generica 'All', a cui seguono le sezioni di ciascun collaboratore).

   ```
   In estates.xml:
   <listPlace n="Cognome Nome">
     <place> 
    <geogName>XXX</geogName>
    <geogName type="other"/>
    <idno>estates/3000</idno>
    <note/>
    </place>
   </listPlace>
   
   In places.xml:
   <listPlace n="Cognome Nome">
     <place>
     <placeName>XXX</placeName>
     <placeName type="other"/>
     <geogName type="coord"><geo/></geogName>
     <idno>places/3000</idno>
     <note/>
     </place>
   </listPlace>
   
   In people.xml:
   <listPerson n="Cognome Nome">
     <person>
     <persName>XXX</persName>
     <persName type="other"/>
     <idno>people/3000</idno>
     <note/>
     </person>
   </listPerson>
   
   In juridical_persons.xml:
   <listOrg n="Cognome Nome">
     <org>
     <orgName>XXX</orgName>
     <orgName type="other"/>
     <idno>juridical_persons/3000</idno>
     <note/>
     </org>
   </listOrg>
   ```
