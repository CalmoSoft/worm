# The Worm Game  				   	  
# 2025, Gal Zsolt (CalmoSoft) calmosoft@gmail.com

# Game Data 

	# Map Size
		C_LEVEL_ROWSCOUNT = 20
		C_LEVEL_COLSCOUNT = 27

	# Map Items
		C_EMPTY 	= 1
		C_WALL  	= 2
		C_BRICKS  	= 3
		C_PLAYER  	= 4
		C_BOMB  	= 5	
	# The Map Data 
		aLevel = list(C_LEVEL_ROWSCOUNT)
		aCalmo = list(C_LEVEL_ROWSCOUNT)
		for nRow = 1 to C_LEVEL_ROWSCOUNT
			aLevel[nRow] = list(C_LEVEL_COLSCOUNT)
			aCalmo[nRow] = list(C_LEVEL_COLSCOUNT)
			for nCol = 1 to C_LEVEL_COLSCOUNT
				aLevel[nRow][nCol] = C_EMPTY
                                aCalmo[nRow][nCol] = 0
			next
		next

	# Add the worm
		aworm 		= [ [1,14] , [2,14] , [3,14] ]
		aLevel[1][14] 	= C_PLAYER
		aLevel[2][14] 	= C_PLAYER
		aLevel[3][14] 	= C_PLAYER
		cDirection 	= :Down

                for n=1 to 20
                    aLevel[n][3] = C_BRICKS
                next

                for n=1 to 20
                    aLevel[n][25] = C_BRICKS
                next
                for n=4 to 24
                    aLevel[20][n] = C_BOMB
                next

                for n=5 to 19
                    rn = random(1)+1
                    if rn = 1
                       aLevel[n][14] = C_WALL
                    ok
                next

                for n=4 to 19
                    rn1 = random(9)
                    rn2 = random(9)
                    for m=4 to 3+rn1
                        aLevel[n][m] = C_WALL
                    next
                    for m=24 to 24-rn2 step - 1
                        aLevel[n][m] = C_WALL
                    next
                    for x=4+rn1 to 24-rn2
                        aCalmo[n][x] = 1
                    next

                    for x=4+rn1 to 24-rn2
                        if aCalmo[n][x] = 1 and aLevel[n+1][m] = C_WALL
                           aLevel[n+1][x] = C_EMPTY
                           exit
                        ok
                    next

                    for x=24-rn2 to 4+rn1 step -1 
                        if aCalmo[n][x] = 1 and aLevel[n+1][m] = C_WALL
                           aLevel[n+1][x] = C_EMPTY
                           exit
                        ok
                    next

                next

                for n=4 to 19
                    flag = 0
                    for m=4 to 24
                        if aCalmo[n][m] = 1 and aLevel[n+1][m] = C_WALL and
                           aLevel[n][m] = C_EMPTY
                           flag = 1
                           exit                         
                        ok
                    next                     
                    if flag = 1
                       aCalmo[n][m] = 0
                       aLevel[n+1][m] = C_EMPTY
                    ok

                    flag = 0
                    for m=24 to 4 step - 1
                        if aCalmo[n][m] = 1 and aLevel[n+1][m] = C_WALL and
                           aLevel[n][m] = C_EMPTY
                           flag = 1
                           exit                         
                        ok
                    next                     
                    if flag = 1
                       aCalmo[n][m] = 0
                       aLevel[n+1][m] = C_EMPTY
                    ok

                next


        # Create the first BRICKS 
		//NewBRICKS()

	# For Game Restart 
		aLevelCopy  	= aLevel 

	# Timers 
		nKeyClock 	= clock()
		nMoveClock 	= clock() 		

	# Game Over
		lGameOver 	= False

	# Speed 
		nKeyboardSpeed  = 5
		nMovementSpeed  = 6

load "gameengine.ring"        	

func main          		

	GE_SCREEN_W = 800
	GE_SCREEN_H = 600

	oGame = New Game      	
	{

		title = "Worm Game"
		icon  = "images/BRICKS.jpg"

		Map {

			blockwidth  = 30
			blockheight = 30

			aMap = aLevel
	
			aImages = [
				"images/empty.jpg",
				"images/wall.jpg",
				"images/bricks.jpg",
				"images/player.jpg",
                                "images/bomb.jpg"
			]

			keypress = func oGame,oSelf,nkey {
				if lGameOver return ok
				# Avoid getting many keys in short time 
					if (clock() - nKeyClock) < clockspersecond()/nKeyboardSpeed return ok
					nKeyClock = Clock()
				Switch nkey 
					on Key_Esc
						oGame.Shutdown()
					on Key_Space 
						Restart(oGame)
					on Key_Right
						if cDirection = :UP or cDirection = :Down
							cDirection = :Right
						ok
					on Key_Left
						if cDirection = :UP or cDirection = :Down
							cDirection = :Left
						ok
					on Key_Up
						if cDirection = :Left or cDirection = :Right
							cDirection = :Up
						ok
					on Key_Down
						if cDirection = :Left or cDirection = :Right
							cDirection = :Down
						ok
				off
			}

			state = func oGame,oSelf {
				if clock() - nMoveClock >= clockspersecond()/nMovementSpeed
					nMoveClock = clock()
					Moveworm(oGame,oSelf)
				ok 
			}

		}
	}         

