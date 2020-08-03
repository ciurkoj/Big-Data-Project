!!!!!!!!!!!!
Make sure you have downloaded the right repository: https://github.coventry.ac.uk/ciurkoj/5011CEM
It guaratees, the project will run without any issues.
!!!!!!!!!!!!

1. gui_exported.m
			1.1. Requirements:
				- make sure you have all files in the same directory: FileChooser.m, DefaultFileChooser.m, PathFinder.m
				- chceck if your MATLAB version is R2019b or higher
				- check if you have installed package Mapping Toolbox 4.9, availabe in Add-on Explorer

			1.2 Instructions how to use gui_exported.m
				1.2.1 This is the script version. It requires MATLAB Mapping Toolbox 4.9 to be installed in MATLAB environment.
				1.2.2 If everything is set up, go to folder where gui_exported.m is located, run the script by typing full 
							name in MATLAB terminal or by finding the file in "Current folder" section and double clicking on it. 
							It should open the file in MATLAB editor. Click "Run" button from panel above.
				1.2.3 When the application is fully loaded it is ready to use.
				1.2.4 To read NetCDF Files click "Upload an NC file" button, it will open a dialog window.
				1.2.5 Select o3_surface_20180701000000.nc file from folder "Data/Model Combined/" for combined model file.
							Individual models are availabe in "Data/Model Individual/".
							Or go to section "Extract data from CSV model, click on "Choose folder with CSV models" and select
							the folder where you keep extracted form .fig to .csv files. Select where which ensemble do you want to display.
				1.2.6 Click "Load data" to load data to program's memory. This process may take a while, please be patient.
				1.2.7 When data have been loaded, you should be able to see new entries in table on the left side of the application.
				1.2.8 Then click on "Generate a Map" button. This process will take long time to complete.
				1.2.9 When Map has been plotted, you should be able to see it in the app.

			1.3. More function of ozone_levels_visualisator.exe:
				- click on the "Play" button to run a presentation
				- use switch next to "play" button to switch between show composed of: images and figures
				- use slider to change displayed map
				- export a video by typing the name in "Save as" cell, select save location by clicking "Select save destination",
					then select resolution from dropdown list. If everything is set up, click "Export video file" button to export the video.

2. ozone_levels_visualisator Executable

			2.1. Prerequisites for Deployment 
					Verify that version 9.7 (R2019b) of the MATLAB Runtime is installed.   
					If not, you can run the MATLAB Runtime installer.
					To find its location, enter
						
							>>mcrinstaller
								
					at the MATLAB prompt.
					NOTE: You will need administrator rights to run the MATLAB Runtime installer. 

					Alternatively, download and install the Windows version of the MATLAB Runtime for R2019b 
					from the following link on the MathWorks website:

							https://www.mathworks.com/products/compiler/mcr/index.html
						
					For more information about the MATLAB Runtime and the MATLAB Runtime installer, see 
					"Distribute Applications" in the MATLAB Compiler documentation  
					in the MathWorks Documentation Center.



			2.2. Instructions how to use ozone_levels_visualisator.exe: :
				2.2.1 This is the compiled version of gui_exported.m It requires MATLAB Runtime 9.7 to run
				2.2.2 If MATLAB Runtime is installed, run the application by double-click on the ozone_levels_visualisator.exe
				2.2.3 When the application is fully loaded it is ready to use.
				2.2.4 To read NetCDF Files click "Upload an NC file" button, it will open a dialog window.
								1.2.5 Select o3_surface_20180701000000.nc file from folder "Data/Model Combined/" for combined model file.
							Individual models are availabe in "Data/Model Individual/".
							Or go to section "Extract data from CSV model, click on "Choose folder with CSV models" and select
							the folder where you keep extracted form .fig to .csv files. Select where which ensemble do you want to display.
				2.2.6 Click "Load data" to load data to program's memory. This process may take a while, please be patient.
				2.2.7 When data have been loaded, you should be able to see new entries in table on the left side of the application.
				2.2.8 Then click on "Generate a Map" button. This process will take long time to complete.
				2.2.9 When Map has been plotted, you should be able to see it in the app.

			2.3. More function of ozone_levels_visualisator.exe:
				- click on the "Play" button to run a presentation
				- use switch next to "play" button to switch between show composed of: images and figures
				- use slider to change displayed map
				- export a video by typing the name in "Save as" cell, select save location by clicking "Select save destination",
					then select resolution from dropdown list. If everything is set up, click "Export video file" button to export the video.
				


