#encode: utf-8
require 'sketchup.rb'


module BGSketchup_Composants
	@BGSketchup_dates_a_changer=false
	@BGSketchup_liste_entite_a_change_date=[]
	@BGSketchup_Composants_Update_in_progress="non"
	@BGSketchup_Composants_Demarre="non"
	@BGSketchup_Composants_Selection_en_cours=false		# Flag pour empêcher de déclencher la sélection dans la liste si on sélectionne dans la liste...
	
	require 'BGSketchup/Composants/Rb/Localization.rb'
	require 'BGSketchup/BGSketchup.rb'
	include BGSketchup
	include BGSketchup_Components_Localization
	def self.demarrer
		load_options
		initialise_localization
		@BGSketchup_Composants_Update_in_progress="non"
		@liste_definitions=[]
		@liste_branches_affichees=[]
		@filtres=[true, true, true, true, true, true, true]
		@w=nil
		@composantsAMAJ=[] #Liste des composants à mettre à jour
		initialize_window if @option_DemarrageAuto
	end
	
	def self.initialize_window
		return nil if @w!=nil #On n'affiche rien si la fenêtre est déjà affichée
		attacher_observers(false)
		@BGSketchup_Composants_Demarre="oui"
		@w = UI::WebDialog.new(@strWindowName+" "+BGSketchup_Composants_extension.version, false,"BGSketchup_Composants" , 316, 293, 100, 200, true)
		html_path = File.join(DIR, "Composants", "Html", "treeview.html")
		@w.set_file(html_path)
		@w.set_background_color("ffffff")
		if ( Object::RUBY_PLATFORM =~ /darwin/i ? true : false ) then
			@w.show_modal()
		else
			@w.show()
		end
		@w.set_on_close{ @w=nil	}
		@w.min_height = 302
		@w.min_width = 326-10+24+5
		@w.set_size(@option_PosFenL.to_i,@option_PosFenH.to_i)
		@element_selectionne=nil
		@Timer_message_en_cours=false
		
		@w.add_action_callback("get_data") do |web_dialog,action_name|
			maj_liste(action_name) if (action_name=="charger" && @option_DemarrageAutoMAJListe)
			maj_liste(action_name) if (action_name=="maj")						#Mettre à jour la liste
			afficher_info(action_name[13..action_name.length-2]) if action_name[0..11]=="clickElement" #Si on clique sur un élément de la liste, on affiche les infos
			changer_lien if action_name=="changer_lien"							#On veut changer le lien
			enregistrer_definition if action_name=="enregistrer_definition"		#Enregistrer la définition
			recharger_definition if action_name=="recharger_definition"			#Recharger la définition
			enregistrer_definitions if action_name=="enregistrer_definitions"	#Enregistrer les définitions
			recharger_definitions if action_name=="recharger_definitions"		#Recharger les définitions
			selectionner_instances if action_name=="selectionner_instances"		#Sélectionner les instances
			apropos if action_name=="apropos"									#A propos
			options if action_name=="options"									#Options
			charger_titres if action_name=="charger_titres"
			editer_composant if action_name=="editer_composant"
			renommer_composant if action_name=="renommer_composant"
			filters_window if action_name=="filters_window"
			save_options_html if action_name=="save_options_html"
			appliquerOptions(action_name[17..action_name.length-2]) if action_name[0..15]=="appliquerOptions"
			enregistrer_taille_fenetre(action_name[27..action_name.length-2]) if action_name[0..25]=="enregistrer_taille_fenetre"
			date_for_all if action_name=="date_for_all"
			hideBranch(action_name[11..action_name.length-2]) if action_name[0..9]=="hideBranch"
			showBranch(action_name[11..action_name.length-2]) if action_name[0..9]=="showBranch"
			if action_name=="start" then 
				self.charger_titres
				self.maj_liste("charger") if (@option_DemarrageAutoMAJListe)
			end
		end
	end
	def self.enregistrer_taille_fenetre(taille)
		if @option_EnregistrerPositionFenetre and taille!=nil then
			taille=taille.split(",")
			@option_PosFenH=taille[0]
			@option_PosFenL=taille[1]
			save_options
		end
	end
	
	def self.editer_composant
		if @element_selectionne!=nil then
			definition=@liste_definitions[@element_selectionne][0]
			return nil if (definition.is_a? Sketchup::Group)
			nouveau_chemin=bgSketchup_chemin_composant(definition)
			nouveau_chemin=bgSketchup_to_ascii(nouveau_chemin)
			nouveau_chemin=fichier_dernier_indice(nouveau_chemin,@option_TexteIndice) if @option_UtiliserIndice==true #check for new level
			if File.exist?(nouveau_chemin)!=false then 
				system('start sketchup "' + nouveau_chemin + '"') #Mettre start /wait sketchup pour attendre la fermeture de l'autre sketchup
			
				reponse=UI.messagebox @strEditerSketchup+10.chr+13.chr+@strEditerAnnulerEgalRelance,MB_YESNOCANCEL
				if reponse==6 then
					charge(definition,true,nil)
					maj_liste
				elsif reponse==2 then
					@id_rappel = UI.start_timer(@option_temps_rappel_maj, true) { rappellerMAJ(definition) }
				end
			else
				UI.messagebox @strMenuVerifierpresence
			end
		end
	end
	def self.rappellerMAJ(definition)
		if @Timer_message_en_cours==false then	#Si un message n'est pas déjà en cours
			if definition.deleted? ==false then
				@Timer_message_en_cours=true
				reponse=UI.messagebox @strMAJComposant+definition.name+"' ?", MB_YESNOCANCEL
				@Timer_message_en_cours=false
				if reponse==6 then 		#oui = on met à jour
					UI.stop_timer @id_rappel
					charge(definition,true,nil)
					maj_liste
				elsif reponse==7 then 	#non = on arrête le timer
					UI.stop_timer @id_rappel
				else					#annuler = on ne fait rien
				end
			else
				UI.stop_timer @id_rappel # Definition supprimée, on arrête le timer
			end
		end
	end
	
	def self.renommer_composant
		if @element_selectionne!=nil then
			definition=@liste_definitions[@element_selectionne][0]
			return nil if (definition.is_a? Sketchup::Group)
			input=UI.inputbox [@strNouveauNom],[definition.name],@strRenommer
			if input!=nil then
				definition.name=input[0]
				if definition.name!=input[0] then
					UI.messagebox @strComposantRenommeEn + definition.name
				end
				maj_liste
			end
		end
	end
	#To update the list
	def self.maj_liste(action_name="maj")
		return nil if @BGSketchup_Composants_Demarre!="oui" # Pas de mise à jour de la liste si la fenêtre n'est pas visible
		time_depart = Time.now
		viderListeAttribut #On met les dates dans les attributs des composants
		return nil if @w==nil
		@liste_definitions=[]
		liste=""
		# On liste les composants du fichiers
		if @option_AfficherAbre then
			liste=liste_composants(liste,Sketchup.active_model,0,Sketchup.active_model,Sketchup.active_model,nil)
		else
			liste=liste_composants2
		end
		if liste!="" then
			js_command =""
			js_command += "desactivateTree('LinkedList1');" if action_name=="maj" # On désactive les liens de la liste précédente
			js_command += "document.getElementById('LinkedList1').innerHTML='" << liste.to_s << "';"	# On ajoute la liste
			js_command += "addEvents('LinkedList1');"	# On initialise les liens de la liste
			@w.execute_script(js_command)
			if @option_AfficherAbre then
				#On essaye de développer l'arbre de la même façon qu'avant la mise à jour
				js=""
				@nouvelle_liste_branches_affichees=[]
				@liste_branches_affichees.each{ |definition|
					if !(definition.deleted?) then
						if !(definition.is_a? Sketchup::Group) then
							i=retrouve_entite(definition.instances[0])
							js+='showBranch2("'+i.to_s+'");'
						else #Group
							i=retrouve_entite(definition)
							js+='showBranch2("'+i.to_s+'");'
						end
						@nouvelle_liste_branches_affichees.push definition
					end
				}
				@w.execute_script(js)
				@liste_branches_affichees=@nouvelle_liste_branches_affichees
			end
		end			
		@element_selectionne==nil
		time=Time.new
		temps_execution=Time.now-time_depart
		h=@strHeureMAJListe+time.strftime("%H:%M:%S")+@strEn+temps_execution.to_s+@strSec
		Sketchup.status_text = h
		barre_etat(h)
	end
	def self.liste_composants(liste,entity,nb_instances_branche, instance=nil, ent_parent=nil, instancesID=nil)	#Ajoute à "liste" la liste des sous composants de entity (récursif)
		#liste = 					la liste avant l'ajout
		#entity = 					entité à ajouter dans la liste
		#nb_instannces_branche = 	nombre d'instance de "entity" dans la branche
		#instance = 				instance de "entity" qui a déclenché l'ajout dans la liste
		#ent_parent =				entité du parent de "entity"
		#instancesID =				tableau avec les entityID des autres instances de "entity" dans le parent de "entity"
		
		entity_de_depart=instance
		modele=(entity.is_a? Sketchup::Model)
		if (entity.is_a? Sketchup::ComponentInstance) || (entity.is_a? Sketchup::ComponentDefinition) || (entity.is_a? Sketchup::Group) || (entity.is_a? Sketchup::Model) then
			entity=entity.definition if (entity.is_a? Sketchup::ComponentInstance)
			#On regarde les sous-composants (on met tout dans liste2)
			trouve=false; liste2=""; l=[]; i=0; model_length=Sketchup.active_model.entities.length

			######################## SCAN OF SUB ELEMENTS ########################
			for ent in entity.entities
				#Show progress
					if modele==true then
						Sketchup.status_text = @strAvancementMAJ + ((1000*(i.to_f/model_length)).round.to_f/10).to_s + "%"
						i+=1
					end

				#Check entities
				if (ent.is_a? Sketchup::ComponentInstance) || (ent.is_a? Sketchup::ComponentDefinition) || (ent.is_a? Sketchup::Group) then
					inst=nil;inst=ent #if (ent.is_a? Sketchup::ComponentInstance)
					ent=ent.definition if (ent.is_a? Sketchup::ComponentInstance)
					nom = ent.name if (ent.is_a? Sketchup::ComponentDefinition)
					nom = nil if (ent.is_a? Sketchup::Group)
					
					if l.index(nom)==nil then 			#Si on a pas déjà ajouté le sous-composant
						liste2+='<ul>' if trouve==false
						trouve=true
						if (ent.is_a? Sketchup::ComponentDefinition) then 	#ComponentDefinition
							#Count instances number in parent
							nb=0; id=[]
							for entite in entity.entities
								if (entite.is_a? Sketchup::ComponentInstance) then
									if entite.definition==inst.definition then
										nb+=1
										id.push entite.entityID #ont pour parent "entity"
									end
								end
							end								
							liste2=liste_composants(liste2,ent,nb,inst,entity_de_depart,id) #Récursif (le père de la sous liste c'est ent)
						else #Group
							liste2=liste_composants(liste2,ent,1,inst,entity_de_depart,[ent.entityID]) 	#Récursif
						end
						l.push nom if nom!=nil
					else
						#On l'a déjà ajouté
					end
				end
			end
			#On met dans les 
			
			######################## ADD ELEMENTS TO LIST ########################
			if (entity.is_a? Sketchup::Model) then		#Si l'entity était le MODEL
				if liste2!="" && liste2!="<ul>" then 	#Il y a qqchose en dessous
					#On supprime le <ul> en début de liste
					liste2=liste2[4..liste.length-1]
					liste+=liste2
					return liste
				else 									#Il n'y a rien en dessous
					return ""
				end
			end
			
			#On les ajoute à la liste	
			liste+=li_element(entity,liste2,instance,ent_parent,instancesID).to_s
				
			if entity.is_a? Sketchup::Group then		#On a un GROUPE
			
			else										#On a un COMPOSANT
				#On ajout le nombre d'instance si on a coché l'option et qu'il y a plus d'une instance
					liste+= ' &#x21E8; ' + nb_instances_branche.to_s + "x" if nb_instances_branche!=1
				
				#On ajoute la sous-liste
					liste2="" if liste2=="<ul>"###############
					liste+=liste2 
					liste+="</ul>" if liste2[0..3]=="<ul>"
				#On ferme la liste
			end
		end
		return liste
	end
	def self.liste_composants2 #liste sans arborescence
		definitions=Sketchup.active_model.definitions
		liste=""
		for entity in definitions
			if !(entity.deleted?) && (!(entity.group?) || ((@option_afficher_groupes) && (entity.group?))) then
				liste2=""
				instance=entity.instances[0]
				
				ent_parent=Sketchup.active_model
				instancesID=[]
				for i in entity.instances
					instancesID.push i.entityID
				end
				nb_inst=entity.instances.length
				entity=entity.instances[0] if entity.group?
				l=li_element(entity,liste2,instance,ent_parent,instancesID)
				
				if l!=nil && l!="" then
					if 	(@filtres[0] || (l.index('class="group"')==nil)) && \
							(@filtres[1] || (l.index('class="grey')==nil)) && \
							(@filtres[2] || (l.index('class="uptodate')==nil)) && \
							(@filtres[3] || (l.index('class="unlinked')==nil)) && \
							(@filtres[4] || (l.index('class="no_link')==nil)) && \
							(@filtres[5] || (l.index('class="older')==nil)) && \
							(@filtres[6] || (l.index('class="newer')==nil)) then
						liste+=l
						liste+= ' &#x21E8; ' + nb_inst.to_s + "x" if nb_inst!=1 && (l.index('class="group"')==nil)
					else
					end
				end
			end
		end
		liste =@nothingToShow if liste==""
		return liste
	end
	
	def self.li_element(entity,liste2,instance,ent_parent,instancesID)
		liste=""
		if entity.is_a? Sketchup::Group then		#On a un GROUPE
			liste2="" if liste2=="<ul>"
			if liste2!="" ||@option_afficher_groupes==true then 	#Il y a qqchose en dessous
				liste+='<li class="group'
				liste+='_plus' if (liste2!="")
				liste+='" data-test="'+@liste_definitions.length.to_s+'" id="'+@liste_definitions.length.to_s+'">'
				liste+= bgSketchup_to_java(entity.name) if entity.name!=""
				liste+='(' + @strGroupSansNom + ')' if entity.name==""
				#On ajoute le group à la liste des définitions
				@liste_definitions.push [entity,ent_parent,instancesID]
				liste+=liste2
				liste+="</ul>" if liste2[0..3]=="<ul>" 
				liste+="</li>"
			end
		else										#On a un COMPOSANT
			entity=entity.definition if (entity.is_a? Sketchup::ComponentInstance)

			#On regarde le chemin actuel (par défaut le chemin relatif)
			chemin_actuel =bgSketchup_chemin_composant(entity)
			
			if chemin_actuel.to_s!="" then
				if @option_verifier_existance_fichier==true then #if @option_verifier_existance_fichier==true
					chemin_actuel=bgSketchup_to_ascii(chemin_actuel)
					if File.exist?(chemin_actuel)==true then
						date_fichier=bgSketchup_date_to_str(File.mtime(chemin_actuel))
						if (entity.attribute_dictionary "BGSketchup_Composants")!=nil then
							date_entity=entity.get_attribute "BGSketchup_Composants", "Date"
						else
							date_entity=nil
						end
						if date_fichier==date_entity then
							liste+='<li class="uptodate' 	#Chemin ok, date ok => VERT
						else
							if date_entity!=nil then
								if date_from_str(date_fichier)<date_from_str(date_entity) then
									liste+='<li title="' + @strDateFichierPlusAncien 	#Chemin ok, date nok => ROUGE
									if (@option_RecentRougeVif==true) then
										liste+='" class="older' # rouge foncé
									else
										liste+='" class="newer' # rouge vif
									end
								else
									liste+='<li title="' + @strDateFichierPlusRecent 	#Chemin ok, date nok => ROUGE
									if (@option_RecentRougeVif==true) then
										liste+='" class="newer' # rouge foncé
									else
										liste+='" class="older' # rouge vif
									end
								end
								
							else
								liste+='<li title="' + @strPasDateDefinition+ '" class="unlinked' 			#Chemin ok, date ? => BLEU
							end
						end
					else
						liste+='<li title="' + @strCheminFichierNOK+ '" class="no_link' 						#Chemin nok, date ? => ORANGE
					end
				else
					liste+='<li title="' + @strGrey+ '" class="grey' 											#Sans vérification => NOIR
				end
			else
				liste+='<li title="' + @strPasCheminDefintion+ '" class="unlinked'								#Sans lien vers un fichier => BLEU
			end
			#A chaque fois à la fin, on met :
			#La fin du nom de fichier
				if liste2!="" && liste2!="<ul>" then
					liste+= '_plus"'	# avec des sous-composants
				else
					liste+= '"'			# sans sous-composants
				end
			#On ajoute l'index dans la liste des définitions
				liste+= ' data-test="' 	+ @liste_definitions.length.to_s + '"'
				liste+= ' id="'			+ @liste_definitions.length.to_s + '" ' #if (instance.is_a? Sketchup::ComponentInstance)
				liste+= '>'
			#On met le nom de la definition dans le innerHTML
				liste+= bgSketchup_to_java(entity.name)
				
			#On ajoute à la liste des définitions
				@liste_definitions.push [entity,ent_parent,instancesID]			#dans la liste générale
		end
		return liste
	end
	
	def self.showBranch(num_element)
		definition=@liste_definitions[num_element.to_i][0]
		if @liste_branches_affichees.index(definition)==nil then
			@liste_branches_affichees.push definition
		end
	end
	def self.hideBranch(num_element)
		definition=@liste_definitions[num_element.to_i][0]
		@liste_branches_affichees.delete(definition)
	end
	def self.afficher_info(num_element)
		#On retrouve la définition du composant
			@element_selectionne=num_element.to_i
			definition=@liste_definitions[@element_selectionne][0]
			
			if !(definition.is_a? Sketchup::Group) then
				chemin=bgSketchup_chemin_composant(definition)
				if @option_verifier_existance_fichier==true then
					if chemin!="" && chemin!=nil then #Si un chemin existe
						if File.exist?(chemin)==true then	#et si le fichier existe
							#On compare les dates
							date_fichier=bgSketchup_date_to_str(File.mtime(chemin))
							date_definition=definition.get_attribute "BGSketchup_Composants", "Date"
							if date_definition !=nil then
								barre_etat(@strFichierAncien) if date_from_str(date_fichier)<date_from_str(date_definition)
								barre_etat(@strFichierRecent) if date_from_str(date_fichier)>date_from_str(date_definition)
								if date_from_str(date_fichier)==date_from_str(date_definition) then
									chemin = definition.get_attribute "BGSketchup_Composants", "Chemin"
									chemin = definition.path if chemin==nil
									barre_etat(chemin)
								end
							else
								barre_etat(@strPasDateDefinition)
							end
						else #Le fichier n'existe pas (lien cassé)
							#chemin = definition.get_attribute "BGSketchup_Composants", "Chemin"
							#chemin = definition.path if chemin==nil
							barre_etat(chemin)
						end
					else #On ne vérifie pas le chemin
						barre_etat(chemin)
					end
				else
					barre_etat(@strPasCheminDefintion)
				end
			else #c'est un groupe
			barre_etat(@strGroupe)
			#@element_selectionne=nil					
			end
		#On sélectionne les instances si l'option est cochée
		selectionner_instances if @option_SelectionAuto==true 
	end		
	def self.barre_etat(message)
		@w.execute_script("document.getElementById('zone_texte').value='" + bgSketchup_to_java(message.to_s) + "';") if @w!=nil
	end
	
	#Buttons actions
	def self.changer_lien
		viderListeAttribut
		if @element_selectionne!=nil then						
			definition=@liste_definitions[@element_selectionne][0]
			#On regarde le chemin actuel (par défaut le chemin relatif)
			chemin_actuel =bgSketchup_chemin_composant(definition)
			#On demande le nouveau lien
			nouveau_lien = UI.openpanel @strPanelOuvrir, "", chemin_actuel
			#Si tout es ok, on met à jour le dessin
			if nouveau_lien != nil then
				nouveau_lien=bgSketchup_to_ascii(nouveau_lien)
				if File.exists?(nouveau_lien)==true then
					nouveau_chemin = BGSketchup_creer_lien_relatif(nouveau_lien,bgSketchup_to_ascii(Sketchup.active_model.path))
					#On demande si on ne veux modifier que le lien relatif
					reponse=UI.messagebox @strModifierLienRelatif, MB_YESNO
					if reponse[0]==6 then
						#On charge la nouvelle instance
							nom=definition.name
							nouvelle_definition = Sketchup.active_model.definitions.load nouveau_lien
						#On lui définit le lien relatif et la date
							@BGSketchup_Composants_Update_in_progress=true
							nouvelle_definition.set_attribute "BGSketchup_Composants", "Chemin", nouveau_chemin
							nouvelle_definition.set_attribute "BGSketchup_Composants", "Date", bgSketchup_date_to_str(File.mtime(nouveau_lien))
						#On remplace toutes les anciennes instances par la nouvelles
							definition.instances.each { |instance|
								instance.definition=nouvelle_definition
							}
						#On purge les définitions pas utilisées
							#Sketchup.active_model.start_operation("Delete Definition")
								Sketchup.active_model.definitions.purge_unused#.entities.erase_entities(definition.entities.to_a)
							#Sketchup.active_model.commit_operation
							definition.name="tatayoyosurlechiouaoua" if !(definition.deleted?)
							nouvelle_definition.name=nom
							@BGSketchup_Composants_Update_in_progress=false
						#On enregistre la définition comme la nouvelle définition du composant
							@liste_definitions[@element_selectionne][0]=nouvelle_definition
						#On attache l'observer
							nouvelle_definition.entities.add_observer(MyEntitiesObserver.new)
					else #On ne veut pas recharger le composant, juste changer le lien
						@BGSketchup_Composants_Update_in_progress=true
							definition.set_attribute "BGSketchup_Composants", "Chemin", nouveau_chemin
							definition.set_attribute "BGSketchup_Composants", "Date", bgSketchup_date_to_str(Time.now)
						@BGSketchup_Composants_Update_in_progress=false
					end
					#On met à jour la page Html
						maj_liste
				else
					UI.messagebox @strCheminNOK
				end
			end
		end
	end
	def self.enregistrer_definition	#Enregistre la définition sélectionnée dans son fichier
		viderListeAttribut
		if @element_selectionne!=nil then						
			definition=@liste_definitions[@element_selectionne][0]
			return nil if !(definition.is_a? Sketchup::ComponentDefinition)
			
			#On regarde le chemin actuel (par défaut le chemin relatif)
			chemin=bgSketchup_chemin_composant(definition)
			chemin=bgSketchup_to_ascii(chemin)
			if chemin==nil || chemin=="" then
				chemin = UI.savepanel @strPanelEnregistrer, Sketchup.active_model.path, definition.name+".skp"
				return nil if chemin==nil
				chemin=bgSketchup_to_ascii(chemin)
				if File.exist?(chemin)==true then
					reponse = UI.messagebox @strRemplacerFichierExistant, MB_YESNO
					return nil if reponse!=6
				end
			else
				if File.exist?(chemin)==false then
					chemin = UI.savepanel @strPanelEnregistrer, Sketchup.active_model.path, definition.name+".skp"
					return nil if chemin==nil
					chemin=bgSketchup_to_ascii(chemin)
					if File.exist?(chemin)==true then
						reponse = UI.messagebox @strRemplacerFichierExistant, MB_YESNO
						return nil if reponse!=6
					end
				end
			end
			#On enregistre
			if chemin!=nil
				if @option_UtiliserIndice then
					reponse=UI.messagebox @strEnregistrerNouvelIndice, MB_YESNO
					if reponse==6 then
						chemin=fichier_dernier_indice(chemin, @option_TexteIndice, true)
					end
				end
				resultat=definition.save_as chemin
				if resultat==false then
					UI.messagebox @strErreurEnregistrement+" (" + chemin_actuel + ")."
				else
					@BGSketchup_Composants_Update_in_progress="oui"
					definition.set_attribute "BGSketchup_Composants", "Chemin", BGSketchup_creer_lien_relatif(chemin,Sketchup.active_model.path)
					definition.set_attribute "BGSketchup_Composants", "Date", bgSketchup_date_to_str(File.mtime(chemin))
					@BGSketchup_Composants_Update_in_progress="non"						
					UI.messagebox @strEnregistrementOK
					#On met à jour la liste
					maj_liste
				end
			end
		end
	end		
	def self.recharger_definition #Recharge depuis un fichier la définition
		
		viderListeAttribut
		# ATTENTION : est-ce que l'utilisateur veut un lien relatif ?????????????????????????????????
		
		return nil if @element_selectionne==nil
		definition=@liste_definitions[@element_selectionne][0]
		
		if !(definition.is_a? Sketchup::Group) then				#Si c'est pas un composant
			resultat=charge(definition, true, @element_selectionne)
			maj_liste if resultat!=nil 	#On met à jour la liste
		end
	end		
	def self.enregistrer_definitions
		viderListeAttribut
		return nil if (6!=(UI.messagebox @strEnregistrerDefinitions, MB_YESNO))
		passer_si_chemin_inexistant=((UI.messagebox @strPasserSiInexistant, MB_YESNO)==6)
		
		#On enregistre les définitions une par une
		compteur=0;compteur_ok=0
		@liste_definitions.each { |d|
			definition=d[0]
			if !(definition.is_a? Sketchup::Group) then # Pas d'enregistrement si c'est un groupe
				compteur+=1
				#On regarde le chemin actuel (par défaut le chemin relatif)
				chemin=bgSketchup_chemin_composant(definition)
				chemin=bgSketchup_to_ascii(chemin)
				#On enregistre
				if chemin==nil then #Le chemin n'existe pas
					if !(passer_si_chemin_inexistant) then
						chemin = UI.savepanel definition.name.to_s+" : " +@strPanelEnregistrer, Sketchup.active_model.path, definition.name.to_s+".skp"
						if chemin!=nil then
							chemin=bgSketchup_to_ascii(chemin)
							if File.exist?(chemin)==true then
								reponse = UI.messagebox @strRemplacerFichierExistant, MB_YESNO
								chemin=nil if reponse!=6
							end
						end
					end
				end
				
				if chemin!=nil then
					if File.exists?(chemin) then
						if @option_UtiliserIndice then
							chemin=fichier_dernier_indice(chemin, @option_TexteIndice, true)
						end
						resultat=definition.save_as chemin
						if resultat==false then
							UI.messagebox @strErreurEnregistrementDefinition + definition.name.to_s + strErreurEnregistrementDefinition2 + chemin_actuel + ")."
						else
							compteur_ok+=1
							@BGSketchup_Composants_Update_in_progress="oui"
							definition.set_attribute "BGSketchup_Composants", "Chemin", BGSketchup_creer_lien_relatif(chemin,bgSketchup_to_ascii(Sketchup.active_model.path))
							definition.set_attribute "BGSketchup_Composants", "Date", bgSketchup_date_to_str(File.mtime(chemin))
							@BGSketchup_Composants_Update_in_progress="non"
						end
						else
					end
				end
			else #c'est un groupe
			end
		}
		#On met à jour la liste
		maj_liste
		UI.messagebox @strNbEnregistementDefinitions+" ("+compteur_ok.to_s+"/"+compteur.to_s+")"
	end		
	def self.recharger_definitions
		
		viderListeAttribut
		return nil if (6!=(UI.messagebox @strMAJDefinitions, MB_YESNO))
		@liste_definitions_rechargees=[]
		for ent in Sketchup.active_model.entities
			upload(ent)
		end
		#On met à jour la liste
		maj_liste
	end
	def self.upload (entity)	#Recharge (récursif) les composants de entity
		#On recharge si c'est une instance
		if (entity.is_a? Sketchup::ComponentInstance) then
			entity=entity.definition
			nom=entity.name
			entity=charge(entity) if @liste_definitions_rechargees.index(nom)==nil #On recharge uniquement si c'est pas déjà fait.
			@liste_definitions_rechargees.push nom
			return nil if entity.deleted? 
		end
		
		#On regarde en dessous de l'instance chargée (ou pas)
		if (entity.is_a? Sketchup::Group) || (entity.is_a? Sketchup::ComponentDefinition) then
			for ent in entity.entities
				if (ent.is_a? Sketchup::Group) || (ent.is_a? Sketchup::ComponentInstance) then #Un group ou un composant ?
					upload(ent) #On scanne en dessous => récursif
				end
			end
		end
	end
	def self.charge (definition, message=false, element=nil) #Recharge la définition et remplace les instances et ajoute les observers
		nouvelle_definition=definition
		#On regarde le chemin actuel (par défaut le chemin relatif)
		nouveau_chemin=bgSketchup_chemin_composant(definition)
		nouveau_chemin=bgSketchup_to_ascii(nouveau_chemin)
		nouveau_chemin=fichier_dernier_indice(nouveau_chemin,@option_TexteIndice) if @option_UtiliserIndice==true #check for new level
		#On vérifie que le fichier atteignable
		if nouveau_chemin!=nil then
			if File.exist?(nouveau_chemin)!=false then 
				#Si le fichier est le même, alors pas de mise à jour nécessaire
					date_fichier=bgSketchup_date_to_str(File.mtime(nouveau_chemin))
					date_definition =definition.get_attribute "BGSketchup_Composants", "Date"
					if date_fichier!=date_definition then #il y a une différence
						#On charge la nouvelle instance
							nom=definition.name
							nouvelle_definition = Sketchup.active_model.definitions.load nouveau_chemin
						#On lui définit le lien relatif
							chemin_relatif = BGSketchup_creer_lien_relatif(nouveau_chemin,bgSketchup_to_ascii(Sketchup.active_model.path))
							@BGSketchup_Composants_Update_in_progress="oui"
							nouvelle_definition.set_attribute "BGSketchup_Composants", "Chemin", chemin_relatif
							nouvelle_definition.set_attribute "BGSketchup_Composants", "Date", bgSketchup_date_to_str(File.mtime(nouveau_chemin))
						#On remplace toutes les anciennes instances par la nouvelles
							definition.instances.each { |instance|
								instance.definition=nouvelle_definition
							}
						#On purge les définitions pas utilisées
							#Sketchup.active_model.definitions.purge_unused
							#Sketchup.active_model.start_operation("Delete Definition")
								Sketchup.active_model.definitions.purge_unused#definition.entities.erase_entities(definition.entities.to_a)
							#Sketchup.active_model.commit_operation
							definition.name="tatayoyosurlechiouaoua" if !(definition.deleted?)
							nouvelle_definition.name=nom
							@BGSketchup_Composants_Update_in_progress="non"
						#On enregistre la définition comme la nouvelle définition du composant
							@liste_definitions[element][0]=nouvelle_definition if element!=nil
						#On attache l'observer
							nouvelle_definition.entities.add_observer(MyEntitiesObserver.new)
					else
						return definition #Le fichier correspondait à la définition : pas de mise à jour, on retourne la définition actuelle
					end
			else	# Si le fichier n'est pas atteignable, la nouvelle définition ne sera pas chargée
				UI.messagebox @strFichierPasAtteignable +10.chr+13.chr+nouveau_chemin.to_s if message==true
				return nil if element!=nil
			end
		else #Le chemin n'est pas défini
			UI.messagebox @strFichierPasAtteignable +10.chr+13.chr+nouveau_chemin.to_s if message==true
			return nil if element!=nil
		end
		return nouvelle_definition
	end
	def self.apropos
		whelp = UI::WebDialog.new(@strAbout, false,"BGSketchup_Composants_About" , 316, 293, 100, 200, false)
		whelph=File.join(DIR, "Composants", "Html", "About.html")
		whelp.set_file(whelph)
		whelp.set_background_color("ffffff")
		whelp.set_size(400,300)
		whelp.show_modal { whelp.execute_script("document.getElementById('version').innerHTML='"+BGSketchup_Composants_extension.version+"';")}
	end
	def self.filters_window
		if @option_AfficherAbre then
			UI.messagebox @strTreeListOptionToBeSelected
			return nil
		end
		@wFiltres = UI::WebDialog.new(@strFilters, false,"BGSketchup_Composants_Filtres" , 316, 293, 100, 200, true)
		wFiltresh=File.join(DIR, "Composants", "Html", "Filters.html")
		@wFiltres.set_file(wFiltresh)
		@wFiltres.set_background_color("ffffff")
		@wFiltres.set_size(500,260)
		
		@wFiltres.add_action_callback("get_data") do |web_dialog,action_name|
			if action_name[0..15]=="AppliquerFiltres" then
				#On récupère les options
				param=action_name[17..action_name.length-2]
				@filtres=[]
				for i in 0..param.length-1
					o=(param[i].chr=="1") ? true : false
					@filtres.push o
				end
				@wFiltres.close
				maj_liste
			end
			@wFiltres.close if action_name=="Annuler"
		end			
		
		#Affiche la fenêtre en mettant les filtres actuels
		@wFiltres.show_modal {
			js=""
			for i in 0..@filtres.length-1
				js+="document.getElementById('"+i.to_s+"').checked="
				js+="true;" if @filtres[i]==true
				js+="false;" if @filtres[i]==false
				js+="document.getElementById('title_"+i.to_s+"').innerHTML='"+@strFilterTitles[i]+"';"
			end
			js+="document.getElementById('title').innerHTML='"+@strFilterSelectAll+"';"
			js+="document.getElementById('buttonApply').innerHTML='"+@buttonApply+"';"
			js+="document.getElementById('buttonCancel').innerHTML='"+@buttonCancel+"';"
			@wFiltres.execute_script(js)
		}
		
	end
	def self.date_for_all
		viderListeAttribut
		reponse=UI.inputbox [@strChangePathsToRelative,@strChangeDateToNow],[@strOui,@strOui],[@strOui+"|"+@strNon,@strOui+"|"+@strNon],@strDateForAll
		return nil if reponse==false || reponse==nil
		#On scanne toutes les définitions et on définit le lien relatif et la date
		Sketchup.active_model.definitions.each {|definition|
			chemin=bgSketchup_chemin_composant(definition)
			chemin=bgSketchup_to_ascii(chemin)
			@BGSketchup_Composants_Update_in_progress="oui"
				if File.exists?(chemin) then
					definition.set_attribute "BGSketchup_Composants", "Chemin", BGSketchup_creer_lien_relatif(chemin,bgSketchup_to_ascii(Sketchup.active_model.path)) if reponse[0]==@strOui
					definition.set_attribute "BGSketchup_Composants", "Date", bgSketchup_date_to_str(Time.now) if reponse[1]==@strOui
				else
					definition.set_attribute "BGSketchup_Composants", "Chemin", definition.path if reponse[0]==@strOui
					definition.set_attribute "BGSketchup_Composants", "Date", bgSketchup_date_to_str(Time.now) if reponse[1]==@strOui
				end
			@BGSketchup_Composants_Update_in_progress="non"
			maj_liste
		}
	end
	#Selection
	def self.selectionner_instances 			#retrouve le composant, sélectionné dans la liste, dans le modele
		return nil if @element_selectionne==nil
		return nil if @BGSketchup_Composants_Selection_en_cours
		@BGSketchup_Composants_Selection_en_cours=true
		definition=@liste_definitions[@element_selectionne][0]
		model = Sketchup.active_model
		selection = model.selection
		selection.clear
		if (definition.is_a? Sketchup::ComponentDefinition) then
			selection.add definition.instances
		else #Group
			entity=@liste_definitions[@element_selectionne][0]
			selection.add entity
		end
		@BGSketchup_Composants_Selection_en_cours=false
	end
	def self.choisir_element_liste(entity)		#retrouve un entity, selectionné dans le modèle, dans la liste
		return nil if @option_SelectionAutoModel!=true || (@BGSketchup_Composants_Selection_en_cours) || entity==nil#|| !(entity.is_a? Sketchup::ComponentInstance)
		@BGSketchup_Composants_Selection_en_cours=true
		#On efface le fond
			js='efface_fond();'
		
		#On retrouve l'entity dans @liste_definitions
			i=retrouve_entite(entity)
			if i==nil then
				@BGSketchup_Composants_Selection_en_cours=false
				return nil
			end
			if @option_AfficherAbre then
				js+='showBranch("'+i.to_s+'");'
				#On déplie les branches au dessus
				parents=retrouve_id_parents(i) #On a un tableau avec les id
				if parents!=nil
					for p in parents
						js+='showBranch("'+p.to_s+'");'
					end
				end
			end
			
		# On sélectionne l'instance			
			js+= 'document.getElementById("'+i.to_s+'").style.backgroundColor="#CCCCFF";'
			js+= 'found_element("'+i.to_s+'");'
		
		# On exécute le tout
			@w.execute_script(js) if @w!=nil
			
			afficher_info(i)
		@BGSketchup_Composants_Selection_en_cours=false
	end
	def self.retrouve_entite(entity)			#retrouve entity dans @liste_definitions
		return nil if (entity.is_a? Sketchup::Model) || entity==nil
		trouve=false
		for i in 0..@liste_definitions.length-1
			d=@liste_definitions[i]
			if d[2]!=nil && d[2]!=[]
				index=d[2].index(entity.entityID)
				return i if index!=nil  #On a la bonne definition
			end
		end
		return nil
	end		
	def self.retrouve_id_parents(i)				#retrouve les parents de l'item i dans @liste_definitions
		return nil if i==nil
		parents=[]
		i=retrouve_entite(@liste_definitions[i][1])
		while (i!=nil)
			oldi=i
			parents.push i
			i=retrouve_entite(@liste_definitions[i][1])
			if oldi==i then
				puts "erreur"
				return nil
			end
		end
		return parents
	end

	#Gestion des dates
	def self.date_from_str(str)
		return Time.local(str[0..3],str[4..5],str[6..7],str[9..10],str[11..12],str[13..14])
	end

	#Options
	def self.options
		#On coche les options
			cb=[]
			cb.push (@option_DemarrageAuto==true) ? "true" : "false"
			cb.push (@option_ActiverAuDemarrage==true) ? "true" : "false"
			cb.push (@option_AfficherAbre==true) ? "true" : "false"
			cb.push (@option_DemarrageAutoMAJListe==true) ? "true" : "false"
			cb.push (@option_verifier_existance_fichier==true) ? "true" : "false"
			cb.push (@option_RecentRougeVif==true) ? "true" : "false"
			cb.push (@option_SelectionAuto==true) ? "true" : "false"
			cb.push (@option_SelectionAutoModel==true) ? "true" : "false"
			cb.push (@option_UtiliserIndice==true) ? "true" : "false"
			cb.push (@option_EnregistrerPositionFenetre==true) ? "true" : "false"
			cb.push (@option_afficher_groupes==true) ? "true" : "false"
			
			js=""
			for i in 0..cb.length-1
				js+= "document.getElementById('cb"+i.to_s+"').checked="+cb[i].to_s+";"
			end
			
			js+= "document.getElementById('i0').value='"+@option_temps_rappel_maj.to_s+"';"
			js+= "document.getElementById('i1').value='"+@option_TexteIndice.to_s+"';"
			js+= "liste=document.getElementById('s0');"
			js+= "liste.length=0;"
			for i in 0..@availableLanguages.length-1
				js+= "liste.options[liste.length] = new Option('"+@availableLanguagesName[i].to_s+"', '"+@availableLanguages[i].to_s+"'); "
			end
			
			js+= "liste.value='"+@option_langue.to_s+"';"
			
			
		#On affiche la div
			js+="show_options();"
			@w.execute_script(js)
	end
	def self.save_options_html
		js="etatOptions();"
		@w.execute_script(js)
	end
	def self.appliquerOptions(options)
		old=@option_langue
		@option_DemarrageAuto=(options[0].chr=='1') ? true : false
		@option_ActiverAuDemarrage=(options[1].chr=='1') ? true : false
		@option_AfficherAbre=(options[2].chr=='1') ? true : false
		@option_DemarrageAutoMAJListe=(options[3].chr=='1') ? true : false
		@option_verifier_existance_fichier=(options[4].chr=='1') ? true : false
		@option_RecentRougeVif=(options[5].chr=='1') ? true : false
		@option_SelectionAuto=(options[6].chr=='1') ? true : false
		@option_SelectionAutoModel=(options[7].chr=='1') ? true : false
		@option_UtiliserIndice=(options[8].chr=='1') ? true : false
		@option_EnregistrerPositionFenetre=(options[9].chr=='1') ? true : false
		@option_afficher_groupes=(options[10].chr=='1') ? true : false
		
		o=options[12..options.length-1].split(",")
		@option_temps_rappel_maj=o[0]
		@option_TexteIndice=o[1]
		@option_langue=o[2]
		
		save_options
		
		js="hide_options();"
		@w.execute_script(js)
		
		if @option_langue!=old then	#Si on change de langue, alors on redémarre l'interface
			@w.close
			self.demarrer
		else 						#Sinon, on met à jour la liste
			maj_liste
		end

	end
	def self.load_default_options	#Default options
		@option_verifier_existance_fichier=true
		@option_afficher_groupes= false 
		@option_langue=Sketchup.os_language
		@option_SelectionAuto=true
		@option_SelectionAutoModel=true
		@option_UtiliserIndice=false
		@option_TexteIndice=" ind"
		@option_RecentRougeVif=true
		@option_DemarrageAuto = false
		@option_DemarrageAutoMAJListe=true
		@option_temps_rappel_maj=60
		@option_ActiverAuDemarrage=true
		@option_AfficherAbre=true
		@option_EnregistrerPositionFenetre=true
		@option_PosFenH=302
		@option_PosFenL=326-20
	end
	def self.load_options
		#Load default option in case one option is missing
		load_default_options
		file_name=File.join(bgSketchup_getTempFolder,"BGSketchup_Composants.ini")
		if File.exists?(file_name)==true then 	#File exist
			file = File.open(file_name, "r")
			while !file.eof?
				option_name=file.readline.gsub(10.chr,"").gsub(13.chr,"")
				option_value=file.readline.gsub(10.chr,"").gsub(13.chr,"")
				@option_verifier_existance_fichier=(option_value=="true") ? true : false if option_name=="option_verifier_existance_fichier"
				@option_afficher_groupes=(option_value=="true") ? true : false if option_name=="option_afficher_groupes"
				@option_langue=option_value if option_name=="option_langue"
				@option_SelectionAuto=(option_value=="true") ? true : false if option_name=="option_SelectionAuto"
				@option_SelectionAutoModel=(option_value=="true") ? true : false if option_name=="option_SelectionAutoModel"
				@option_RecentRougeVif=(option_value=="true") ? true : false if option_name=="option_RecentRougeVif"
				@option_UtiliserIndice=(option_value=="true") ? true : false if option_name=="option_UtiliserIndice"
				@option_TexteIndice=option_value if option_name=="option_TexteIndice"
				@option_DemarrageAuto=(option_value=="true") ? true : false if option_name=="option_DemarrageAuto"
				@option_DemarrageAutoMAJListe=(option_value=="true") ? true : false if option_name=="option_DemarrageAutoMAJListe"
				@option_temps_rappel_maj=option_value.to_i if option_name=="option_temps_rappel_maj"
				@option_ActiverAuDemarrage=(option_value=="true") ? true : false if option_name=="option_ActiverAuDemarrage"
				@option_AfficherAbre=(option_value=="true") ? true : false if option_name=="option_AfficherAbre"
				@option_EnregistrerPositionFenetre=(option_value=="true") ? true : false if option_name=="option_EnregistrerPositionFenetre"
				@option_PosFenH=(option_value.to_i) if option_name=="option_PosFenH"
				@option_PosFenL=(option_value.to_i) if option_name=="option_PosFenL"					
			end
			file.close
		else												#File doesn't exist
			#Save Default options
			save_options
		end
	end
	def self.save_options
		file_name=File.join(bgSketchup_getTempFolder,"BGSketchup_Composants.ini")
		File.delete(file_name) if File.exists?(file_name)
		file=File.new(file_name, "w")
		file.puts("option_verifier_existance_fichier") 
		file.puts(@option_verifier_existance_fichier)
		file.puts("option_afficher_groupes") 
		file.puts(@option_afficher_groupes)
		file.puts("option_langue") 
		file.puts(@option_langue)
		file.puts("option_SelectionAuto") 
		file.puts(@option_SelectionAuto)
		file.puts("option_RecentRougeVif") 
		file.puts(@option_RecentRougeVif)
		file.puts("option_UtiliserIndice") 
		file.puts(@option_UtiliserIndice)
		file.puts("option_TexteIndice") 
		file.puts(@option_TexteIndice)
		file.puts("option_DemarrageAuto") 
		file.puts(@option_DemarrageAuto)
		file.puts("option_DemarrageAutoMAJListe") 
		file.puts(@option_DemarrageAutoMAJListe)
		file.puts("option_temps_rappel_maj") 
		file.puts(@option_temps_rappel_maj)
		file.puts("option_SelectionAutoModel") 
		file.puts(@option_SelectionAutoModel)
		file.puts("option_ActiverAuDemarrage") 
		file.puts(@option_ActiverAuDemarrage)
		file.puts("option_AfficherAbre") 
		file.puts(@option_AfficherAbre)
		file.puts("option_EnregistrerPositionFenetre") 
		file.puts(@option_EnregistrerPositionFenetre)
		file.puts("option_PosFenH") 
		file.puts(@option_PosFenH)
		file.puts("option_PosFenL") 
		file.puts(@option_PosFenL)
		file.close
	end

	#Creation des menus
	def self.creations_menus
		menu=BGSketchup_Ajouter_Submenu("BGSketchup")
		menu.add_item(@strMenuGestionnaireComposants) {self.initialize_window }
		#Ajout de la barre d'outil
		toolbar = UI::Toolbar.new "BGSketchup-Composants"
		cmd = UI::Command.new(@strWindowName) { self.initialize_window }
		cmd.small_icon = cmd.large_icon = "../Html/Images/puzzle.png" 
		cmd.tooltip = @strWindowName
		cmd.status_bar_text = @strWindowName
		toolbar.add_item cmd 
	end
	def self.charger_titres
		js=""
		for i in 0..@strButtonsTitles.length-1
			js+= "document.getElementById('Btn"+i.to_s+"').title='"+bgSketchup_to_java(@strButtonsTitles[i])+"';"+13.chr
			js+= "document.getElementById('CMT"+i.to_s+"').innerHTML='"+bgSketchup_to_java(@strContextMenuTitles[i])+"';"+13.chr if i<@strContextMenuTitles.length
		end
		js+= "document.getElementById('RefreshListMessage').innerHTML='"+@strRefreshListMessage+"';"+13.chr
		for i in 0..@strOptionsList.length-1
			js+='document.getElementById("txt'+i.to_s+'").innerHTML="'+bgSketchup_to_java(@strOptionsList[i])+'";'+13.chr
		end
		for i in 0..@strOptionsTitles.length-1
			js+='document.getElementById("t'+i.to_s+'").innerHTML="'+bgSketchup_to_java(@strOptionsTitles[i])+'";'+13.chr
		end
		@w.execute_script(js)
	end

	#Gestion des indices et chemin
	def self.fichier_dernier_indice(fichier, indice, indice_suivant=false)
		return nil if fichier==nil 
		#On retrouve le repertoire et le nom du fichier
			rep=File.dirname(fichier)
			nom=File.basename(fichier)
			ext=File.extname(fichier)
			base=File.basename(fichier, ".*" )
			
			if base.rindex(indice)!=nil then
				base=base[0..base.rindex(indice)-1]
			end
		#On liste les fichiers du répertoire ayant la même base de nom
			fichiers_ok=[]
			return fichier if File.directory?(rep)==false
			Dir.foreach(rep) { |f|
				b=File.basename(f)
				if (b[0..base.length+indice.length-1]==(base+indice)) then
					n_sans_ext=File.basename(b, ".*" )
					partie_apres_indice=b[(base+indice).length..n_sans_ext.length-1]
					partie_apres_indice=partie_apres_indice.strip! || partie_apres_indice	#On efface les espace en début et fin de chaine
					if partie_apres_indice.index(" ")!=nil then	#On prend le texte jusqu'au premier espace
						partie_apres_indice=partie_apres_indice[0..partie_apres_indice.index(" ")]
					end
					ind=b[(base+indice).length..n_sans_ext.length-1].to_i
					fichiers_ok.push [f,ind]
				end
			}
		#On retrouve le dernier indice
			if fichiers_ok!=[] then
				#On trouve l'indice le plus grand
				max=fichiers_ok[0][1]
				maxi=0
				for i in 0..fichiers_ok.length-1
					if (fichiers_ok[i][1]>max) then
						max=fichiers_ok[i][1]
						maxi=i
					end
				end
				#On retourne le fichier correspondant
				return File.join(rep,fichiers_ok[i][0]) if indice_suivant==false
				return File.join(rep,base+indice+(max+1).to_s+".skp") if indice_suivant==true
			else#On n'a pas de fichier avec indice, on l'ajoute
				return File.join(rep,base+indice+"1"+".skp")
			end
	end
	
	#Gestion des observers
	def self.attacher_observers(demarrage=false)
		if (@option_ActiverAuDemarrage==true && demarrage==true) || (demarrage==false) then
			# Attach the observer to all components
				@obsEntities=BGSketchup_Composants::MyEntitiesObserver.new
				for d in Sketchup.active_model.definitions
					d.entities.add_observer(@obsEntities)
				end
				Sketchup.active_model.entities.add_observer @obsEntities
			
			# Attach observer to Sketchup and model
				@obsApp=BGSketchup_Composants::MyAppObserver.new
				@obsModel=BGSketchup_Composants::MyModelObserver.new
				@obsSelection=BGSketchup_Composants::MySelectionObserver.new
				Sketchup.add_observer(@obsApp)
				Sketchup.active_model.add_observer(@obsModel)
				Sketchup.active_model.selection.add_observer(@obsSelection)
		end
	end
	def self.detacher_observers
		if @obsEntities!=nil then
			# Attach the observer to all components
				for d in Sketchup.active_model.definitions
					d.entities.remove_observer(@obsEntities)
				end
				Sketchup.active_model.entities.remove_observer @obsEntities
			
			# Attach observer to Sketchup and model
				Sketchup.remove_observer(@obsApp)
				Sketchup.active_model.remove_observer(@obsModel)
				Sketchup.active_model.selection.remove_observer(@obsSelection)
		end
	end

	#Gestion des attributs
	def self.changeDateComponent(entity,date)
		#entity.set_attribute "BGSketchup_Composants", "Date", bgSketchup_date_to_str(Time.now)
		@composantsAMAJ.push [entity,date]
	end
	def self.viderListeAttribut
		Sketchup.active_model.start_operation("BGSketchup",false,false,true)
			@composantsAMAJ.each { |couple|
				couple[0].set_attribute "BGSketchup_Composants", "Date", couple[1]
			}
			@composantsAMAJ=[]
		Sketchup.active_model.commit_operation
	end
	def self.purgerListeAttribut
		@composantsAMAJ=[]
	end
	
	# Fonctions de modification des attributs
	def self.bgSketchup_set_modification_date(entity,obs=nil,ent=nil)
		@BGSketchup_liste_entite_a_change_date.push entity if @BGSketchup_liste_entite_a_change_date.index(entity)==nil
		if !(@BGSketchup_dates_a_changer)
			UI.start_timer(0.1,false) { bgSketchup_maj_les_dates }
		end
		@BGSketchup_dates_a_changer=true
	end
	def self.bgSketchup_maj_les_dates
		@BGSketchup_liste_entite_a_change_date.each {|entity|
			if entity!=nil then
				if entity.respond_to?(:deleted? ) then
					if !(entity.deleted?)
						if @BGSketchup_Composants_Update_in_progress!="oui" then
							bgSketchup_changer_date_entite(entity)
						end
					end
				else
					if @BGSketchup_Composants_Update_in_progress!="oui" then
						bgSketchup_changer_date_entite(entity)
					end
				end
			end
		}
		@BGSketchup_dates_a_changer=false
		@BGSketchup_liste_entite_a_change_date=[]
	end
	def self.bgSketchup_changer_date_entite (entity)
		@BGSketchup_Composants_Update_in_progress="oui"
		Sketchup.active_model.start_operation("BGSketchup",false,false,true)
			#entity.set_attribute "BGSketchup_Composants", "Date", bgSketchup_date_to_str(Time.now)
			BGSketchup_Composants::changeDateComponent(entity,bgSketchup_date_to_str(Time.now))
		Sketchup.active_model.commit_operation
		@BGSketchup_Composants_Update_in_progress="non"
	end
		
	#Add observers to Sketchup to detect when components changed
    class MyEntitiesObserver < Sketchup::EntitiesObserver
		def onElementAdded(entities, entity)
			parent=bgSketchup_find_parent_component(entity)
			return nil if parent==nil && !(entity.is_a? Sketchup::ComponentInstance)
			if ((entity.is_a? Sketchup::ComponentDefinition)  || (entity.is_a? Sketchup::ComponentInstance) || (entity.is_a? Sketchup::Group)) then
				entity=entity.definition if (entity.is_a? Sketchup::ComponentInstance)
				entity.entities.add_observer BGSketchup_Composants::MyEntitiesObserver.new
			else
				entity.add_observer BGSketchup_Composants::MyEntitiesObserver.new
			end
			#puts "onElementAdded "+parent.to_s if @BGSketchup_Composants_Update_in_progress!="oui"
			BGSketchup_Composants::bgSketchup_set_modification_date(parent,"onElementAdded")
		end
	    def onElementModified(entities, entity)
			#return nil if entity.typename=="AttributeNamed" || entity.typename=="Thumbnail" || entity.typename=="AttributeContainer"
			parent=bgSketchup_find_parent_component(entity)
			return nil if parent==nil
			#puts "onElementModified "+parent.to_s+","+entity.to_s if @BGSketchup_Composants_Update_in_progress!="oui"
			BGSketchup_Composants::bgSketchup_set_modification_date(parent,"onElementModified")
		end
		def onElementRemoved(entities, entity_id)
			return nil if entities.is_a? Sketchup::Model
			parent=bgSketchup_find_parent_component(entities)
			return nil if parent==nil		
			#puts "onElementRemoved "+parent.to_s if @BGSketchup_Composants_Update_in_progress!="oui"
			BGSketchup_Composants::bgSketchup_set_modification_date(parent,"onElementRemoved")
		end
		def onEraseEntities(entities)
			return nil if entities.is_a? Sketchup::Model
			parent=bgSketchup_find_parent_component(entities)
			return nil if parent==nil	
			#puts "onEraseEntities "+parent.to_s if @BGSketchup_Composants_Update_in_progress!="oui"
			BGSketchup_Composants::bgSketchup_set_modification_date(parent,"onEraseEntities") if (entities.parent.is_a? Sketchup::ComponentDefinition)
		end
		def bgSketchup_find_parent_component(entity) #retrouve le composant parent de "entity", s'il existe (récursif)
			return nil if (entity.is_a? Sketchup::Model)
			if entity.respond_to?(:deleted? ) then
				return nil if (entity.deleted?)
			end
			return nil if (entity.parent.is_a? Sketchup::Model) && !(entity.is_a? Sketchup::ComponentInstance)
			return entity.parent.definition if (entity.parent.is_a? Sketchup::ComponentInstance) 
			return entity.parent if (entity.parent.is_a? Sketchup::ComponentDefinition)
			return bgSketchup_find_parent_component(entity.parent)
		end
		
    end
	class MyAppObserver < Sketchup::AppObserver
		def onNewModel(model)
			# Clear attribute list
				BGSketchup_Composants::purgerListeAttribut #Liste des composants à mettre à jour
				
			# Attach the observer to all components
				for d in Sketchup.active_model.definitions; d.entities.add_observer(BGSketchup_Composants::MyEntitiesObserver.new); end
				Sketchup.active_model.entities.add_observer BGSketchup_Composants::MyEntitiesObserver.new
				
			# Attch observer to Sketchup and model
				Sketchup.add_observer(BGSketchup_Composants::MyAppObserver.new)
				Sketchup.active_model.add_observer(BGSketchup_Composants::MyModelObserver.new)
				Sketchup.active_model.selection.add_observer(BGSketchup_Composants::MySelectionObserver.new)
				
			# Update the list
				BGSketchup_Composants::maj_liste
		end
		def onOpenModel(model)
			# Clear attribute list
				BGSketchup_Composants::purgerListeAttribut #Liste des composants à mettre à jour
			
			# Attach the observer to all components
				for d in Sketchup.active_model.definitions; d.entities.add_observer(BGSketchup_Composants::MyEntitiesObserver.new); end
				Sketchup.active_model.entities.add_observer BGSketchup_Composants::MyEntitiesObserver.new
				
			# Attch observer to Sketchup and model
				Sketchup.add_observer(BGSketchup_Composants::MyAppObserver.new)
				Sketchup.active_model.add_observer(BGSketchup_Composants::MyModelObserver.new)
				Sketchup.active_model.selection.add_observer(BGSketchup_Composants::MySelectionObserver.new)
				
			# Update the list
				BGSketchup_Composants::maj_liste
		end
	end
	class MyModelObserver < Sketchup::ModelObserver
		def onAfterComponentSaveAs(model)
			#Component just save as, therefore the path have changed...
			#So we save also to related link
			definition=Sketchup.active_model.selection[0].definition
			chemin=definition.path
			if File.exists?(chemin) then
				@BGSketchup_Composants_Update_in_progress="oui"
				Sketchup.active_model.start_operation("BGSketchup",false,false,true)
				definition.set_attribute "BGSketchup_Composants", "Chemin", BGSketchup_creer_lien_relatif(chemin,Sketchup.active_model.path)
				definition.set_attribute "BGSketchup_Composants", "Date", bgSketchup_date_to_str(File.mtime(chemin))
				Sketchup.active_model.commit_operation
				@BGSketchup_Composants_Update_in_progress="non"
			end
		end
		def onPreSaveModel(model)
			BGSketchup_Composants::viderListeAttribut
		end
	end
	class MySelectionObserver < Sketchup::SelectionObserver
		def onSelectionBulkChange(selection)
			entity= selection[0]
			BGSketchup_Composants::choisir_element_liste(entity)
		end
	end
	unless file_loaded?( __FILE__ )
		if File.exists?(File.join(bgSketchup_getTempFolder,"Debug.bg")) then
			res = Sketchup.send_action "showRubyPanel:"
		end
		
		# Start interface
			self.demarrer
			self.creations_menus
		
		# Attach the observer to all components
			self.attacher_observers(true)
		
	end
	file_loaded(__FILE__)
end #module
