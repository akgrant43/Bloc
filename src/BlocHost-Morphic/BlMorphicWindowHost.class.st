"
I am a concrete implementation of a BlHost that allows users to open host bloc spaces within Moprhic windows
"
Class {
	#name : #BlMorphicWindowHost,
	#superclass : #BlHost,
	#instVars : [
		'isRunning'
	],
	#category : 'BlocHost-Morphic-Host'
}

{ #category : #'driver selection' }
BlMorphicWindowHost class >> isSupported [
	^ true
]

{ #category : #'driver selection' }
BlMorphicWindowHost class >> label [
	^ 'Morphic'
]

{ #category : #'driver selection' }
BlMorphicWindowHost class >> priority [
	"I am a default host, hence return zero.
	Morphic host is the most stable and will work on any machine"
	<return: #Number>

	^ 0
]

{ #category : #'host - api' }
BlMorphicWindowHost >> createHostSpaceFor: aSpace [
	"Create and assign a new morphic host space for given bloc space"
	| aWindow aHostSpace|

	self
		assert: [ aSpace hasHostSpace not ]
		description: [ 'Space must not have a host!' ].

	aWindow := self createMorphicWindowFor: aSpace.
	aHostSpace := BlMorphicWindowHostSpace new morphicWindow: aWindow.
	aHostSpace host: self.
	aHostSpace space: aSpace.
	aHostSpace withSpartaRenderer.

	aSpace hostSpace: aHostSpace
]

{ #category : #private }
BlMorphicWindowHost >> createMorphicWindowFor: aSpace [
	"Note, that I use given space only to find out what window properties to use for created window.
	I do not create any strong or weak references to provided space"
	| aWindow |

	aWindow := BlMorphicWindow new.
	aWindow spaceExtent: aSpace extent.
	aWindow borderless: aSpace borderless.

	^ aWindow
]

{ #category : #'host - api' }
BlMorphicWindowHost >> destroyHostSpaceFor: aSpace [

	self
		assert: [ aSpace hasHostSpace ]
		description: [ 'Space must have a host!' ].
	
	aSpace hostSpace close.
	aSpace detachHostSpace
]

{ #category : #initialization }
BlMorphicWindowHost >> initialize [
	super initialize.

	isRunning := false
]

{ #category : #'host - api' }
BlMorphicWindowHost >> isRunning [
	^ isRunning
]

{ #category : #'host - api' }
BlMorphicWindowHost >> mainLoopPriority [
	^ Processor userSchedulingPriority - 1
]

{ #category : #'host - api' }
BlMorphicWindowHost >> start [
	isRunning := true
]

{ #category : #'host - api' }
BlMorphicWindowHost >> stop [
	isRunning := false
]

{ #category : #'host - testing' }
BlMorphicWindowHost >> supportsBufferSurface [
	^ false
]

{ #category : #'host - testing' }
BlMorphicWindowHost >> supportsFormSurface [
	^ true
]

{ #category : #'host - testing' }
BlMorphicWindowHost >> supportsOpenGLSurface [
	^ false
]
