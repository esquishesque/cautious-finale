#written by emily clare
#this script goes through a folder of soundfiles of individual words starting with d and t.
#it creates varying levels of ambiguous stimuli between d and t,
#using the vowel of d and the onset of t, and shortening VOT and transitions incrementally.
#the resulting .wav file is saved.


form arguments
	comment directory:
	text directory /Users/emcee/Documents/school/dissertation/ex5/sound_files/sz_script/
	real fricIntensity 48
	real vowIntensity 55
	real minvowdif 0.015

#######????????????????????########
	real levelStart 10
	real levelEnd 90
	real levelInc 20
#	real findur 0.04212
#	real ipercent 0.4658
#######????????????????????########

endform

###iterate through files and open them
printline tworddword'tab$'vowdif'tab$'vowpercent'tab$'tdur'tab$'ddur'tab$'tvow'tab$'dvow

Create Strings as file list... tlist 'directory$'/s*.wav
tnumberOfFiles = Get number of strings
for tfile to tnumberOfFiles
	select Strings tlist
	t_file$ = Get string... tfile
	t_word$ = left$ ("'t_file$'", (length ("'t_file$'") -4))
	t_grid$ = replace$ ("'t_file$'", ".wav", ".TextGrid", 1)
	Read from file... 'directory$'/'t_file$'
	Read from file... 'directory$'/'t_grid$'
	###fill out textgrid times for each t word
	select TextGrid 't_word$'
	temp = Get start point... 1 2
	tbeg = temp
	tpul = Get start point... 1 3
	tend = Get start point... 1 4
#	temp = Get start point... 1 5
	taft = tend + 0.05
	tbef = tbeg - 0.05
	endeditor
	select all
	minus Strings tlist
	Remove

	Create Strings as file list... dlist 'directory$'/z*.wav
	dnumberOfFiles = Get number of strings
	for dfile to dnumberOfFiles
		select Strings dlist
		d_file$ = Get string... dfile
		d_word$ = left$ ("'d_file$'", (length ("'d_file$'") -4))
		d_grid$ = replace$ ("'d_file$'", ".wav", ".TextGrid", 1)
		Read from file... 'directory$'/'d_word$'.wav
		Read from file... 'directory$'/'d_grid$'

		###fill out textgrid times for each d word
		select TextGrid 'd_word$'
		temp = Get start point... 1 2
		dbeg = temp
		dpul = Get start point... 1 3
		dend = Get start point... 1 4
#		temp = Get start point... 1 5
		daft = dend + 0.05
		dbef = dbeg - 0.05		
		call clean

		###set up other variables
		tdur = tpul-tbeg
		ddur = dpul-dbeg
		durdif = tdur-ddur
		tvow = tend-tpul
		dvow = dend-dpul
		vowdif = dvow-tvow
		vowpercent = vowdif/tvow
		printline 't_word$''d_word$''tab$''vowdif''tab$''vowpercent''tab$''tdur''tab$''ddur''tab$''tvow''tab$''dvow'

elig1 = vowdif > minvowdif
#elig2 = vowpercent < 0.36
#elig3 = tdur > 0.063

#printline eligibility'tab$''elig1'
#printline eligibility'tab$''elig1''tab$''elig2''tab$''elig3'
#this is the if about only synthing eligible ones
		if vowdif > minvowdif


##############

numLevels = ((levelEnd-levelStart)/levelInc)+1
for dur to numLevels
durLevel = levelStart + (levelInc*(dur-1))
#the durLevel will increase over reps

#######################################################################
			###cutting dur
			#%#%ipercent = there used to be something here :(
			#%#%findur = ddur + (ipercent*durdif) #this we use for multiple stages
			findur = ((tdur-ddur) * durLevel/100) + ddur
                              #the findur will increase over reps, making it more s like
			intFile$ = "intermediateStage-'ttp''i'.wav"
			call openEdit 'directory$'/'t_file$'
	
			###calculate cut points
			tdurcut = tdur - findur
			tdurcutbeg = tpul - tdurcut
			tdurcutend = tpul
