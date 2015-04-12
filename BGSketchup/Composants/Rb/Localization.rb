module BGSketchup_Components_Localization
	module ClassMethods

		def initialise_localization
			@strWindowName="Component manager"
			@strMenuComposants="Components"
			@strMenuGestionnaireComposants="Components manager"
			@strMenuOption="Options"
			@strMenuVerifierpresence="Check if files exist"
			@strAPropos="BGSketchup Component manager version "+BGSketchup_Composants_extension.version+10.chr+13.chr+10.chr+13.chr+"Created on Dec,2013 by BGSketchup."+10.chr+13.chr+10.chr+13.chr+bgSketchup_to_java("http://sketchucation.com/forums/viewtopic.php?p=505544#p505544")
			@strPanelOuvrir="Link to file"
			@strPanelEnregistrer="Save component as..."
			@strFichierAncien="Saved file is older!"
			@strFichierRecent="Saved file is newer!"
			@strRemplacerFichierExistant="Overwrite file?"
			@strErreurEnregistrement="Error saving component! Please check file access."
			@strEnregistrementOK = "File saved!"
			@strFichierPasAtteignable="File can't be reached, definition won't be reloaded."
			@strFichierPasAtteignable2="File can't be reached"
			@strEnregistrerDefinitions="Save all components?"
			@strErreurEnregistrementDefinition="Error saving Component "
			@strErreurEnregistrementDefinition2=". Please check access to file ("
			@strMAJDefinitions="Do you want to reload all components?"
			@strGroupe=""
			@strRenommer="Rename"
			@strNouveauNom="New name : "
			@strComposantRenommeEn = "Definition automatically renamed by Sketchup in : "
			@strEditerSketchup ="Component was edit in Sketchup. Update defintion from file ?"
			@strEditerAnnulerEgalRelance="(Cancel = remind me in few seconds !)"
			@strEnregistrerNouvelIndice="Save with new revision level ?"
			@strPasserSiInexistant="Pass if path doesn't exist ?"
			@strNbEnregistementDefinitions="Definitions saved"
			@strMAJComposant="Do you want to update the component '"
			@strCheminNOK = "Can't access path!"
			@strAvancementMAJ="Updating: "
			@strHeureMAJListe= bgSketchup_to_java("List update at ")
			@strEn=" in "
			@strSec=" s."
			@strChangePathsToRelative="Change paths to relative "
			@strChangeDateToNow="Change modification dates to now "
			@strDateForAll="Updating definitions data"
			@strModifierLienRelatif="Modify component full path ?"+10.chr+13.chr+10.chr+13.chr+"If you click No, the new path will be saved only as relative path and component won't be uploaded from file. Then do not reload component using Sketchup reload function."
			
			#Options
				@strOui="Yes"
				@strNon="No"
				@strOptions="Options"
				@strOptionsList=["Language : ",
					"Auto-start component manager on start up",
					"Activate component management on SU start up",
					"Show list in tree style",
					"Auto-start : don t load list on start up",
					"List updating frequency when editing a component in new SU instance (in seconds)",
					"Auto-check file paths",
					"Bright red for component OLDER than file",
					"Auto-select instances in model",
					"Auto-select instances in list",
					"Use revision level system",
					"Revision text identification : ",
					"Save window size",
					"Show groups without sub-components"]
				@strOptionsTitles=["Options","General","List","Linked files","Selection","Revision management system","Save","Cancel"]
				@strTreeListOptionToBeSelected="You must unchecked option '"+@strOptionsList[3]+"' in options."


			#HTML text, pay attention to use javscript strings standard
				#List texts
					@strDateFichierPlusAncien=bgSketchup_to_java("File is OLDER than component")
					@strDateFichierPlusRecent=bgSketchup_to_java("File is NEWER than component")
					@strComposantAJour=bgSketchup_to_java("Component up to date")
					@strCheminFichierNOK=bgSketchup_to_java("File path doesn't exist")
					@strPasCheminDefintion=bgSketchup_to_java("Component has no associated file")
					@strPasDateDefinition=bgSketchup_to_java("Component has no defined date")
					@strPasDateOuCheminDefinition=bgSketchup_to_java("Component has no defined date or path")
					@strGrey=bgSketchup_to_java("Component not verified")
					@strGroupSansNom= bgSketchup_to_java("Unnamed Group")
					
				#HTML buttons titles
					@strButtonsTitles = ["Update list",
						"Select component instances",
						"Modify file's path",
						"Save selected component",
						"Reload selected component",
						"Save all components",
						"Reload all components",
						"Filter",
						"Options",
						"About",
						"Set date/path for all"]
					@strContextMenuTitles = [@strButtonsTitles[1],@strButtonsTitles[3],@strButtonsTitles[4],"Edit component","Rename"]
					@strRefreshListMessage=bgSketchup_to_java("Please refresh the list")
				
				#HTML Filter window
					@strFilterTitles=["Group",@strGrey,@strComposantAJour,@strPasDateOuCheminDefinition,@strCheminFichierNOK,@strDateFichierPlusRecent,@strDateFichierPlusAncien]
					@strFilterSelectAll=bgSketchup_to_java("Select / Unselect all")
					@buttonApply=bgSketchup_to_java("Apply")
					@buttonCancel=bgSketchup_to_java("Cancel")
					@nothingToShow=bgSketchup_to_java("Nothing to show due to filters")
					
				#Html windows name
					@strAbout=bgSketchup_to_java("About...")
					@strFilters=bgSketchup_to_java("Filters")
			
			
			@availableLanguages=["en","fr","pt","es"]
			@availableLanguagesName=["English","Français","Português","Espanhol"]
			@option_langue="en" if @availableLanguages.index(@option_langue)==nil
			
			if @option_langue=="fr" then
				@strWindowName="Gestionnaire composant"
				@strMenuComposants="Composants"
				@strMenuGestionnaireComposants="Gestionnaire de composants"
				@strMenuOption="Options"
				@strMenuVerifierpresence="Vérifier l'existance des fichiers"
				@strAPropos="BGSketchup Gestionnaire de composants version "+BGSketchup_Composants_extension.version+10.chr+13.chr+10.chr+13.chr+"Créé en Décembre 2013 par BGSketchup."+10.chr+13.chr+10.chr+13.chr+bgSketchup_to_java("http://sketchucation.com/forums/viewtopic.php?p=505544#p505544")
				@strPanelOuvrir="Lien vers le fichier"
				@strPanelEnregistrer="Enregistrer la définition sous..."
				@strFichierAncien="Le fichier enregistré est plus ancien"
				@strFichierRecent="Le fichier enregistré est plus récent"
				@strRemplacerFichierExistant="Voulez-vous écraser le fichier existant ?"
				@strErreurEnregistrement="Erreur lors de l'enregistrement de la définition. Veuillez vérifier l'accès au fichier"
				@strEnregistrementOK="Enregistrement correctement effectué"
				@strFichierPasAtteignable="Le fichier n'est pas atteignable, la nouvelle définition ne sera pas chargée"
				@strFichierPasAtteignable2="Le fichier n'est pas atteignable"
				@strEnregistrerDefinitions="Etes-vous sûr de vouloir enregistrer toutes les définitions ?"
				@strErreurEnregistrementDefinition="Erreur lors de l'enregistrement de la définition "
				@strErreurEnregistrementDefinition2=". Veuillez vérifier l'accès au fichier ("
				@strMAJDefinitions="Etes-vous sûr de recharger à jour toutes les définitions ?"
				@strGroupe=""
				@strRenommer="Renommer"
				@strNouveauNom="Nouveau nom : "
				@strComposantRenommeEn = "La definiton a été automatiquement renommée par sketchup en : "
				@strEditerSketchup ="Le composant a été édité dans sketchup. Voulez-vous mettre à jour sa définition ?"
				@strEditerAnnulerEgalRelance="(Annuler = rapeller dans quelques instant de mettre à jour)"
				@strEnregistrerNouvelIndice="Voulez-vous enregistrer dans un nouvel indice ?"
				@strPasserSiInexistant="Passer si chemin inexistant ?"
				@strNbEnregistementDefinitions="Enregistrement des définitions effectuées"
				@strMAJComposant="Voulez-vous mettre à jour le composant '"
				@strCheminNOK = "Le chemin n'est pas accessible !"
				
				#Options
					@strOui="Oui"
					@strNon="Non"
					@strOptions="Options"
					@strOptionsList=["Langue : ",
						"Démarrer le gestionnaire avec Sketchup",
						"Activer la gestion des composant avec Sketchup",
						"Liste sous forme d'arbre",
						"Ne pas mettre la liste à jour au démarrage",
						"Fréquence de mise à jour si édition composant dans nouvelle instance Skectup (en secondes)",
						"Vérfier automatiquement les fichiers",
						"Rouge vif pour composant plus vieux que le fichier",
						"Selectionner automatiquement le composant dans le modèle",
						"Selectionner automatiquement le composant dans la liste",
						"Utiliser le système d'indice",
						"Texte identifiant l'indice : ",
						"Enregistrer taille de la fenêtre",
						"Montrer aussi les groupes ne contenant pas de composant"]
					@strOptionsTitles=["Options","Général","Liste","Fichiers liés","Sélection","Gestion des indices","Enregistrer","Annuler"]
					@strTreeListOptionToBeSelected="Vous devez décocher l'option '"+@strOptionsList[3]+"' dans les options."
					
				#Texte HTML, attention de respecter les règles du javascript pour les chaînes de caractère
					#List texts
						@strDateFichierPlusAncien=bgSketchup_to_java("Le fichier est plus ANCIEN que le composant")
						@strDateFichierPlusRecent=bgSketchup_to_java("Le fichier est plus RECENT que le composant")
						@strComposantAJour=bgSketchup_to_java("Composant à jour")
						@strCheminFichierNOK=bgSketchup_to_java("Le lien vers la définition n'existe pas")
						@strPasDateDefinition=bgSketchup_to_java("Pas de date définie dans la définition")
						@strPasCheminDefintion=bgSketchup_to_java("Pas de chemin définit dans la définition")
						@strPasDateOuCheminDefinition=bgSketchup_to_java("Pas de date ou chemin défini dans la définition")
						@strGrey=bgSketchup_to_java("Composant non vérifié")
						@strGroupSansNom= bgSketchup_to_java("Groupe sans nom")
						@strHeureMAJListe= bgSketchup_to_java("Liste mise à jour à ")
						@strEn=" en "
						@strSec=" s."
					
					#Titres des boutons de la page HTML
						@strButtonsTitles = ["Mise à jour de la liste",
							"Sélectionner le composant",
							"Modifier le chemin de la définition",
							"Enregistrer la définition sélectionnée",
							"Recharger la définition sélectionnée",
							"Enregistrer toutes les définitions",
							"Recharger toutes les définitions",
							"Filtrer",
							"Options",
							"A propos",
							"Définir la date ou le chemin de tous les composants"]
						@strContextMenuTitles = [@strButtonsTitles[1],@strButtonsTitles[3],@strButtonsTitles[4],"Modifier composant","Renommer"]
						@strRefreshListMessage=bgSketchup_to_java("Merci de rafraîchir la liste")
						
					#HTML Filter window
						@strFilterTitles=["Groupe",@strGrey,@strComposantAJour,@strPasDateOuCheminDefinition,@strCheminFichierNOK,@strDateFichierPlusRecent,@strDateFichierPlusAncien]
						@strFilterSelectAll=bgSketchup_to_java("Sélectionner / Désélectionner tout")
						@buttonApply=bgSketchup_to_java("Apply")
						@buttonCancel=bgSketchup_to_java("Cancel")
						@nothingToShow=bgSketchup_to_java("Rien à afficher dans cette liste à cause des filtres")
						
					#Html windows name
						@strAbout=bgSketchup_to_java("A propos...")
						@strFilters=bgSketchup_to_java("Filtres")

			elsif @option_langue=="es" then
				@strWindowName="Gestor de Componentes"
				@strMenuComposants="Componentes"
				@strMenuGestionnaireComposants="Gestor de Componentes"
				@strMenuOption="Opciones"
				@strMenuVerifierpresence="Revisar si existen archivos"
				@strAPropos="BGSketchup Versión de Gestor de Componente "+BGSketchup_Composants_extension.version+10.chr+13.chr+10.chr+13.chr+"Creado en Diciembre de 2013 por BGSketchup."+10.chr+13.chr+10.chr+13.chr+bgSketchup_to_java("http://sketchucation.com/forums/viewtopic.php?p=505544#p505544")
				@strPanelOuvrir="Enlazar a Archivo"
				@strPanelEnregistrer="Guardar componente como..."
				@strFichierAncien="¡El archivo guardado es más viejo!"
				@strFichierRecent="¡El archivo guardado es más nuevo!"
				@strRemplacerFichierExistant="¿Sobreescribir archivo?"
				@strErreurEnregistrement="¡Error guardando componente! Por vaor revisa el acceso al archivo."
				@strEnregistrementOK = "¡Archivo guardado!"
				@strFichierPasAtteignable="No se pudo acceder al archivo, la definición no se recargará."
				@strFichierPasAtteignable2="No se pudo acceder al archivo"
				@strEnregistrerDefinitions="¿Guardar todos los componentes?"
				@strErreurEnregistrementDefinition="Error guardando Componente "
				@strErreurEnregistrementDefinition2=". Por favor revisa el acceso al archivo ("
				@strMAJDefinitions="¿Quieres recargar todos los componentes?"
				@strGroupe=""
				@strRenommer="Renombrar"
				@strNouveauNom="Nuevo Nombre:      "
				@strComposantRenommeEn = "Definición renombrada automáticamente por Sketchup en: "
				@strEditerSketchup ="El Componente fue editado en Sketchup. ¿ Actualizar definición desde archivo ?"
				@strEditerAnnulerEgalRelance="(¡Cancelar = recordarmelo en pocos segundos!)"
				@strEnregistrerNouvelIndice="¿Guardar con nuevo nivel de revisión?"
				@strPasserSiInexistant="¿Pasar si la ruta no existe?"
				@strNbEnregistementDefinitions="Definiciones guardadas"
				@strMAJComposant="¿Quieres actualizar el componente '"
				@strCheminNOK = "¡No se puede acceder a la ruta!"
				@strAvancementMAJ="Actualizando: "
				@strHeureMAJListe= bgSketchup_to_java("Lista actualizada a las ")
				@strEn=" en "
				@strSec=" s."
				@strChangePathsToRelative="Cambiar rutas a relativas "
				@strChangeDateToNow="Cambiar fechas de modificación a ahora              "
				@strDateForAll="Actualizando datos de definiciones"
				@strModifierLienRelatif="¿ Modificar ruta completa de componente ?"+10.chr+13.chr+10.chr+13.chr+"Si haces clic en No, la nueva ruta se guardará sólo como una ruta relativa y el componente no se podrá cargar desde el archivo. Entonces no recargar componente usando la función recargar de Sketchup."

				#Options
					@strOui="Si"
					@strNon="No"
					@strOptions="Opciones"
					@strOptionsList=["Idioma : ",
						"Auto-inicio Gestor de Componente al inicio",
						"Activar Gestor de Componente al iniciar SU",
						"Mostrar Lista en Estilo Árbol",
						"Auto-inicio : no cargar lista al inicio",
						"Frecuencia actualización Lista cuando se edita componente en nueva instancia SU (segundos)",
						"Auto-revisar rutas de archivo",
						"Rojo vivo para componente MÁS VIEJO que archivo",
						"Auto-seleccionar Instancias en Modelo",
						"Auto-seleccionar Instancias en Lista",
						"Usar Sistema Nivel de Revisión",
						"Identificación texto de Revisión: ",
						"Guardar tamaño y posición de ventana",
						"Mostrar Grupos sin Sub-Componentes"]
					@strOptionsTitles=["Opciones","General","Lista","Archivos Enlazados","Selección","Sistema Gestión de Revisión","Guardar","Cancelar"]
					@strTreeListOptionToBeSelected="Debes desmarcar la opción '"+@strOptionsList[3]+"' en Opciones."

				#HTML text, pay attention to javscript string standards
				#List texts
					@strDateFichierPlusAncien=bgSketchup_to_java("El archivo es más VIEJO que el componente")
					@strDateFichierPlusRecent=bgSketchup_to_java("El archivo es más NUEVO que el componente")
					@strComposantAJour=bgSketchup_to_java("Componente está actualizado")
					@strCheminFichierNOK=bgSketchup_to_java("La ruta del archivo no existe")
					@strPasCheminDefintion=bgSketchup_to_java("El Componente no tiene archivo asociado")
					@strPasDateDefinition=bgSketchup_to_java("El Componente no tiene fecha definida")
					@strPasDateOuCheminDefinition=bgSketchup_to_java("El Componente no tiene fecha o archivo definida")
					@strGrey=bgSketchup_to_java("Componente no verificado")
					@strGroupSansNom= bgSketchup_to_java("Grupo Sin nombre")
					
				#HTML buttons titles
					@strButtonsTitles = ["Actualizar Lista",
						"Seleccionar instancias de componente",
						"Modificar ruta de archivo",
						"Guardar componente seleccionado",
						"Recargar componentes seleccionado",
						"Guardar todos los componentes",
						"Recargar todos los componentes",
						"Filtro",
						"Opciones",
						"Acerca de",
						"Ajustar Fecha/Ruta para Todo"]
					@strContextMenuTitles = [@strButtonsTitles[1],@strButtonsTitles[3],@strButtonsTitles[4],"Editar componente","Renombrar"]
					@strRefreshListMessage=bgSketchup_to_java("Por favor actualiza la lista")
					
				#HTML Filter window
					@strFilterTitles=["Grupo",@strGrey,@strComposantAJour,@strPasDateOuCheminDefinition,@strCheminFichierNOK,@strDateFichierPlusRecent,@strDateFichierPlusAncien]
					@strFilterSelectAll=bgSketchup_to_java("Seleccionar / Deseleccionar Todo")
					@buttonApply=bgSketchup_to_java("Aplicar")
					@buttonCancel=bgSketchup_to_java("Cancelar")
					@nothingToShow=bgSketchup_to_java("Nada para mostrar debido a los filtros")
				
				#Html windows name
					@strAbout=bgSketchup_to_java("Acerca de...")
					@strFilters=bgSketchup_to_java("Filtros")
					
			elsif @option_langue=="pt" then
				@strWindowName="Gestor de Componentes"
				@strMenuComposants="Componentes"
				@strMenuGestionnaireComposants="Gestor de Componentes"
				@strMenuOption="Opções"
				@strMenuVerifierpresence="Verificar se os ficheiros existem"
				@strAPropos="BGSketchup Versão do Gestor de Componentes  "+BGSketchup_Composants_extension.version+10.chr+13.chr+10.chr+13.chr+"Criado em Dezembro de 2013 por BGSketchup."+10.chr+13.chr+10.chr+13.chr+bgSketchup_to_java("http://sketchucation.com/forums/viewtopic.php?p=505544#p505544")
				@strPanelOuvrir="Ligação ao ficheiro"
				@strPanelEnregistrer="Guardar componente como..."
				@strFichierAncien="Ficheiro gravado é mais antigo"
				@strFichierRecent="Ficheiro gravado é mais novo"
				@strRemplacerFichierExistant="Substituir ficheiro?"
				@strErreurEnregistrement="Erro a gravar componente! Por favor, Verifique as permissões de acesso ao ficheiro!"
				@strEnregistrementOK = "Ficheiro gravado!"
				@strFichierPasAtteignable="O ficheiro não foi encontrado, o componente não será actualizado."
				@strFichierPasAtteignable2="O ficheiro não foi encontrado"
				@strEnregistrerDefinitions="Gravar todos os componentes?"
				@strErreurEnregistrementDefinition="Erro a gravar componente "
				@strErreurEnregistrementDefinition2=". Por favor verifique o acesso ao ficheiro ("
				@strMAJDefinitions="Quer recarregar todos os componentes?"
				@strGroupe=""
				@strRenommer="Rename"
				@strNouveauNom="New name : "
				@strComposantRenommeEn = "Definition automatically renamed by Sketchup in : "
				@strEditerSketchup ="Component was edit in Sketchup. Update defintion from file ?"
				@strEditerAnnulerEgalRelance="(Cancel = remind me in few seconds !)"
				@strEnregistrerNouvelIndice="Save with new revision level ?"
				@strFrequenceRappelMAJ="Frequency to ask updating list (in seconds) : "
				@strPasserSiInexistant="Pass if path doesn't exist ?"
				@strNbEnregistementDefinitions="Definitions saved"
				
				#Options
					@strOui="Sim"
					@strNon="Não"
					@strOptions="Opções"
					@strOptionsList=["Language : ",
						"Auto-start component manager on start up",
						"Activate component management on SU start up",
						"Show list in tree style",
						"Auto-start : don t load list on start up",
						"List updating frequency when editing a component in new SU instance (in seconds)",
						"Auto-check file paths",
						"Bright red for component OLDER than file",
						"Auto-select instances in model",
						"Auto-select instances in list",
						"Use revision level system",
						"Revision text identification : ",
						"Save window size",
						"Show groups without sub-components"]
					@strOptionsTitles=["Options","General","List","Linked files","Selection","Revision management system","Save","Cancel"]
					@strTreeListOptionToBeSelected="You must unchecked option '"+@strOptionsList[3]+"' in options."
					
				#HTML text, pay attention to javscript string standards
					@strDateFichierPlusAncien=bgSketchup_to_java("O ficheiro é mais ANTIGO que o componente")
					@strDateFichierPlusRecent=bgSketchup_to_java("O ficheiro é mais NOVO que o componente")
					@strComposantAJour=bgSketchup_to_java("componente é atualizado")
					@strCheminFichierNOK=bgSketchup_to_java("O caminho do ficheiro não existe")
					@strPasCheminDefintion=bgSketchup_to_java("O componente não tem um ficheiro associado")
					@strPasDateDefinition=bgSketchup_to_java("O componente não tem data definida")
					@strPasDateOuCheminDefinition=bgSketchup_to_java("O Componente não tem data ou ficheiro definido")
					@strGrey=bgSketchup_to_java("Component not verified")
					@strGroupSansNom= bgSketchup_to_java("Grupo sem nome")
					@strHeureMAJListe= bgSketchup_to_java("List updated at ")
					@strEn=" em "
					@strSec=" s."
				#HTML buttons titles
					@strButtonsTitles = [
						"Actualizar lista",
						"Seleccionar cópias do componente",
						"Modificar caminho do ficheiro",
						"Gravar componente seleccionado",
						"Recarregar componente seleccionado",
						"Gravar todos os componentes",
						"Recarregar todos os componentes",
						"Filtro",
						"Opções",
						"Sobre",
						"Set date/path for all"]
					@strContextMenuTitles = [@strButtonsTitles[1],@strButtonsTitles[3],@strButtonsTitles[4],"Edit component","Rename"]
					@strRefreshListMessage=bgSketchup_to_java("Please refresh the list")
				#HTML Filter window	
					@strFilterTitles=["Groupo",@strGrey,@strComposantAJour,@strPasDateOuCheminDefinition,@strCheminFichierNOK,@strDateFichierPlusRecent,@strDateFichierPlusAncien]
					@strFilterSelectAll=bgSketchup_to_java("Seleccionar / Deseleccionar todo")
					@buttonApply=bgSketchup_to_java("Aplicar")
					@buttonCancel=bgSketchup_to_java("Cancelar")
					@nothingToShow=bgSketchup_to_java("Nada para mostrar devido aos filtros")
				#Html windows name
					@strAbout=bgSketchup_to_java("Acerca de...")
					@strFilters=bgSketchup_to_java("Filtros")
			end
		end
	end# ClassMethods
	extend ClassMethods
	def self.included( other )
		other.extend( ClassMethods )
	end
end