func Moveworm oGame,oMap


	//if lGameOver return ok
	aHead = aworm[len(aworm)]

	switch cDirection
		on :right 
                        if aHead[2] = 24 DisplayGameOver(oGame) return ok
			aHead[2]++
                        if aHead[2] = 24
                           see "Game Over!" + nl
                        ok

                        if aLevel[aHead[1]][aHead[2]]=C_WALL
                           see "Game Over!" + nl
                        ok

		on :left 
			if aHead[2] = 4 DisplayGameOver(oGame) return ok		
			aHead[2]--
                        if aHead[2] = 4
                           see "Game Over!" + nl
                        ok

                        if aLevel[aHead[1]][aHead[2]]=C_WALL
                           see "Game Over!" + nl
                        ok

		on :up
			if aHead[1] = 1	 DisplayGameOver(oGame) return ok		
			aHead[1]--
		on :down
			if aHead[1] = C_LEVEL_ROWSCOUNT	 DisplayGameOver(oGame) return ok		
			na = aHead[1]++
                        if aHead[1]=20
                           see "Win: reached the last row!" + nl
                        ok
                        if aLevel[aHead[1]][aHead[2]]=C_WALL
                           see "Game Over!" + nl
                        ok

	off
	if aLevel[aHead[1]][aHead[2]] = C_EMPTY
		HideCell(aworm[1])
		del(aworm,1)
	but aLevel[aHead[1]][aHead[2]] = C_BRICKS
		//NewBRICKS()
	else  
		DisplayGameOver(oGame) 
		return
	ok

 	aworm + aHead

	ShowCell(aHead)
	UpdateGameMap(oGame)

func HideCell aCell
	aLevel[aCell[1]][aCell[2]] = C_EMPTY
        aCalmo[aCell[1]][aCell[2]] = 1

func ShowCell aCell
	aLevel[aCell[1]][aCell[2]] = C_PLAYER
 	
func UpdateGameMap oGame
	# The Map is our first object in Game Objects 
		oGame.aObjects[1].aMap = aLevel

func DisplayGameOver oGame 
        //see "You reached the last row" + nl
        Restart(oGame)

func Restart oGame
	# Restart the Level
		aLevel = aLevelCopy  
		aworm = [ [1,14] , [2,14] , [3,14] ]
		cDirection = :Down
		UpdateGameMap(oGame)
		lGameOver = False
                newGame() 

func newGame()

	# Map Size
		C_LEVEL_ROWSCOUNT = 20
		C_LEVEL_COLSCOUNT = 27

	# Map Items
		C_EMPTY 	= 1
		C_WALL  	= 2
		C_BRICKS  	= 3
		C_PLAYER  	= 4
		C_BOMB  	= 5	
	# The Map Data 
		aLevel = list(C_LEVEL_ROWSCOUNT)
		aCalmo = list(C_LEVEL_ROWSCOUNT)
		for nRow = 1 to C_LEVEL_ROWSCOUNT
			aLevel[nRow] = list(C_LEVEL_COLSCOUNT)
			aCalmo[nRow] = list(C_LEVEL_COLSCOUNT)
			for nCol = 1 to C_LEVEL_COLSCOUNT
				aLevel[nRow][nCol] = C_EMPTY
                                aCalmo[nRow][nCol] = 0
			next
		next

	# Add the worm
		aworm 		= [ [1,14] , [2,14] , [3,14] ]
		aLevel[1][14] 	= C_PLAYER
		aLevel[2][14] 	= C_PLAYER
		aLevel[3][14] 	= C_PLAYER
		cDirection 	= :Down

                for n=1 to 20
                    aLevel[n][3] = C_BRICKS
                next

                for n=1 to 20
                    aLevel[n][25] = C_BRICKS
                next
                for n=4 to 24
                    aLevel[20][n] = C_BOMB
                next

                for n=5 to 19
                    rn = random(1)+1
                    if rn = 1
                       aLevel[n][14] = C_WALL
                    ok
                next

                for n=4 to 19
                    rn1 = random(9)
                    rn2 = random(9)
                    for m=4 to 3+rn1
                        aLevel[n][m] = C_WALL
                    next
                    for m=24 to 24-rn2 step - 1
                        aLevel[n][m] = C_WALL
                    next
                    for x=4+rn1 to 24-rn2
                        aCalmo[n][x] = 1
                    next

                    for x=4+rn1 to 24-rn2
                        if aCalmo[n][x] = 1 and aLevel[n+1][m] = C_WALL
                           aLevel[n+1][x] = C_EMPTY
                           exit
                        ok
                    next

                    for x=24-rn2 to 4+rn1 step -1 
                        if aCalmo[n][x] = 1 and aLevel[n+1][m] = C_WALL
                           aLevel[n+1][x] = C_EMPTY
                           exit
                        ok
                    next

                next

                for n=4 to 19
                    flag = 0
                    for m=4 to 24
                        if aCalmo[n][m] = 1 and aLevel[n+1][m] = C_WALL and
                           aLevel[n][m] = C_EMPTY
                           flag = 1
                           exit                         
                        ok
                    next                     
                    if flag = 1
                       aCalmo[n][m] = 0
                       aLevel[n+1][m] = C_EMPTY
                    ok

                    flag = 0
                    for m=24 to 4 step - 1
                        if aCalmo[n][m] = 1 and aLevel[n+1][m] = C_WALL and
                           aLevel[n][m] = C_EMPTY
                           flag = 1
                           exit                         
                        ok
                    next                     
                    if flag = 1
                       aCalmo[n][m] = 0
                       aLevel[n+1][m] = C_EMPTY
                    ok

                next


        # Create the first BRICKS 
		//NewBRICKS()

	# For Game Restart 
		aLevelCopy  	= aLevel 

	# Timers 
		nKeyClock 	= clock()
		nMoveClock 	= clock() 		

	# Game Over
		lGameOver 	= False

	# Speed 
		nKeyboardSpeed  = 5
		nMovementSpeed  = 6
