# Some functions for BGSketchup plugins
#
# Version history :
#	24/03/2014:	Added function to find plugin folder (Thx Aerilius)
#				Change global variable by moduel variables
#	16/03/2014: Deleted .chr code in lines 44 & 66 to avoid errors in SU8
#	19/02/2014: Change some code to avoid error on SU 2013, wrap code in module to avoid errors.
#	19/01/2014: Added new function to retrieve component path with relative option : "bgSketchup_chemin_composant"
#	06/01/2014: Added function for ascii/unicode strings
# 	01/01/2014: Correct error in BGSketchup_retrouve_lien_absolu
module BGSketchup
	self::DIR = File.dirname(__FILE__)
	module Module_commun
		@@BGSketchup_menu=nil
		def BGSketchup_Ajouter_Submenu(menu)
			if @@BGSketchup_menu!=nil then
			  index=@@BGSketchup_menu.index(menu)
			  if index==nil then #on ne le trouve pas
				sm=UI.menu("Plugins").add_submenu(menu)
				@@BGSketchup_menu_nb+=1
				@@BGSketchup_menu[@@BGSketchup_menu_nb]=menu
				@@BGSketchup_menu_lien[@@BGSketchup_menu_nb]=sm
			  else  #il existe déjà
				sm=@@BGSketchup_menu_lien[@@BGSketchup_menu.index(menu)]
			  end
			  
			else #rien n'existe
			 sm= UI.menu("Plugins").add_submenu(menu)
			 @@BGSketchup_menu=[]
			 @@BGSketchup_menu_lien=[]
			 @@BGSketchup_menu_nb=1
			 @@BGSketchup_menu[@@BGSketchup_menu_nb]=menu
			 @@BGSketchup_menu_lien[@@BGSketchup_menu_nb]=sm
			end
			return sm
		end

		def BGSketchup_creer_lien_relatif( fichier_destination, fichier_origine) # retourne un lien relatif de "fichier_destination" depuis "fichier_origine"
			#Convention:
			# ../toto.skp = on remonte d'un répertoire et on a le fichier toto.skp
			# toto.skp = on est dans le même répertoire et on a le fichier toto.skp
			# test/toto.skp = on va dans le sous répertoire "test" et on a le fichier toto.skp
			# creer_lien_relatif("c:/test/toto.skp","c:/testu/tutu/tata.skp")
			#On split :
				f_o=fichier_origine.gsub("\\","/").split("/")
				f_d=fichier_destination.gsub("\\","/").split("/")
			
			#On cherche la partie commune
				if (f_o[0]!=f_d[0] || fichier_origine==nil) then #Le premier bloc n'est pas commun !! Donc rien n'est commun
					return fichier_destination
				end
				for rep in 0..f_o.length-2 #-2 car on ne prend pas en compte le nom du fichier
					if f_o[rep]!=f_d[rep] then 	#On tient une différence, donc la partie commune va jusque rep-1
						if rep==0 then 			#Le premier bloc n'est pas commun !! Donc rien n'est commun
							return fichier_destination
						else
							#A partir de la on est plus commun : de combien de répertoire faut-il monter ?
							difference = (f_o.length-1) - rep #-1
							return "../" * difference + f_d[rep..f_d.length-1].join("/")
						end
					end
				end
				#Si on est ici c'est que tout est commum : soit on est dans le même répertoire, soit c'est un sous répertoire
				return  f_d[f_o.length-1..f_d.length-1].join("/") #=> On retourne les derniers blocs
		end

		def BGSketchup_retrouve_lien_absolu(lien,fichier_origine)	# retrouve le chemin absolu de "lien" depuis depuis "fichier_origine"
			return lien if lien==nil || fichier_origine==nil
			lien=lien.gsub("\\","/")
			fichier_origine=fichier_origine.gsub("\\","/")
			if lien[1]!=":"[0] && lien[0..1]!="//" && lien[0..1]!="\\\\" then
				#On n'est pas dans un lien vers le réseau ou vers un lecteur
				if lien.index("../")!=nil then
					#On doit remonter
					f_o=fichier_origine.split("/")
					nb=lien.scan("../").size
					if nb>fichier_origine.scan("/").size-1 then
						return nil #On remonte plus que le nombre de répertoire
					end
					return f_o[0..f_o.length-2-nb].join("/") + "/" + lien[lien.rindex("../")+3..lien.length]
				else
					#On ne doit pas remonter : On est dans le même répertoire ou on a un sous répertoire
					return File.dirname(fichier_origine) << "/" << lien
				end
			else
				#On est dans un lien vers le réseau ou vers un lecteur
				return lien
			end
		end

		def bgSketchup_chemin_composant(entity,relative=false) #Retourne le chemin en relatif
			return nil if entity==nil || entity.deleted?
			
			#On regarde le chemin actuel (par défaut le chemin relatif)
			if (entity.attribute_dictionary "BGSketchup_Composants")==nil
				if entity.is_a? Sketchup::ComponentDefinition then
					return entity.path 
				else
					return nil
				end
			else
				chemin_relatif = entity.get_attribute "BGSketchup_Composants", "Chemin"
				if relative==true then
					return chemin_relatif
				else
					if chemin_relatif!=nil then
						return BGSketchup_retrouve_lien_absolu(chemin_relatif,Sketchup.active_model.path)
					else
						return entity.path
					end
				end
			end
		end

		
		
		def bgSketchup_getTempFolder
			return ENV['TEMP'] || ENV['TMPDIR']
		end

		#Conversion function (thanks to TIG)
		def bgSketchup_to_ascii(txt)
		  return txt.unpack("U*").map{|c|c.chr}.join if txt!=nil
		  return nil
		end
		def bgSketchup_to_unicode(txt)
		  return txt.unpack("C*").pack("U*") if txt!=nil
		  return nil
		end
		def bgSketchup_to_java(txt)
			return txt.to_s.gsub("\\","\\\\\\").gsub('"','\\\\"').gsub("'","\\\\'") if txt!=nil
			return nil
		end
		def bgSketchup_date_to_str(date)
			return date.strftime("%Y%m%d %H%M%S")
		end
		
	end# Module_commun
	extend Module_commun
	def self.included( other )
		other.extend( Module_commun )
	end
end