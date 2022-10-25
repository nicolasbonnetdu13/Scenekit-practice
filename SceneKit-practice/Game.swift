/*
    Copyright (C) 2016 Apple Inc. All Rights Reserved.
    See LICENSE.txt for this sample’s licensing information
    
    Abstract:
    Handles logic controlling the scene. Primarily, it initializes the game's entities and components structure, and handles game updates.
*/

import SceneKit
import GameplayKit

class Game: NSObject, SCNSceneRendererDelegate {
    // MARK: Properties
    
    /// The scene that the game controls.
    let scene = SCNScene(named: "GameScene.scn")!
    
    /**
        Manages all of the player control components, allowing you to access all 
        of them in one place.
    */
    let playerControlComponentSystem = GKComponentSystem(componentClass: PlayerControlComponent.self)
    
    /**
        Manages all of the particle components, allowing you to update all of 
        them synchronously.
    */
    
    /// Holds the box entities, so they won't be deallocated.
     var boxEntities = [GKEntity]()
    
    /// Keeps track of the time for use in the update method.
    var previousUpdateTime: TimeInterval = 0
    
    // MARK: Initialization
    
    override init() {
        super.init()
        
        setUpEntities()
        addComponentsToComponentSystems()
    }
    
    /**
        Sets up the entities for the scene. It creates four entities with a
        factory method, but leaves the purple box entity for you to set up 
        yourself.
    */
    func setUpEntities() {
        
        let blueBoxEntity = makeBoxEntity(position: SCNVector3(-4, 1, 0), color: .blue, wantsPlayerControlComponent: true)
        
        let purpleBoxEntity = makeBoxEntity(position: SCNVector3(-2, 1, 0), color: .purple, wantsPlayerControlComponent: true)
        
        // Create entities with components using the factory method.
        let redBoxEntity = makeBoxEntity(position: SCNVector3(0, 1, 0), color: .red, wantsPlayerControlComponent: true)
        
        let yellowBoxEntity = makeBoxEntity(position: SCNVector3(2, 1, 0), color: .yellow, wantsPlayerControlComponent: true)
        
        let greenBoxEntity = makeBoxEntity(position: SCNVector3(4, 1, 0), color: .green, wantsPlayerControlComponent: true)
        
        /* 
            Experiment for yourself:
            Try creating and attaching a ParticleComponent and 
            PlayerControlComponent for the purple box in the space below.
        */
        
        // Keep track of all the newly-created box entities.
        boxEntities = [
            redBoxEntity,
            yellowBoxEntity,
            greenBoxEntity,
            blueBoxEntity,
            purpleBoxEntity
        ]
    }
    
    /**
        Checks each box for components. If a box has a particle and/or player 
        control component, it is added to the appropriate component system.
        Since the methods `jumpBoxes(_:)` and `renderer(_:)` use component
        systems to reference components, a component will not properly affect 
        the scene unless it is added to one of these systems.
    */
    func addComponentsToComponentSystems() {
        for box in boxEntities {
            playerControlComponentSystem.addComponent(foundIn: box)
        }
    }
    
    // MARK: Methods
    
    /**
        Causes each box controlled by an entity with a playerControlComponent 
        to jump.
    */
    func jumpBoxes() {
        /*
            Iterate over each component in the component system that is a
            PlayerControlComponent.
        */
        for case let component as PlayerControlComponent in playerControlComponentSystem.components {
            component.jump()
        }
    }
    
    /**
        Updates every frame, and keeps components in the particle component 
        system up to date.
    */
    func renderer(_: SCNSceneRenderer, updateAtTime time: TimeInterval) {
        // Calculate the time change since the previous update.
        let timeSincePreviousUpdate = time - previousUpdateTime
        
        // Update the particle component system with the time change.
//        particleComponentSystem.update(deltaTime: timeSincePreviousUpdate)
        
        // Update the previous update time to keep future calculations accurate.
        previousUpdateTime = time
    }
    
    // MARK: Box Factory Method
    
    /**
        Creates box entities with a set of components as specified in the 
        parameters. It uses default parameter values so parameters can be 
        ommitted in the method call. The parameter particleComponentName is a 
        string optional so its default parameter value can be nil.
    
        - Parameter name: The name of the box that this entity should manage.
    
        - Parameter wantsPlayerControlComponent: Whether or not this entity 
        should be set up with a player control component.
    
        - Returns: An entity with the set of components requested.
    */
    func makeBoxEntity(position: SCNVector3, color: UIColor = .lightGray, wantsPlayerControlComponent: Bool = false) -> GKEntity {
        // Create the box entity and grab its node from the scene.
        let box = GKEntity()
        
        let boxGeometry = SCNBox(width: 1, height: 2, length: 1, chamferRadius: 0)
        let material = SCNMaterial()
        material.isDoubleSided = true
        material.diffuse.contents = UIColor.lightGray
        boxGeometry.firstMaterial = material
        let boxNode = SCNNode(geometry: boxGeometry)
        let physicShape = SCNPhysicsShape(geometry: boxGeometry)
        let physicsBody = SCNPhysicsBody(type: .dynamic, shape: physicShape)
        boxNode.physicsBody = physicsBody
        boxNode.position = position
        
        scene.rootNode.addChildNode(boxNode)
        
        // Create and attach a geometry component to the box.
        let geometryComponent = GeometryComponent(geometryNode: boxNode, color: color)
        box.addComponent(geometryComponent)
        
        // If requested, create and attach a player control component.
        if wantsPlayerControlComponent {
            let playerControlComponent = PlayerControlComponent()
            box.addComponent(playerControlComponent)
        }
        
        return box
    }
}
