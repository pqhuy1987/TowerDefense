//
//  GameScene.swift
//  TookaDefense
//
//  Created by Antoine Beneteau on 29/11/2015.
//  Copyright © 2015 Tastyapp. All rights reserved.
//
//	******************** TookaDefense/GameUtils+Levels ********************
//	Les classes utiles pour la scene active et les matrices pour les levels
//
//	******************** TookaDefense/GameUtils+LevelsParticules ********************
//	Les particules utilisées pour le jeux sont toutes dans ce dossier
//
//	******************** TookaDefense/GameUtils+LevelsEntities ********************
//	Toutes les classes des entitées du jeu (tours, ennemis, obstacles)
//
//	******************** TookaDefense/GameUtils+LevelsComponents ********************
//	Tous les composants des GKEntity du jeu (visuel, animation, tirs, vie de l'ennemi)
//
//	******************** TookaDefense/GameUtils+LevelsScenes ********************
//	Toutes les scenes utilisées pour le jeu
//
//	******************** TookaDefense/GameUtils+LevelsStates ********************
//	Les differentes étapes du jeu sont gérés avec une "StateMachine" (menu, level, actif, fin)
//
//	******************** TookaDefense/GameUtils+LevelsArts ********************
//	Les images utilisées dans le jeu
//
//	******************** TookaDefense/GameUtils+LevelsGameSceneHelper ********************
//	Les variables et fonctions utilisées pour le bon fonctionnement des scenes sous forme du pré-scene
//
//	******************** TookaDefense/GameUtils+LevelsOverlayNodeClass ********************
//	Les classes des "Nodes" utilisées pour les sprite et label utilisés sur les scenes
//

import SpriteKit
import GameplayKit


class GameScene: GameSceneInit {
	
	let gridRows = 10
	
	let gridHeightModifier = 0.6
	let gridWidthModifier = 0.85
	
	var grid = SKNode()
	var optionGrid = SKNode()
	var hudGrid = SKNode()
	var layout = [[GKEntity]]()
	var boxSize: Double!
	var gridColumns: Int!
	var offsetX: Double!
	var offsetY: Double!
	
	var waveManager: WaveManager!
	
	lazy var stateMachine: GKStateMachine = GKStateMachine(states:
		[
			GameSceneReadyState(scene: self),
			GameSceneLevelSelector(scene: self),
			GameSceneActiveState(scene: self),
			GameSceneWinState(scene: self),
			GameSceneLoseState(scene: self)
		])
	
	var lastUpdateTimeInterval: NSTimeInterval = 0
	
	var entities = Set<GKEntity>()
	
	var towerSelectorNodes = [TowerSelectorNode]()
	var placingTower = false
	var placingTowerOnNode = SKNode()
	
	var selectorPosition: int2 = int2(0,0)
	
	lazy var componentSystems: [GKComponentSystem] = {
		let animationSystem = GKComponentSystem(
			componentClass: AnimationComponent.self)
		let firingSystem = GKComponentSystem(componentClass: FiringComponent.self)
		return [animationSystem, firingSystem]
	}()
	
	override func didMoveToView(view: SKView) {
		super.didMoveToView(view)
		
		let background = SKSpriteNode(color: UIColor(red: 0.20, green: 0.29, blue: 0.37, alpha: 1.0), size: CGSize(width: self.size.width, height: self.size.height))
		background.position = CGPointMake(self.size.width / 2, self.size.height / 2)
		addChild(background)
		
		physicsWorld.gravity = CGVector(dx: 0, dy: 0)
		
		stateMachine.enterState(GameSceneReadyState.self)
		
		let waves = [
			Wave(enemyCount: 5, enemyDelay: 1.5, enemyType: .Enemy1),
			Wave(enemyCount: 5, enemyDelay: 1.5, enemyType: .Enemy2),
		]
		waveManager = WaveManager(waves: waves,
			newWaveHandler: { (waveNum) -> Void in self.runAction(SKAction.playSoundFileNamed("NewWave.mp3", waitForCompletion: false))},
			newEnemyHandler: { (enemyType) -> Void in self.addEnemy(enemyType, gridposition: int2(0,5), endGridPosition: int2(17,5))}
		)
		waveLabel.text = "\(waveManager.currentWave)/\(waveManager.waves.count)"
	}
	
