## Fiscal Estate in Medieval Italy: Continuity and Change (9th – 12th centuries)

This database, built with [EFES](https://github.com/EpiDoc/EFES), is the main output of the research project *FISCUS. Fiscal Estate in Medieval Italy: Continuity and Change (9th-12th Centuries)*. The project focused on the fiscal assets and the revenues managed by royal officials and ecclesiastical elites in the early and high Middle Ages.

----

EFES is licensed under the Apache 2.0 open software license,
and is copyright the University of London, King's College London,
and all [listed individual contributors](https://github.com/EpiDoc/EFES/wiki/About-the-project).

----

## Configurazione
1. Creare un account su GitHub https://github.com/ e inviare al proprio referente il proprio username per essere aggiunti come editor; nella email che arriverà, cliccare su ‘accetta invito’
2. Scaricare GitHub Desktop https://desktop.github.com/ e accedere con l'account appena creato

   2a. Se l’ultima versione di GitHub Desktop non è compatibile con il proprio sistema operativo, è possibile scaricare una versione precedente da https://github.en.uptodown.com/windows/versions o https://github.en.uptodown.com/mac/versions. Per disattivare gli aggiornamenti automatici:
    - Windows: eliminare il file Update.exe generato da GitHub https://www.thewindowsclub.com/what-is-update-exe-from-github
    - Mac: andare in Applicazioni, cliccare sul destro su ‘GitHub Desktop’, selezionare ‘Ottieni informazioni’ e mettere la spunta a ‘Bloccato’; quando chiederà di poter installare un update, negare il permesso. Oppure, su macOS 10.12: https://github.com/desktop/desktop/issues/3410#issuecomment-1143941309.
3. Scaricare la cartella generale https://github.com/FiscalEstate/Fiscus, cliccando su 'Code' e poi su 'Open with GitHub Desktop'. Nella schermata che appare non cambiare il 'Repository URL'; è possibile invece cambiare il 'Local Path', che è dove la cartella verrà salvata sul proprio computer; cliccare poi su 'Clone'
4. Scaricare una versione di Oxygen XML Editor compatibile con la licenza Oxygen in proprio possesso (https://www.oxygenxml.com/xml_editor/software_archive_editor.html) ed inserire la licenza.
5. Andare in Oxygen su Preferenze > Document Type Associations > Locations, selezionare 'Custom' e indicare la cartella 'fiscus_framework' all'interno della cartella appena scaricata (webapps/ROOT/content/fiscus_framework).

## Creazione/modifica schede
- webapps/ROOT/content/fiscus_framework/templates: template fiscus-template.xml
- webapps/ROOT/content/fiscus_framework/resources: places.xml, people.xml, estates.xml, juridical_persons.xml ('schede di II livello')
- webapps/ROOT/content/xml/epidoc: schede documento ('schede di I livello')

1. Per creare una scheda di I livello, creare una copia del template e salvarla in webapps/ROOT/content/xml/epidoc, rinominandola con il numero del documento che si sta creando (a ciascun collaboratore è assegnato un range di numeri da utilizzare per la numerazione delle proprie schede, indicato [qui](https://docs.google.com/document/d/17_lKbWBAqnTlzafvdUV0CYfxk4nb7GXKj95enWb6yp8/edit); NB: nel nome del file non devono esserci spazi)
2. Per creare una scheda di II livello, aprire il corrispondente file xml contenuto in webapps/ROOT/content/fiscus_framework/resources e crearla all'interno della propria sezione (a ciascun collaboratore è assegnata una sezione della lista, con il proprio nome nell'intestazione)
3. Per sincronizzare le proprie modifiche con la cartella online: https://github.com/FiscalEstate/Fiscus/blob/master/GitHub.md