#	printline dur: 'dur'
#	print findur: 'findur'
#	print tdurcut: 'tdurcut'

			###adjust to zero crossing
			#%call precZero 'tdurcutend'	
			#%old = tdurcutend		
			#%tdurcutend = Get cursor
			#%if old - tdurcutend > 0.003
			#%	printline ERROR! old: 'old' tdurcutend: 'tdurcutend' word: 't_word$'
			#%endif	

			###cut and save
			Select... tdurcutbeg tdurcutend
			Cut
			newtpul1 = tpul-tdurcut
			newtpul = newtpul1

			###save file
			intermediatePoint = newtpul - tbef
			call saveClean 'intFile$' tbef newtpul


##########
for vow to numLevels
vowLevel = levelStart + (levelInc*(vow-1))
#the vowLevel will increase over repetitions
#######################################################################
			###comping vow
			finvow = ((dvow-tvow) * ((100-vowLevel)/100)) + tvow
			call open 'directory$'/'d_file$'

			###calculate cut points
			dvowcut = dvow - finvow

			dpartvow=dvow/3
			finpartvow=dpartvow-(dvow-finvow)
			vowratio = finpartvow/dpartvow
			
			dvowcompbeg = dpul
			dvowcompend = dpul+dpartvow
#print 'dvowcompend'
		#			vowratio = finvow/dvow

#	printline
#	printline vow: 'vow'
#	print finvow: 'finvow'
#	print dowcut: 'dvowcut'

			###psola
			Create DurationTier... dur 0.0 1.0
			Add point... 'dvowcompbeg'-0.005 1.0
			Add point... 'dvowcompbeg'+0.005 'vowratio'
			Add point... 'dvowcompend'-0.005 'vowratio'
			Add point... 'dvowcompend'+0.005 1.0
			select Sound 'd_word$'
			noprogress To Manipulation... 0.01 75 600
			select Manipulation 'd_word$'
			plus DurationTier dur
			Replace duration tier
			select Manipulation 'd_word$'
			Get resynthesis (PSOLA)
			Edit
	select Sound 'd_word$'
	editor Sound 'd_word$'

			newdaft = daft - dvowcut
			Select... dpul newdaft
			Extract selected sound (preserve times)
			endeditor
			select Sound untitled
			Scale intensity... vowIntensity
			Edit
			select Sound untitled
			editor Sound untitled
			Select... dpul newdaft
			Copy selection to Sound clipboard

			###open intermediate and paste
			call clean
			call openEditScale 'directory$'/results/'intFile$' fricIntensity
			Move cursor to... intermediatePoint
			Paste after selection

			###save file
			secondHalf = (newdaft-dpul)
			intend = intermediatePoint + secondHalf
			call saveClean 'durLevel'-'vowLevel'.wav 0 intend
#######################################################################

endfor

##############

#this is the if about only synthing eligible ones #elig next three lines
		else
			endeditor
		endif
	endfor
	#endif
###end loops
#endif
endfor
select all
Remove


#####procedure find preceding zero crossing (cursor will be on it)
procedure precZero .cursor
	Move cursor to... .cursor
	Move cursor to nearest zero crossing
	zero = Get cursor
	while zero > .cursor
		#%printline 'cursor'
		#%printline 'zero'
		.cursor = .cursor - 0.001
		Move cursor to... .cursor
		Move cursor to nearest zero crossing
		zero = Get cursor
	endwhile
endproc

#####procedure to open file
procedure open .name$
	Read from file... '.name$'
	.name$ = selected$ ("Sound")
	select Sound '.name$'
endproc

#####procedure to edit file
procedure openEditScale .name$ .intensity
	Read from file... '.name$'
	.name$ = selected$ ("Sound")
	select Sound '.name$'
	Scale intensity... .intensity
	Edit
	select Sound '.name$'
	editor Sound '.name$'
endproc

#####procedure to open and edit file
procedure openEdit .name$
	Read from file... '.name$'
	.name$ = selected$ ("Sound")
	select Sound '.name$'
	Edit
	select Sound '.name$'
	editor Sound '.name$'
endproc

#####procedure to save and clean
procedure saveClean .name$ .beg .end
	Select... .beg .end
	Write selected sound to WAV file... 'directory$'/results/'.name$'
	call clean
endproc

#####procedure to clean
procedure clean
	endeditor
	select all
	minus Strings tlist
	minus Strings dlist
	Remove
endproc