	override func update(currentTime: NSTimeInterval) {
		super.update(currentTime)
		if paused { return }
		
		guard view != nil else { return }
		
		let deltaTime = currentTime - lastUpdateTimeInterval
		lastUpdateTimeInterval = currentTime
		
		stateMachine.updateWithDeltaTime(deltaTime)
		
		for componentSystem in componentSystems {
			componentSystem.updateWithDeltaTime(deltaTime)
		}
	}
	
	override func didFinishUpdate() {
		let enemies: [EnemyEntity] = entities.flatMap { entity in
			if let enemy = entity as? EnemyEntity {
				return enemy
			}
			return nil
		}
		let towers: [TowerEntity] = entities.flatMap { entity in
			if let tower = entity as? TowerEntity {
				return tower
			}
			return nil
		}
		let slower: [ObstacleEntity] = entities.flatMap { entity in
			if let slower = entity as? ObstacleEntity {
				return slower
			}
			return nil
		}
		
		for tower in towers {
			let towerType = tower.towerType
			var target: EnemyEntity?
			for enemy in enemies.filter({
				(enemy: EnemyEntity) -> Bool in
				distanceBetween(tower.spriteComponent.node, nodeB: enemy.spriteComponent.node) < towerType.range}) {
					
					if let t = target {
						if enemy.spriteComponent.node.position.x >
							t.spriteComponent.node.position.x {
								target = enemy
						}
					} else {
						target = enemy
					}
			}
			tower.firingComponent.currentTarget = target
		}
		
		for enemy in enemies {
			for slow in slower {
				let test: Bool = (coordinateOfPoint(slow.spriteComponent.node.position)!.x == coordinateOfPoint(enemy.spriteComponent.node.position)!.x) && (coordinateOfPoint(slow.spriteComponent.node.position)!.y == coordinateOfPoint(enemy.spriteComponent.node.position)!.y)
				if slow.obstacleType == .Slow && !enemy.slowed {
					if test {
						boosterParticule(slow.spriteComponent.node.position, explosionType: "ABDA")
						enemy.enemySlowed(0.7)
					}
				} else if slow.obstacleType == .Boost && !enemy.boosted {
					if test {
						boosterParticule(slow.spriteComponent.node.position, explosionType: "ABDA")
						enemy.enemyBoosted(1.3)
					}
				} else if slow.obstacleType == .Teleport && !enemy.teleported{
					if test {
						var position = teleport[1].spriteComponent.node.position
						if position == slow.spriteComponent.node.position {
							position = teleport[0].spriteComponent.node.position
						}
						teleportParticule(teleport[1].spriteComponent.node.position, explosionType: "ABDA")
						teleportParticule(teleport[0].spriteComponent.node.position, explosionType: "ABDA")
						enemy.enemyTeleported(position)
						setEnemyOnPath(enemy, toPoint: enemy.endPoint)
						updateVisualPath()
					}
				} else if slow.obstacleType == .Diamond && diamond == 0{
					if test {
						diamond++
						diamondLabel.text = "\(diamond)"
						slow.spriteComponent.node.zPosition = 2
						slow.spriteComponent.node.runAction(SKAction.moveTo(diamondLabelImage.position, duration: 1.0))
					}
				}
			}
			if enemy.healthComponent.health <= 0 {
				for _ in 0..<5 {
					explosion(enemy.spriteComponent.node.position, explosionType: "Enemy")
				}
				gold += enemy.enemyType.goldReward
				updateHUD()
				enemyKilled++
				if waveManager.removeEnemyFromWave() == true {
					if levelToLoad <= levels.count {
						stateMachine.enterState(GameSceneWinState.self)
					}
				}
				waveLabel.text = "\(waveManager.currentWave)/\(waveManager.waves.count)"
				enemy.spriteComponent.node.removeFromParent()
				entities.remove(enemy)
			}
			else if enemy.spriteComponent.node.position.x >= enemy.endPoint.x - 1 {
				baseLives -= enemy.enemyType.baseDamage
				updateHUD()
				
				if baseLives <= 0 {
					stateMachine.enterState(GameSceneLoseState.self)
				}
				enemy.spriteComponent.node.removeFromParent()
				entities.remove(enemy)
			}
		}
	}
	
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		for touch in (touches ) {
			let touchLocation = touch.locationInNode(self)
			let touchedNode = self.nodeAtPoint(touchLocation)
			
			switch stateMachine.currentState {
			case is GameSceneReadyState:
				if touchedNode.name == "playButton" {
					stateMachine.enterState(GameSceneLevelSelector.self)
					return
				}
			case is GameSceneLevelSelector:
				switch touchedNode.name! {
				case "homeButton":
					let newScene = GameScene(fileNamed:"GameScene")
					newScene!.scaleMode = .AspectFill
					let reveal = SKTransition.doorsCloseHorizontalWithDuration(0.5)
					self.view?.presentScene(newScene!, transition: reveal)
					break
				case "box1":
					levelToLoad = 1
					stateMachine.enterState(GameSceneActiveState.self)
					break
				case "box2":
					levelToLoad = 2
					stateMachine.enterState(GameSceneActiveState.self)
					break
				case "box3":
					levelToLoad = 3
					stateMachine.enterState(GameSceneActiveState.self)
					break
				case "box4":
					levelToLoad = 4
					stateMachine.enterState(GameSceneActiveState.self)
					break
				case "box5":
					levelToLoad = 5
					stateMachine.enterState(GameSceneActiveState.self)
					break
				case "box6":
					levelToLoad = 6
					stateMachine.enterState(GameSceneActiveState.self)
					break
				case "box7":
					levelToLoad = 7
					stateMachine.enterState(GameSceneActiveState.self)
					break
				case "box8":
					levelToLoad = 8
					stateMachine.enterState(GameSceneActiveState.self)
					break
				case "box9":
					levelToLoad = 9
					stateMachine.enterState(GameSceneActiveState.self)
					break
				case "box10":
					levelToLoad = 10
					stateMachine.enterState(GameSceneActiveState.self)
					break
				default:
					break
				}
			case is GameSceneActiveState:
				let position = coordinateOfPoint(touchLocation)
				if coordinateOfPoint(touchLocation)?.x < 18 && coordinateOfPoint(touchLocation)?.y < 10 {
					if layout[Int(position!.x)][Int(position!.y)].components.count == 0 && placingTower == false{
						placingTowerOnNode = touchedNode
						showTowerSelector(atPosition: touchLocation)
						selectorPosition = position!
						return
					}
					else if placingTower {
						if let touchedNode = self.nodeAtPoint(touchLocation).name {
							placeTower(selectorPosition, touchedNode: touchedNode)
							hideTowerSelector()
							return
						} else {
							hideTowerSelector()
							return
						}
					}
				} else {
					if touchedNode.name == "LeaveButton" {
						let newScene = GameScene(fileNamed:"GameScene")
						newScene!.scaleMode = .AspectFill
						let reveal = SKTransition.doorsCloseHorizontalWithDuration(0.5)
						self.view?.presentScene(newScene!, transition: reveal)
						return
					}
					if touchedNode.name == "PauseButton" && !paused{
						paused = true
					} else {
						paused = false
					}
				}
				break
			case is GameSceneLoseState:
				if touchedNode.name == "homeButton" {
					let newScene = GameScene(fileNamed:"GameScene")
					newScene!.scaleMode = .AspectFill
					let reveal = SKTransition.doorsCloseHorizontalWithDuration(0.5)
					self.view?.presentScene(newScene!, transition: reveal)
					return
				}
				break
			case is GameSceneWinState:
				if touchedNode.name == "homeButton" {
					let newScene = GameScene(fileNamed:"GameScene")
					newScene!.scaleMode = .AspectFill
					let reveal = SKTransition.doorsCloseHorizontalWithDuration(0.5)
					self.view?.presentScene(newScene!, transition: reveal)
					return
				}
				break
			default:
				break
			}
		}
	}
	
	func startFirstWave() {
		waveManager.startNextWave()
	}
	
	func addEntity(entity: GKEntity) {
		entities.insert(entity)
		for componentSystem in self.componentSystems {
			componentSystem.addComponentWithEntity(entity)
		}
		
		if let spriteNode = entity.componentForClass(
			SpriteComponent.self)?.node {
				addNode(spriteNode, toGameLayer: .Sprites)
		}
	}
	
	func addEnemy(enemyType: EnemyType, gridposition: int2, endGridPosition: int2) {
		let startPosition = pointForGridPosition(gridposition)
		let endPosition = pointForGridPosition(endGridPosition)
		
		let enemy = EnemyEntity(enemyType: enemyType, size: CGSize(width: boxSize, height: boxSize), endPoint: endPosition)
		let enemyNode = enemy.spriteComponent.node
		enemyNode.position = startPosition
		setEnemyOnPath(enemy, toPoint: enemy.endPoint)
		updateVisualPath()
		
		addEntity(enemy)
	}
	
	func addTower(towerType: TowerType, gridPosition: int2) {
		if gold >= towerType.cost {
			gold -= towerType.cost
			moneySpent += towerType.cost
			updateHUD()
			if let node = graph.nodeAtGridPosition(gridPosition) {
				let position = pointForGridPosition(gridPosition)
				let coordinate = gridPosition
				
				let towerEntity = TowerEntity(towerType: towerType, size: CGSize(width: boxSize, height: boxSize))
				towerEntity.spriteComponent.node.position = position
				layout[Int(coordinate.x)][Int(coordinate.y)] = towerEntity
				
				graph.removeNodes([node])
				recalculateEnemyPaths()
				if path != nil {updateVisualPath()}
				
				addEntity(towerEntity)
			}
		}
	}
	
	func addObstacle(obstacleType: ObstacleType, gridPosition: int2) {
		if let node = graph.nodeAtGridPosition(gridPosition) {
			let position = pointForGridPosition(gridPosition)
			let coordinate = gridPosition
			
			let obstacleEntity = ObstacleEntity(obstacleType: obstacleType, size: CGSize(width: boxSize * 0.9, height: boxSize * 0.9))
			obstacleEntity.spriteComponent.node.position = position
			layout[Int(coordinate.x)][Int(coordinate.y)] = obstacleEntity
			
			switch obstacleType {
			case .Wall:
				graph.removeNodes([node])
				break
			case .Teleport:
				teleport.append(obstacleEntity)
				break
			default:
				break
			}
			addEntity(obstacleEntity)
		}
	}
	
	func randomPosition() ->int2 {
		let x: Int32
		let y: Int32
		
		x = Int32(arc4random() % UInt32(gridColumns - 4))
		y = Int32(arc4random() % UInt32(gridRows - 1))
		
		return int2(x,y)
	}
	
	func coordinateOfPoint(location: CGPoint) -> int2? {
		let col = Int32(ceil((Double(location.x) - offsetX) / boxSize)) - 1
		let row = Int32(ceil((Double(location.y) - offsetY) / boxSize)) - 1
		
		return int2(col, row) // use range operator here to make it better
	}
	
	// returns CGPoint at center of grid coordinate
	func pointForGridPosition(gridPosition: int2) -> CGPoint {
		let x = Double(gridPosition.x) * boxSize + offsetX + (boxSize / 2)
		let y = Double(gridPosition.y) * boxSize + offsetY + (boxSize / 2)
		
		return CGPoint(x: x, y: y)
	}
	
	func createGrid() {
		grid = SKNode()
		
		let usableHeight = Double(size.height) * gridHeightModifier
		let usableWidth = Double(size.width) * gridWidthModifier
		
		boxSize = usableHeight / Double(gridRows)
		gridColumns = Int(usableWidth / boxSize)
		offsetX = (Double(size.width) - boxSize * Double(gridColumns)) / 4.0
		offsetY = (Double(size.height) - boxSize * Double(gridRows)) / 2.5
		
		for col in 0 ..< gridColumns {
			let xPos = boxSize * Double(col)
			layout.append(Array(count: gridRows, repeatedValue: GKEntity()))
			
			for row in 0 ..< gridRows {
				let yPos = boxSize * Double(row)
				
				let path = UIBezierPath(rect: CGRect(x: xPos + offsetX, y: yPos + offsetY, width: boxSize, height: boxSize))
				let box = SKShapeNode()
				box.path = path.CGPath
				box.strokeColor = UIColor.grayColor()
				box.alpha = 0.3
				grid.addChild(box)
			}
		}
		self.addChild(grid)
	}
	
	func createOptionGrid() {
		optionGrid = SKNode()
		
		for row in 0 ..< gridRows / 2 {
			let yPos = boxSize * 2.0 * Double(row) + offsetY
			let path = UIBezierPath(rect: CGRect(x: boxSize * Double(gridColumns) + offsetX * 1.3, y: yPos, width: boxSize * 2.0, height: boxSize * 2.0))
			let box = SKShapeNode()
			box.path = path.CGPath
			box.strokeColor = UIColor.grayColor()
			box.alpha = 1.0
			box.lineWidth = 2.0
			
			pauseButton.position = hudConvertPlacement(0, hud: "Option", boxWidthAndHeight: CGSize(width: boxSize * 2.0, height: boxSize * 2.0))
			leaveButton.position = hudConvertPlacement(1, hud: "Option", boxWidthAndHeight: CGSize(width: boxSize * 2.0, height: boxSize * 2.0))
			sellButton.position = hudConvertPlacement(2, hud: "Option", boxWidthAndHeight: CGSize(width: boxSize * 2.0, height: boxSize * 2.0))
			buyButton.position = hudConvertPlacement(3, hud: "Option", boxWidthAndHeight: CGSize(width: boxSize * 2.0, height: boxSize * 2.0))
			recordButton.position = hudConvertPlacement(4, hud: "Option", boxWidthAndHeight: CGSize(width: boxSize * 2.0, height: boxSize * 2.0))
			
			optionGrid.addChild(box)
		}
		addChild(optionGrid)
	}
	
	func createHUDGrid() {
		hudGrid = SKNode()
		
		for row in 0 ..< gridColumns / 6 {
			let yPos = boxSize * Double(gridRows) + offsetY + offsetX * 0.3
			let path = UIBezierPath(rect: CGRect(x: boxSize * 6.0 * Double(row) + offsetX, y: yPos, width: boxSize * 6.0, height: boxSize))
			let box = SKShapeNode()
			box.path = path.CGPath
			box.strokeColor = UIColor.grayColor()
			box.alpha = 1.0
			box.lineWidth = 2.0
			
			hudGrid.addChild(box)
		}
		
		goldLabel.position = hudConvertPlacement(0, hud: "Stats", boxWidthAndHeight: CGSize(width: boxSize * 6.0, height: boxSize))
		baseLabel.position = hudConvertPlacement(1, hud: "Stats", boxWidthAndHeight: CGSize(width: boxSize * 6.0, height: boxSize))
		waveLabel.position = hudConvertPlacement(2, hud: "Stats", boxWidthAndHeight: CGSize(width: boxSize * 6.0, height: boxSize))
		diamondLabel.position = hudConvertPlacement(3, hud: "Stats", boxWidthAndHeight: CGSize(width: boxSize * 5.5, height: boxSize))
		self.addChild(hudGrid)
	}
	
	func hudConvertPlacement(gridPosition: Int, hud: String, boxWidthAndHeight: CGSize) ->CGPoint {
		let x: Double
		let y: Double
		
		let a = offsetY
		let b = offsetX
		let lOffset = b * 0.3
		let boxW = boxWidthAndHeight.width / 2
		let boxH = boxWidthAndHeight.height / 2
		
		if hud == "Stats" {
			x = b + Double(gridPosition + (gridPosition + 1)) * Double(boxW)
			y = a + boxSize * Double(gridRows) + lOffset + Double(boxH)
			return CGPoint(x: x, y: y)
		} else if hud == "Option" {
			x = b * 1.3 + boxSize * Double(gridColumns) + Double(boxW)
			y = a + Double(gridPosition + (gridPosition + 1)) * Double(boxH)
			return CGPoint(x: x, y: y)
		}
		return CGPointMake(0, 0)
	}
	
	func addHudStuff() {
		let optionStuffSize = CGSize(width: boxSize * 1.5, height: boxSize * 1.5)
		let statStuffSize = CGSize(width: boxSize / 2, height: boxSize / 2)
		
		pauseButton.size = optionStuffSize
		pauseButton.name = "PauseButton"
		self.addChild(pauseButton)
		leaveButton.size = optionStuffSize
		leaveButton.name = "LeaveButton"
		self.addChild(leaveButton)
		sellButton.size = optionStuffSize
		sellButton.name = "SellButton"
		self.addChild(sellButton)
		buyButton.size = optionStuffSize
		buyButton.name = "BuyButton"
		self.addChild(buyButton)
		recordButton.size = optionStuffSize
		recordButton.name = "RecordButton"
		self.addChild(recordButton)
		
		baseLabel.runAction(SKAction.fadeAlphaTo(1.0, duration: 0.5))
		baseLabelImage.size = statStuffSize
		baseLabelImage.position = CGPointMake(baseLabel.position.x - CGFloat(boxSize * 2.0), baseLabel.position.y)
		self.addChild(baseLabelImage)
		goldLabel.runAction(SKAction.fadeAlphaTo(1.0, duration: 0.5))
		goldLabelImage.size = statStuffSize
		goldLabelImage.position = CGPointMake(goldLabel.position.x - CGFloat(boxSize * 2.0), goldLabel.position.y)
		self.addChild(goldLabelImage)
		waveLabel.runAction(SKAction.fadeAlphaTo(1.0, duration: 0.5))
		waveLabelImage.size = statStuffSize
		waveLabelImage.position = CGPointMake(waveLabel.position.x - CGFloat(boxSize * 2.0), waveLabel.position.y)
		self.addChild(waveLabelImage)
		diamondLabel.runAction(SKAction.fadeAlphaTo(1.0, duration: 0.5))
		diamondLabelImage.size = statStuffSize
		diamondLabelImage.position = CGPointMake(diamondLabel.position.x - CGFloat(boxSize / 1.15), diamondLabel.position.y)
		self.addChild(diamondLabelImage)
		
	}
	
	func showTowerSelector(atPosition position: CGPoint) {
		if placingTower == true {return}
		placingTower = true
		
		let gridPosition = coordinateOfPoint(position)
		selectedBox = SKSpriteNode(imageNamed: "selectedBox1")
		selectedBox.alpha = 0.0
		let animation1 = SKAction.fadeAlphaTo(0.5, duration: 0.5)
		selectedBox.position = pointForGridPosition(gridPosition!)
		selectedBox.size = CGSize(width: boxSize, height: boxSize)
		self.addChild(selectedBox)
		selectedBox.runAction(animation1)
		
		
		for towerSelectorNode in towerSelectorNodes {
			
			towerSelectorNode.position = pointForGridPosition(gridPosition!)
			gameLayerNodes[.Hud]!.addChild(towerSelectorNode)
			
			towerSelectorNode.show()
		}
	}
	
	func hideTowerSelector() {
		if placingTower == false { return }
		placingTower = false
		
		let animation1 = SKAction.fadeAlphaTo(0.0, duration: 1.0)
		selectedBox.runAction(animation1)
		
		for towerSelectorNode in towerSelectorNodes {
			towerSelectorNode.hide {
				towerSelectorNode.removeFromParent()
			}
		}
	}
	
	func loadTowerSelectorNodeForSellAndBuy(towerToSell: TowerType) {
		let towerTypeCount = TowerType.allValues.count
		let nodeForSellAndBuyPath: String = NSBundle.mainBundle().pathForResource("TowerMenu", ofType: "sks")!
		let nodeForSellAndBuyScene = NSKeyedUnarchiver.unarchiveObjectWithFile(nodeForSellAndBuyPath) as! SKScene
		
		for t in 0..<towerTypeCount {
			let towerSelectorNode = (nodeForSellAndBuyScene.childNodeWithName("MainNode"))!.copy() as! TowerSelectorNode
			towerSelectorNode.setTowerSell(towerToSell, towerType: TowerType.allValues[t], pointForSelection: numToPointForSelection(t))
		}
	}
	
	func loadTowerSelectorNodes() {
		let towerTypeCount = TowerType.allValues.count
		
		let towerSelectorNodePath: String = NSBundle.mainBundle().pathForResource("TowerMenu", ofType: "sks")!
		let towerSelectorNodeScene = NSKeyedUnarchiver.unarchiveObjectWithFile(towerSelectorNodePath) as! SKScene
		
		for t in 0..<towerTypeCount {
			let towerSelectorNode = (towerSelectorNodeScene.childNodeWithName("MainNode"))!.copy() as! TowerSelectorNode
			towerSelectorNode.setTower(TowerType.allValues[t], pointForSelection: numToPointForSelection(t))
			
			towerSelectorNodes.append(towerSelectorNode)
		}
	}
	
	func numToPointForSelection(number: Int) ->CGPoint {
		let x = CGFloat(boxSize * 1.4)
		switch number {
		case 0:
			return CGPointMake(x, 0)
		case 1:
			return CGPointMake(0, x * 1.26)
		case 2:
			return CGPointMake(-x, 0)
		case 3:
			return CGPointMake(0, -x)
		default:
			break
		}
		return CGPointMake(x, 0)
	}
	
	func initializeGrid() {
		graph = GKGridGraph(fromGridStartingAt: int2(0, 0), width: Int32(gridColumns), height: Int32(gridRows), diagonalsAllowed: false)
		pathLine = SKNode()
		self.addChild(pathLine)
	}
	
	func setEnemyOnPath(enemy: EnemyEntity, toPoint point: CGPoint)
	{
		let enemyNode = enemy.spriteComponent.node
		
		let currentNode = graph.nodeAtGridPosition(coordinateOfPoint(enemyNode.position)!)
		let endNode = graph.nodeAtGridPosition(coordinateOfPoint(enemy.endPoint)!)
		path = graph.findPathFromNode(currentNode!, toNode: endNode!) as! [GKGridGraphNode]
		path.removeAtIndex(0)
		
		var sequence = [SKAction]()
		
		for node in path {
			let location = pointForGridPosition(node.gridPosition)
			let update = SKAction.runBlock({ [unowned self] in
				enemyNode.position = self.pointForGridPosition(node.gridPosition)
				})
			let actionDuration = NSTimeInterval(200.0 / enemy.enemyType.speed)
			let action = SKAction.moveTo(location, duration: actionDuration)
			
			sequence += [action,update]
		}
		enemyNode.runAction(SKAction.sequence(sequence))
	}
	
	func recalculateEnemyPaths() {
		let enemies: [EnemyEntity] = entities.flatMap { entity in
			if let enemy = entity as? EnemyEntity {
				if enemy.healthComponent.health <= 0 {return nil}
				return enemy
			}
			return nil
		}
		
		for enemy in enemies {
			setEnemyOnPath(enemy, toPoint: enemy.endPoint)
		}
	}
	
	
	func updateVisualPath() {
		pathLine.removeAllChildren()
		
		let escapePath = self.path
		
		var index = 0
		for node in escapePath {
			let position = pointForGridPosition(node.gridPosition)
			
			if index + 1 < escapePath.count {
				let nextPosition = pointForGridPosition(escapePath[index + 1].gridPosition)
				let bezierPath = UIBezierPath()
				let startPoint = CGPointMake(position.x, position.y)
				let endPoint = CGPointMake(nextPosition.x, nextPosition.y)
				bezierPath.moveToPoint(startPoint)
				bezierPath.addLineToPoint(endPoint)
				
				let pattern: [CGFloat] = [CGFloat(boxSize / 10), CGFloat(boxSize / 10)]
				let dashed = CGPathCreateCopyByDashingPath(bezierPath.CGPath, nil, 0, pattern, 2)!
				
				let line = SKShapeNode(path: dashed)
				line.strokeColor = UIColor.blackColor()
				pathLine.addChild(line)
			}
			index++
		}
	}
	
	func placeTower(selectorPosition: int2, touchedNode: String) {
		if touchedNode == "Tower_Icon_WaterTower" {
			addTower(.Water, gridPosition: selectorPosition)
		} else if touchedNode == "Tower_Icon_PlantTower" {
			addTower(.Plant, gridPosition: selectorPosition)
		} else if touchedNode == "Tower_Icon_IceTower" {
			addTower(.Ice, gridPosition: selectorPosition)
		} else if touchedNode == "Tower_Icon_FireTower" {
			addTower(.Fire, gridPosition: selectorPosition)
		}
	}
	
	func loadLevelMap(level: Int) {
		for i in 0..<10 {
			for j in 0..<18 {
				if levels[level - 1][9 - i][j] == 1 {
					addObstacle(.Wall, gridPosition: int2(Int32(j),Int32(i)))
				} else if levels[level - 1][9 - i][j] == 2 {
					addObstacle(.Slow, gridPosition: int2(Int32(j),Int32(i)))
				} else if levels[level - 1][9 - i][j] == 3 {
					addObstacle(.Boost, gridPosition: int2(Int32(j),Int32(i)))
				} else if levels[level - 1][9 - i][j] == 4 {
					addObstacle(.Repair, gridPosition: int2(Int32(j),Int32(i)))
				} else if levels[level - 1][9 - i][j] == 5 {
					addObstacle(.Diamond, gridPosition: int2(Int32(j),Int32(i)))
				} else if levels[level - 1][9 - i][j] == 6 {
					addObstacle(.Teleport, gridPosition: int2(Int32(j),Int32(i)))
				}
			}
		}
	}
	
	func remove(entity: GKEntity) {
		if let spriteNode = entity.componentForClass(SpriteComponent.self)?.node {
			spriteNode.removeFromParent()
		}
		entities.remove(entity)
	}
	
	func explosion(position: CGPoint, explosionType: String) {
		let explosionEmitterNode = SKEmitterNode(fileNamed:"ExplosionParticule")
		explosionEmitterNode!.position = position
		explosionEmitterNode?.zPosition = 2
		
		self.addChild(explosionEmitterNode!)
		
		let coinEarnedImage = SKSpriteNode(imageNamed: "GoldImage")
		coinEarnedImage.position = (explosionEmitterNode?.position)!
		coinEarnedImage.size = CGSize(width: boxSize / 2, height: boxSize / 2)
		coinEarnedImage.zPosition = 2
		addChild(coinEarnedImage)
		coinEarnedImage.runAction(SKAction.moveTo(goldLabelImage.position, duration: 1.0))
	}
	
	func teleportParticule(position: CGPoint, explosionType: String) {
		let explosionEmitterNode = SKEmitterNode(fileNamed:"MagicTp")
		explosionEmitterNode!.position = position
		explosionEmitterNode?.zPosition = 2
		
		self.addChild(explosionEmitterNode!)
	}
	
	func boosterParticule(position: CGPoint, explosionType: String) {
		let explosionEmitterNode = SKEmitterNode(fileNamed:"SlowAndBoost")
		explosionEmitterNode!.position = position
		explosionEmitterNode?.zPosition = 2
		self.addChild(explosionEmitterNode!)
	}
}




