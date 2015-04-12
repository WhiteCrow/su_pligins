require 'sketchup.rb' ; require 'extensions.rb'

BGSketchup_Composants_extension = SketchupExtension.new "Component manager (BGSketchup)", "BGSketchup/Composants/Rb/Composants_Main.rb"
BGSketchup_Composants_extension.version = 'v1.14.9'
=begin
														BGSketchup Composants
 
 Object :
	Plugins to manage components in a model

 Version history :
	1.14.9:	Optimized :	Change extension name
 
	1.14.8:	Optimized :	Move JQuery folder in root BGSketchup folder, in order to reduce plugin size
			Optimized : Language names now appear fully in Options
			Optimized : Change javascript error message in more accurate details
			Optimized : Some coding correction, thanks to Aerilius
	
	1.14.7:	Corrected :	Wrap localization in module to avoid interferences
			Corrected :	When clicking on a raw object in model, the auto-selection in the list didn't worked anymore (Thanks Ole to saw this bug)
			Corrected :	Change one French translation
			Corrected :	When openning a new model, the list was not refreshing. Now it will, only if window is shown.
			Optimized :	Add Html function to catch errors in javascript (mainly for SU 2014, but also for Safari)
	
	1.14.6:	Corrected :	Try to solve Oxer issues on Mac
	
	1.14.5:	Corrected :	Error in SU8 in BGSketchup.rb file, due to .chr function.
 
	1.14.4:	Corrected : rbz archive error
	
	1.14.3: Corrected :	Remove typename used (thanks Thomthom)
			Corrected :	Change coding to respect Thomthom's rules : 
							- remove .typename
							- use of @ module variable instead of global variables
 
	1.14.2:	Optimized :	When saving a component (right-click), the name of definition is used as default filename.
	
	1.14.1:	Corrected : new option to avoid interferences with Fredo's plugins and others...
 
	1.14.0:	Added:		The tree list keep the fold/unfolded branches when updating (JQL idea)
			Added :		New button to update all components with current date and/or relative path
			Added:		Tiny animation when openning the options list (just for fun)
			Corrected :	Restore show groups options (it was removed...)
			Corrected : new option to avoid interferences with Fredo's plugins
			Optimized : Simplified list generator ('li_element' function)
			Optimized :	Simplified 'retrouve_entite' function
	
	1.13.2: Optimzed :	Reduce code of html for scrollbars in Safari (code didn't work).
	
	1.13.1:	Corrected :	Issue with sizing option
 
	1.13.0:	Added :		New option to save window size
			Added :		Show refreshing time in the window status bar
			Corrected :	Remove one unused global variable
 
	1.12.4: Corrected : Issue when using push/pull tool in a component.
			Optimized :	Simplified attribute date change in model to open only one time for each component.
 
	1.12.3:	Corrected :	Error when created a new model with window closed.
			Corrected :	Error when creating a component in model. May solve JQL push pull issue
	
	1.12.2:	Corrected :	try to solve Safari issue
	
	1.12.1:	Corrected : Bug showing options window.

	1.12.0:	Optimized : New options windows in HTML mode.
			Corrected :	Little change in code to avoid error when deleting components with merge faces (to be verified...)
			Added :		Prompt before upload all definitions
 
	1.11.3:	Optimized : The modification of components don't add lots of undo/redo action in Edit menu.
			Corrected :	Bug when changing filters
 
	1.11.2:	Corrected :	Major error while linking component to file of reloading component
			Corrected :	In non tree style, numbers of instances of components filtered still appeared
			Corrected :	A bug appear in consol when leaving the plugin due to observers still working
			Corrected :	Change context menu javascript position which may imply some Safari problems
			Optimized :	Add translation for component updating while opening new sketchup instance.			
	
	1.11.1: Corrected :	New filter for components which were not checked (option "Auto-check file paths")
			Optimized :	Improve warning message for filter window
			Optimized :	Component without modification date are shown in blue
			Optimized :	Message shown if filter make the list empty
			Optimized :	Allow more translations
 
	1.11.0:	Added :		New option to show list without a tree-style
			Added :		New button and window to filter item shown on list in case of non tree-style list
			Corrected :	Component with relative path were shown as "not updated", now shown in grey
			Corrected : Tiny bug when showing components without dates
			Corrected :	Add filter in remove observer to avoid errors
			Corrected :	When clicking on component in model, all instances were selected if option Auto-select component in model was chosen
			Optimzed :	Purge only the definitions reloaded, to avoid any trouble with other definition
	
	1.10.0:	Added :		Toolbar with icon to show the plugin window
			Added :		Help file is now in plugin sub folders, with a link from the "about" window. It was updated with last options explainations
			Optimzed :	"About" window in HTML format for better rendering and to allow links to help file and forum.
			Optimzed :	Component list shows scrollbar only is required.
			Optimzed :	On MAC, use plugin window is now always on top.
			Corrected :	Only one instance of the window can be shown.
			Corrected :	Added, some missing translations in Spanish language.
	
	1.9.8:	Corrected :	Delete all debugging messages, now works on MAC ! Thanks to Oxer !
	
	1.9.7:	Corrected :	Some javascript standard respect
	(unoff)	Added :		Show a message to update the list if the wasn't.
			Added :		Option not to start component mangement on SU start up to avoid adding attribute to model or slow down due to Observers
	
	1.9.6:	Corrected :	For localisation, in cas of error, the English language is chosen, also, english tranlsation always preload in case translation is missing
	(unoff)	Corrected :	Change function in BGSketchup.rb functions into unic name function to avoid problem with other plugins
			
	1.9.5:	Corrected :	When saving all definitions, it asks now to save also file without link.
			Optimzed :	Now, for revision management, file with letter after revision level and accepted "toto rev 3 (super").skp"
	
	1.9.4:	Corrected :	Bug on Mac according TIG help.		
			
	1.9.3:	Corrected :	When clicking on component in model, the information were not displayed.
			Corrected :	Revision system now working
			Corrected :	Bug when clicking on a group in the model (doesn't block user)
			Corrected :	Attempt to solve Mac file issue
			Added :		Spanish language, thanks to Oxer			
			
	1.9.2:	Corrected : When clicking on model to component within groups, component was not shown
			Corrected : When selecting multiple item in the list make all the list outlined
			Optimized : Click on a group in the model then group is also outlined in list.
			Optimized :	Reduce Javascript code in HTML page
			Added :		Link to forum page in about screen
	
	1.9.1:	Corrected :	Bug in options for "auto-select in list", 
			Corrected :	The component selected on model is now clearly shown in the list
			Corrected :	Observers error onElementAdded, thanks to JQL
			Corrected :	If you don't want to check file existance, when clicking on a item in the list, the file was checked. Not anymore !
			Corrected :	Options file was kept opened after reading option, this produced troubles when saving new options. Now solved.
			Optimized : Ruby consol only shown on my computer, as I forget sometime to hide it when I release verions ;o)
			
	1.9.0:	Added :		Right-click menu to do different actions
			Added :		Rename function in the right-click menu
			Added :		Adding function to open new SU instance to modify a component + message when coming back to previous SU instance
			Added :		Auto-select in the list selected component in the model
			Added :		Now it asks to create a new revision level when saving definition (and option is activated).
			Corrected :	Bug when upload a component with a revision level
			Corrected :	Bug with bright and dark red icon color
			Corrected :	Some translation were missing

	1.8.3:	Corrected : Implement string conversion to Java when upload text titles in Html page

	1.8.2:	Non official version...deleted
			
	1.8.1:	Corrected :	Add option for MAC user, should help to start the plugin, pay attention when saving files.
			Optimized : Simplify access to tool through Plugins menu
	
	1.8.0:	Added :		Revision level management option added !
			Added :		Option to start or not automatically the manager (default=no)
			Added :		Option to refresh or not the list when start automatically the manager (default=yes)
			Optimized :	The return of the update progress in Sketchup state bar !
			Optimized :	In all definitions reload, component definition are reloaded, from file, only if different from model definition.
			Optimized :	Simplify refreshing date display script
			
	1.7.0:	Added :		New red color to distinguish file newer than definition with file older than definition
			Added : 	New option to choose if the brightest red color means file newer or older than definition
			Added :		Add refresh time in window bottom when updating the list
			Corrected :	Number of component instances in a branch was wrong
			Corrected :	Restore highlightning of selected item (come back to previous script...)
			Corrected :	Number of instance in same style that item to avoid double item selection error
			Corrected : Avoid to have unlinked components text in the same color than previous list item (CSS)
			Corrected : Options were still saved in model (even if not used)
			
	1.6.0:	Added :		Window can be resize
			Corrected :	Avoid graphic issue when selecting different line in the list
			Optimized :	Simplify CSS file (removed un-used data)
			Optimized : Buttons are now centered in window

	1.5.0:	Added:		Number of instances are written in italic blue to make it different from definition name	
			Corrected : Bug when component or path have a special characters inside
			Corrected :	Move Win32API in BGSketchup folder not to interfer with other plugins
			Corrected :	Simplify reload definition script, avoid error when Group is selected
			Corrected : add to_java function to format string to reach javascript standard
			

	1.4.1:	Corrected :	Add Win32API.so in package to make it works ok

	1.4.0:	Added :		Options are now saved in My Documents folder
			Added : 	Option to select automatically the instances in the model (yes by default)
			Added : 	Number of instances of components
			Added : 	Plugin version in title for more traceability
			Added : 	Update list when openning a exiwting file or creating new file
			Removed : 	Progress in Sketchup state bar (I will try in implement again later)
			Removed : 	Old code for sub-menu options
			Corrected : Error in observers for new model and open model
			Corrected : Component in root of the model where duplicated in the list : not anymore

	1.3.2:	Corrected : bug when uploading all definition due to SU2013 error when calling for Component instance entities (check other procedure : ok)
			Corrected : bug when clicking on a element in the list : it was refering to the wrong entities

	1.3.1:	Corrected : buttons titles are now in same language as the user preference
			Corrected : avoid error when adding something different than a component in the model
			Corrected : avoid accessing to "ComponentInstance entities" but look for its "definition" entities			

	1.3:	Added : Language change in Option
			Corrected : Removed call to "initialise_les_observers" which doesn't works.

	1.2:	Added : New option to show or not groups without sub-components
			Added : Update progress shown in status bar
			Added : Options are saved in model
			Optimized : Delete the global variable for reverse list of definition (not used anymore)
			Optimized : Update automatically the list when changing options
			Corrected : Add EN translation for "Group without name" in liste
			Corrected : When component include groups that mustn't be shown, icons showed a sub-directory
			Corrected : Replace openpanel by savepanel when asking for saving path

	1.1.1:	Corrected : The observers didn't work, also observers are reseted when new model is opened
			Corrected : Analysis of group in a component was not done

	1.1:	Add automatic link between version in "about" prompt and the extension version
			Add french translation in extension description	
			Improve component loading, in sub-routing in order to reduce file size
			Make messages with "'" characters, in HTML, works.
			Reduce icons size to 23*23 to fit in same window width, due to "options" added button
			Added options prompt, removed the option menu
			Correct relative link function error in BGSketchup.rb
			Correct error while saving all definitions

	1.0.1:	Correction of "all definitions reload" which didn't worked
			Improve "all definitions upload" by uploading definition from model.entity recursively from component to sub-components.

	1.0:	First official release

=end

BGSketchup_Composants_extension.creator="BGSketchup"
BGSketchup_Composants_extension.description = "Plugins to manage components in a model / Plugins pour gerer les composants dans un modele"
Sketchup.register_extension BGSketchup_Composants_extension, true